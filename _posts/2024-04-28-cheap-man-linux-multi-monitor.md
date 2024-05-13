---
title: Cheap man's Linux Multi-Monitor Setup
date: 2024-04-28 00:33 +0100
published: true
categories: [linux]
tags: [linux, multi, monitor]
---

EDIT (13/5/2024): A quick note for the various mentions of Immersed in this post. The company has
recently removed support for physical multi-monitor setups, _requiring_ you to turn off all external
monitors to use Immersed. While the company reserves all rights to do whatever they want with their
software, they have begun banning and moderating away posts that criticised this change. There are
speculations that this is done to keep their records clean for the upcoming IPO. Hence, I cannot, in
good faith, endorse Immersed anymore. There is currently no good alternative for a physical +
virtual multi-monitor setup.

Good morning! :coffee:

Recently, I've been playing around with some ideas that'll eventually get me 24
monitors. Why the impractical and unholy number of monitors?

If I'm being completely realistic, that's way too many monitors to be
practical. It's just way too many monitors to even be useful, except
for some extenuating circumstances like stocks trading.

So, instead of coming up with a good excuse, I present you the best argument
I've had since time immemorial: why not, sounds fun!

There have been some interesting ideas to accomplish this surrounding the use
of Virtual Reality (VR) headsets, using apps like
[Immersed](https://immersed.com) to achieve both a multi-monitor setup, and a
distraction-free environment. When COVID-19 was still a prominent part of life,
I could see this being used fairly frequently.

On [Immersed's FAQ](https://immersed.com/faq), under "What devices can run immersed?", it is stated
that "Currently, Linux only supports plugged-in external monitors" with "virtual displays coming
soon!" (accurate at the time of writing).

Borrowing a mate's Quest 2, I was able to verify that Immersed wasn't able to
spawn new displays on Linux.

So that got me wondering; what if I could implement this killer feature? Apart from Immersed, I
could turn old devices into high-speed, low latency external displays.

Apps like these already exist; notable examples include GNOME's virtual displays and
[deskreen](https://deskreen.com/lang-en).

"But!" I exclaim to myself.

"I want a potentially unlimited number of virtual displays!" I bemoaned.

"And I want to do it by _myself_!" I lamented.

Lo and behold, of course I'd find a way.

----

# Discovery

Ideally, I want whatever solution I come up with to be GPU-agnostic; i.e. there shouldn't be
something that _only_ works for Intel iGPUs (as in the case with `VirtualHeads` in XOrg
configurations).

When searching online, I came across [this wonderful person's
post](https://unix.stackexchange.com/a/585078), who suggested that we can use `DisplayLink`'s `evdi`
kernel module, which allows us to set an initial number of devices.

Running the right `xrandr` commands will then get us virtual monitors that we can't
directly observe on physical monitors, but can instead be accessed via something like VNC or an alternate method
which I will later propose.

# Base: Setting up multiple monitors

The first step is to install the `evdi` kernel module. On Ubuntu, it is as simple as running `sudo
apt install evdi-dkms` and then restarting the system.

On other systems, either look for `evdi` in your package manager, or compile it from the
[source](https://github.com/DisplayLink/evdi).

Now, run `modprobe evdi initial_device_count=2` (or however many you want). 
After which, restart your X session; this can typically be done by signing out and then logging back
in, although I've only ever tested it by using the "restart X session" functionality on my i3
config. (i.e. killing the X session and restarting it).

> You'd have to do this every restart. If you already have a good idea on how
> many additional virtual monitors you want, you can choose to add this to
> `/etc/modprobe.d/local-evdi.conf`: `options evdi initial_device_count=X`, where `X` is the number
> of monitors you intend to boot with.

Now, perform `xrandr --query`. You should see a bunch of disconnected monitors, which can look like
this:

```
DVI-I-3-2 disconnected (normal left inverted right x axis y axis)
DVI-I-2-1 disconnected (normal left inverted right x axis y axis)
eDP-1-1 connected primary 1920x1080+0+0 (normal left invertest right x axis y axis) ...
```

At this point, add the resolution you want your virtual monitors to be. There are plenty of guides
online on how you can add custom resolutions, but if you're adding well-known resolutions (such as
"1920x1080", "1920x1200"), you can do so by running these commands:

```
xrandr --addmode DVI-I-2-1 1920x1200
xrandr --addmode DVI-I-3-2 1920x1080
```

> Note: If you have other interfaces that are free, you can use those instead. The `DVI-I` ones are
> generates by `EVDI`.

Figure out how you want to lay your monitors. In my setup, I want `DVI-I-2-1` to be on the right of
`eDP-1-1`, and `DVI-I-3-2` to be on the right of `DVI-I-2-1`. Here's the `xrandr` magic to achieve
that:

```
xrandr --output DVI-I-2-1 --mode 1920x1200 --right-of eDP-1-1
xrandr --output DVI-I-3-2 --mode 1920x1080 --right-of DVI-I-2-1
```

Congratulations! You've managed to set up virtual desktops. Way to go :beers:

Now, how do you see content on those monitors?

----

# Viewing

Suppose you have two other devices to display the two new virtual monitors you've set up; then there
are actually a fairly abundant number of ways you can go about this. The easiest way is probably
with a VNC server and client, where there are plenty of guides for.

One way I tried that didn't work was with NoMachine (notoriously known to be incredibly fast); it
wasn't happy about the virtual monitors and drew a large black box over where they were supposed to
positioned.

If you have a VR workspace emulator like Immersed, the virtual monitors you've created should just
work straight away (tried and tested).

The rest of this blog post will outline a less conventional way - using
`ffmpeg` and `ffplay`. This allows me to take advantage of a host's NVIDIA card
to display my virtual monitors on other devices.

## Method

First, run `xrandr --query` to figure out the offsets of your outputs. For instance, here's what
mine looks like:

```
> xrandr --query

DVI-I-3-2 disconnected 1920x1200+3360+1000 (normal left inverted right x axis y axis) 0mm x 0mm
DVI-I-2-1 disconnected 1920x1080+5280+1000 (normal left inverted right x axis y axis) 0mm x 0mm
```

This means that `DVI-I-3-2` has an x-offset of `3360`, and a y-offset of `1000`, while `DVI-I-2-1`
has an x-offset of `5280` and a y-offset of `1000` (I have a weird setup).

As you may have guessed, the devices I am planning to project the virtual monitors to are
`1920x1200` and `1920x1080` in resolutions respectively.

Hence, on the host, I run the following command:

```
ffmpeg -video_size 3840x1200 -f x11grab -framerate 60 -i :0.0+3360,1000 \
-c:v h264_nvenc -zerolatency 1 -profile:v main -preset llhq -maxrate 500k \
-bufsize 1m -qp 0 -f mpegts udp://<client 1 IP>:<some port you choose> -c:v \
h264_nvenc -zerolatency 1 -profile:v main -preset llhq -maxrate 500k -bufsize 1m \
-qp 0 -f mpegts udp://<client 2 IP>:<some port you choose>
```

> Quick Disclaimer: I am not a `ffmpeg` pro. I'm fairly certain this can be optimized to smithereens,
> but for the purposes of this blog post (and my usage), this is more than good enough.

The command above screen grabs the regions defined above (essentially the two virtual monitors), and
sends the stream to both devices. The other flags are there to decrease the latency as much as
possible. Note that this setup is _still_ not sub-one latency, but is much faster than achievable
with VNC (`ffmpeg` pros could probably get it to sub-one latency).

Ensure that the client allows ingress into both ports on their firewall, then, on the respective
clients, run the following `ffplay` commands:

```
# Client 1 (the 1920x1200 one)
ffplay -vf "crop=1920:1200:0:0,setpts=0" -fflags nobuffer -flags low_delay \
-framedrop -strict experimental -probesize 32 -fast -an udp://127.0.0.1:<port>

# Client 2 (the 1920x1080 one)
ffplay -vf "crop=1920:1080:1920:0,setpts=0" -fflags nobuffer -flags low_delay \
-framedrop -strict experimental -probesize 32 -fast -an udp://127.0.0.1:<port>
```

The two clients should connect, after which you can press "F" to fullscreen the window.
Congratulations, both devices should now be displaying your virtual screens!
You can now interact with them as if they were external monitors to your host machine.

----

# Conclusions

The solution above can be combined into a single script to suit your needs. It shows that even
without dedicated software, it is possible to have a virtual monitor setup that (basically) supports
unlimited monitors.

If you have any spare devices laying around, and they can run VNC clients / `ffplay`, give this a
shot! You may be able to give it a new lease of life as a secondary monitor.

Happy Coding,

CodingIndex
