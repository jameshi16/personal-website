---
title: "Desktop in LXD Containters"
date: 2019-09-04 23:00 +08:00
categories: [lxd, containers, desktop, linux]
tags: [lxd, containers, desktop, linux, ubuntu, x11, pulseaudio]
published: true
---

Sometimes, when dabbling with technology, you want to know the limits, and how far you can push it before it becomes "too far".

If you've ever read the [About me](/about/) page, you would know that I am a privacy advocate. It means that I go the extra mile to ensure that no one else but myself knows everything about, well, myself. This is why containers are so intriguing to me; they essentially confine applications within a jail that is difficult to escape from, but yet still share the same kernelspace as my host system, giving it much less computing overhead compared to their Virtual Machine counterparts.

This is very useful for developers; which is why applications like [Docker](https://www.docker.com/) exists. These containers ensure that they function exactly the same across all the platforms that can run Docker, eliminating the popular "but it works on my machine!" problem. Other than Docker, which containerizes applications, there are other more general-use container applications, such as `Linux Containers (LXC)` and `LXD`. One clear difference between Docker and LXC, would be the fact that by default, Docker spawns non-persistent containers, while LXC spawns persistent containers, making Docker useful to host applications that interact with an external database, but do not store state themselves (i.e. almost all applications I can think of). LXC, on the other hand, would be useful to create something like a development environment; containing tools such as compilers, interpreters, IDEs, text editors, and sometimes even Docker (container in container-ception!).

### How I have been using LXD Containers

For some people, it is an anti-thesis to computing to have all your tools so segregated. People like all their tools to be in one place, accessible anytime they command. However, I am an organizing freak when it comes to computers.

All projects shall have their own containers - that is my philosphy. The host computer is nothing but a container orchestrator, with the sole purpose of managing the display, USB connections, networking with the outside world, et. cetera. This means that the bulk of my work is done in LXD containers; I even go the extra mile to use an external hard disk to store these containers, so that I can fully isolate even the storage hardware used for the containers.

At the beginning of last year, I followed a [guide by Simos](https://blog.simos.info/how-to-run-graphics-accelerated-gui-apps-in-lxd-containers-on-your-ubuntu-desktop/) on how to allow LXD containers to run X11 applications on the host XOrg server. For a while, that was how I developed graphical applications using graphical IDEs; sometimes, GUIs cannot be avoided. Despite my longing to use the terminal for everything, reality is not all fun and games, meaning some work must be done via GUI.

Simos' guide had some gaping holes in security, however. In his guide, a user mapping is performed on the container to the host; meaning that the unprivileged user's User ID (UID) in the container matched with the one on the host. In simpler terms, that means that `ubuntu@host` has the same user ID has `ubuntu@container`. Should a process be able to escape the isolation provided by the container, the user in the container would have the **same** permission as a normal user in the host, allowing the container's malicious processes to affect files in the host filesystem, particularly the home directory.

Let's not talk about privileged containers; they're just like user mapping, except that **all** the users are mapped, including root (UID 0). [Brauner's blog](https://brauner.github.io/2019/02/12/privileged-containers.html) explain what privileged containers are, and why they are dangerous, even including a link to a [vulnerability report, CVE-2019-5736](https://seclists.org/oss-sec/2019/q1/119). In essence, the only security one would have left are the confines of a chroot jail and apparmor (alongside other techniques, read more about them in Brauner's blog).

The other gaping hole exists in the fact that both the container and the host would share the same XOrg server, meaning that if the container had a keylogger, or a clipboard monitor, and the container is connected to the host via X11, any keystroke performed within the XOrg server (i.e. any application within the host _and_ client) can be stored and used for malicious purposes.

Of course, this would not be an issue if you were to trust the applications within the privileged containers; if you aren't testing untrusted programs or just generally don't trust anything at all, forwarding your X11 server using Simos' method is a viable option to organize your applications and development environments. For a while, I was contend with that; as long as it stayed within the container, I could, at any moment, export and subsequently delete the container. Other than the standard container advantages, this also allowed me to separate configurations for the same application between the containers; for example, I can have a newer version of CUDA tookit installed on my host, but a different version of CUDA tookit installed in the container, without the container's tookit conflicting with my host toolkit; I could also compile a newer version of Clang just for a container without the older compiler available on my host, and the list goes on.

However, as my requirements increased together with my workload, I found this solution to be insufficient. I found myself often times requiring to forward ports from my container just so that I can access certain features within the container; then I found myself requiring to reset cookies often so that my webapp that integrates with many services can have a fresh state to work on; while other times, I wouldn't want to reset it (incognito would not cut it, as I would need to recreate those cookies every browser restart); then I found myself just generally wishing I had file browsers, dedicated terminals for my containers etc. As my requirements grew, so did the number of tabs on my terminal emulator, until one day, I decided it was the end of the XOrg sharing era.

### ContainerTop

After my examinations, I took a few days to develop [ContainerTop](https://github.com/jameshi16/ContainerTop) - a creatively named project to create containers that hosts their own desktop environments, on their own XOrg servers, complete with hardware graphics acceleration (meaning you can play 3D games on it), sound forwarding, and native processing speed minus the typical container overhead (not much).

"What about Virtual Machines? Like virt, VirtualBox and VMWare?" - To get **hardware** graphics accleration, you need to do PCI passthrough. To perform PCI passthrough on a single GPU device, you need to edit the graphics controller's ROM, which is a risk not many people want to take. Plus, virtual machine overhead includes emulating the kernel, which is a big, big overhead.

"Okay, why not go with Xpra/Xrdp/X2GO/SSH X11 Forwarding?" - Same problems as I mentioned in the above section.

"But, Xpra/X2Go can host desktop environments too!" - The overhead is quite substantial in this setup; first, there is the connection. Between the SSH, TCP and NX protocols, the NX protocol is arguably the fastest protocol available out there. Even with NX protocol's superiority, the overhead and hence latency is noticeable. Secondly, there is also image compression. To get acceptable image quality (16k-png) on a local connection (remember, the container is on localhost), the amount of stutter while watching videos is surprisingly unbearable. As much as possible, I would not like to switch between the container and the host while working on a project, because everything I need should be already inside the project container, in one workspace. Hence, being able to watch videos (useful for learnings things on the spot) is an absolute requirement, which leaves Xpra and X2Go unusable. Of course, if all that is needed is a desktop environment for the sole purpose of development and nothing else, Xpra and X2Go provides fantastic speeds and quality (I tested it during these few days of implementing ContainerTop), with Xpra even supporting VirtualGL, so you can install desktop environments on a beefy server, and then use a Thin Client to access it, while maintaining the capabilities required for 3D accelerated programs like FreeCAD with a reasonable latency.

"AWS, Google Cloud, Alibaba Cloud..." - Any cloud service would have too much latency for my tastes. Also, same problem as the above paragraph.

To use ContainerTop, all applications that uses XOrg must be killed, so that the video card is free from any usage. Then, the container's XOrg server is booted, which will take control of the video card and start displaying content. This is all done on an unprivileged and unmapped container; and only the required devices are passed through; things like the video card, mouse and keyboard. Brightness and sound are passed through via a different method, without giving the container direct access to those functionalities.

You can find out more, and even try ContainerTop for yourselves [here](https://github.com/jameshi16/ContainerTop). Please note that you will need an afternoon to set things up properly, so do it only when you are free!

With ContainerTop, I can (finally) have an isolated workspace for any projects I'm working on, with the added bonus of LXD's container management capabilities, including taking snapshots of the container for rollback, export and publishing purposes, and deleting the containers anytime I no longer need them. It's the most perfect solution for me.

### Problems encountered while developing ContainerTop's first version

Long section title, I know.

You didn't expect me to write a blog post claiming I had absolutely no problems developing ContainerTop did you? :smirk:

It's all about the learning experience. 

Anyway, developing the desktop switching part of ContainerTop on my particular setup created many, many problems. The desktop switching script (`desktop_enter.sh` and `desktop_enter_vt.sh`) is in charge of setting the correct permissions, killing the host's login manager and starting the login manager on the container. Let me explain the problems, and how I solved them, and how that created even more problems. 

Firstly, my external harddrive is encrypted, and I made it a policy to manually decrypt it everytime I want to use it. As such, I first tried to make a userspace script (i.e. to be run logged into GNOME session on Ubuntu), with fancy script hooks to my encryption/decryption script, switching the user around terminals, et cetera. The problem was that the TTY spawned by the script to run the child process of the aforementioned script was not persistent; after a certain time period, the script will just magically cease to work.

I tried to find the cause of the issue, and figured out that killing the login manager also probably tries to kill all the child processes spawned from it, and my script was one of those children. I took about two days to come to this conclusion after many, many hours experimenting.

Giving up on the userspace script, I decided to write a script that required a virtual terminal to run. This is how the user would interact with this new script: Logout of GNOME session -> See login screen -> Press CTRL+ALT+F\<num\> to switch to a free terminal -> Run the desktop switching script. Once I got that working with the container I manually constructed to model subsequent containers after, I added the brightness script, which was written using `evtest` on the host so that the container cannot get malicious access to it programmatically (i.e. can cause epilepsy by flashing the screen fast enough). And then I tried to write a PulseAudio script.

Turns out, PulseAudio was yet another brick wall. For those uninitiated, PulseAudio is how most Linux distro handles sound, and is run on a per-user basis. Typically, that is great, but in the context of Virtual Terminals (TTYs), this is bad news. If you have free time, you should try it; first, grab a random `.wav` file, and play it on any virtual terminal using `paplay soundfile.wav` (maybe on tty3). Then, switch your terminal using CTRL+ALT+F\<num\>. Your music file should stop playing. That's how PulseAudio handles sound; only the current active Virtual Terminal gets to play sound. Since ContainerTop's desktop switching script uses a different TTY for display than the TTY used to run the script, this means that I cannot forward PulseAudio's sound while it's running in user mode.

Back then, I didn't know `--system=TRUE` was a thing; so it took me another two days of pure trial and error (with options not related to PulseAudio) to figure out that I needed to run PulseAudio in system mode, which the PulseAudio devs dub as a bad idea :tm:. If you can, try it for yourself; run `pulseaudio --system=TRUE`, do the same playing of the music file thing, and then switch terminals. You'll notice that the sound continues to play. That is a good sign.

Hence, using that new found knowledge, all I needed to do to forward PulseAudio to the container, is to enable PulseAudio's native TCP module, and copy the pulse cookie into the container; this is all done in the PulseAudio script under the `modules/` subdirectory.

I then wrote the container creation script, referring to the model container to see what was required. It may sound all good, but here's the catch: I've fiddled with the model container, to try and find the most optimal configuration, meaning that there may be some additional packages, unrequired configurations, etc that lay residue inside the container. Hence, when the container created from the container creation script didn't work, I was left very confused and frustrated, because I thought I copied almost all aspects of the model container.

After another set of countless hours fiddling with the container configuration files, I finally arrived at a conclusion: the LightDM's greeter was the main cause.

"Huh?"

LightDM can be customized with what is known as greeters; they change the background slightly, maybe move the login panel to the center, has more/less widgets, et cetera. When I first checked the logs for the greeter, there was a line that basically said:

```
...
the greeter executable - screen is 0,0, drawing 0,0 login screen
...
```
<p class="text-center text-gray lh-condensed-ultra f6">Note: not the actual log</p>

This of course looked off, but I didn't attribute it to the greeter at first; because I mean, all greeters basically do the same thing, right?

I only gave changing the greeter to `unity-greeter` a try when I have exhausted all the other options, and to my surprise, it worked! Checking the logs, it seems like `unity-greeter` was able to detect the screen resolution, leaving me, an ex-convict of the confusion prision, jumping for joy. Up to now, I still have no idea why the previous greeter (`slick-greeter`) didn't work - I thought of manually configuring them, but at that point I just wanted the screen to display something from the container.

There were also the problems of how the script can be easily terminated, and malicious attackers with physical access to the computer can simply do so to gain user account access, which I solved by killing the bash process of the TTY the script is in once it terminates, requiring any users to log in again to use the Virtual Terminal.

### Conclusion

There are still some quirks that I intend to iron out, and new features I want to implement to make my life inside the container much easier for myself. Working on ContainerTop has taught me quite a lot of things, including how maintainers think, and how to debug issues when you're no longer within a desktop environment. Please check out the [ContainerTop](https://github.com/jameshi16/ContainerTop) project, and try it out on your free time!

Happy Coding,

Coding Index
