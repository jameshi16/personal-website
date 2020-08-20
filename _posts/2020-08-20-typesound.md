---
title: TypeSound (Release)
date: 2020-08-20 11:00 +08:00
categories: [release]
tags: [release, python, typesound]
published: true
---

> **NOTE**: Most of this post is satire, although [TypeSound](https://github.com/jameshi16/TypeSound) actually does exist, and does correspond your typing speed with playback rate. Refer to [this section](#typesound) for setup instructions.

# Typing

Typing on its own is relatively inconsequential - after all, it is all but a means to put down your thoughts and contributions, which can hopefully be accumulated with efforts from others towards impacting the world in any form.

The virtue of typing has assimilated into our DNA so much, that it has become a norm - typing is no longer a meaningful and special activity. The feeling of pure ecstasy as you tap your fingers on the pleasingly noisy keys of the [typewriter](https://en.wikipedia.org/wiki/Typewriter), the first [IBM keyboard](https://en.wikipedia.org/wiki/IBM_PC_keyboard), and your first ever mechanical keyboard wears out after a few weeks.

The activity of typing once again becomes a chore to put down your thoughts and contributions towards advancing (or regressing) humanity. This is a normal process, and the conventional status quo between you and your latest keyboard would have remained if only this nosy fellow called CodingIndex did not intervene.

# Music

Music has evolved over the decades it has existed; in some ways, each golden era of a genre represents the lifeblood of a generation. After all, music is a universal language capable of invoking emotions, conveying deep messages and inspiring people of diverse backgrounds and cultures to keep on creating.

The point is: music never gets boring. Not only is it a platform for artists to share their talents, but also a form of communication we rely on to change perceptions - hence, it grows with us (happy birthday), and dies with us (parlor music, or if you're a hardcore meme king/queen, [this](https://www.youtube.com/watch?v=iLBBRuVDOo4)). People comment "play this at my funeral" on their favourite sad songs, write short stories for inspirational music, and use dramatic soundtrack to signify - well, drama, in a video clip.

# Idea :keyboard: + :musical_note:

What if, we renewed the excitement of pressing keys on a keyboard, by intrinsically combining that with music?

What if, the combination involved the _playback rate_ of music?

Introducing :drum:... TypeSound!

# TypeSound

TypeSound is a bunch of python scripts working together to involve your music into your typing experience by linking your typing speed to the playback rate of your favourite songs. By being in direct control of how you hear your music, not only is it a source of entertainment whenever you get bored on your desk, but also an incentive for typing - bringing a direct purpose to your typing session.

Just listen to this satisfied user:

> I haven't tried TypeSound, nor am I a real person, but I love it!

What are you waiting for? Try [TypeSound](https://github.com/jameshi16/TypeSound) today!

## Setting up

The masterpiece known as TypeSound has the following requirements:
- [sox](http://sox.sourceforge.net/) with the `libsox-fmt-mp3` extension. Seems to come with the Windows and MacOS installer.
    - For Ubuntu systems, run `sudo apt install -y sox libsox-fmt-mp3`
- [Python 3.6 or above](https://www.python.org/)
- Access to any typing speed test website like [10fastfingers](https://10fastfingers.com/typing-test/english) or [TypeRacer](https://play.typeracer.com/)

> NOTE: Widnows and Mac OSX are not supported yet, because detecting keypresses on your keyboard is done in a Linux-only way (relies on X11). Support should be coming soon, and this notice will be removed accordingly.

(Optional) If you want, create a virtual environment for TypeSound. On Ubuntu, this is achieved with:

```bash
$ virtualenv -p python3 ~/.environments/typesound
$ source ~/.environments/typesound/bin/activate
```

Install the required pip packages by running the following command in terminal (Linux/Mac OS) or PowerShell (Windows):

```bash
$ pip install -r requirements.txt
```

Then, run the configuration script. It'll prompt some instructions to you, and you just need to follow them to complete your first configuration:

```bash
$ ./config.py
```

Subsequently, when you run `./config.py` again, it will modify the existing configuration.

When you are satisfied with your configuration, run:

```bash
$ ./main.py
```

Then start typing away! You should hear the music increase/decrease its playback rate based on your typing speed.

---

# Conclusion

I hope you enjoyed this blog post; most of the content is satire, except for the "Setting up" section. In reality, I wrote the scripts for my own entertainment and learning, testing features on GitHub, listening to the keyboard, and performing audio processing to increase/decrease playback rate.

There is one more blog post that talks about how I developed TypeSound, the problems I faced and how I overcame them. Do check it out [here](/2020/08/20/typesound-dev).

Happy coding

CodingIndex
