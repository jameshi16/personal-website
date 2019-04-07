---
title: My Experience with Gentoo (so far)
date: 2019-04-07 12:00:00 +08:00
published: true
tags: [gentoo, linux, operating systems]
categories: [linux]
---

I installed Gentoo the other day, and would like to share my thoughts on Gentoo, mainly, how it caught my attention.

<img src="https://assets.gentoo.org/tyrian/site-logo.svg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Gentoo Logo"/>
<p class="text-center text-gray lh-condensed-ultra f6">Gentoo Logo | Source: <a href="https://www.gentoo.org/">Gentoo's Official Website</a></p>

Being a privacy evangelist, and a FOSS freak, I was intrigued by Gentoo. There were several reasons for this:
1. Gentoo's Package Manager, Portage;
2. Gentoo's promise of being highly configurable;
3. Gentoo's standing in the community.

# Gentoo's Package Manager, Portage
According to [Gentoo's Wiki regarding Portage](https://wiki.gentoo.org/wiki/Portage), Portage is the official package manager and distribution system for Gentoo. This not only means Portage is used to obtain packages that I need for regular use, but also to update Gentoo itself.

The most interesting thing about Portage is its build system - it compiles packages (that has a FOSS license) from scratch. Using a combination of system and user flags, you can even optimize how Portage compiles these packages, and make full use of whatever resources your system has to compile these packages. It is always mesmerizing to see `configure` and `Makefile` scripts running over and over as Portage compiles the packages and its dependencies; it puts your system in your complete control, and you can feel the _power_.

# Gentoo's Promise of being highly configurable
Gentoo is so ridiculously configurable, you can feel its configurability all the way from installation. When installing Gentoo, you're literally copying the contents of a `tar.gz` archive to your system; from this step alone, you can already start configuring your installation, if you know what you are doing. Then, during installation, you have to configure and compile your kernel, manually mount the EFI, install GRUB, etc.

After installation, if you selected the minimal profile during base system installation outlined in [this part of the handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base), you get to choose and install a desktop environment / window manager, configure that, choose between [nouveau](https://wiki.gentoo.org/wiki/Nouveau) or the [NVIDIA Proprietary graphics drivers](https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers) (although, note that this particular package is closed-source. Only the wrappers are compiled against the source). Then, you choose a composer, a network manager (if you wish), choose between [AppArmor](https://wiki.gentoo.org/wiki/AppArmor) or [SELinux](https://wiki.gentoo.org/wiki/SELinux), your [image viewer](https://wiki.gentoo.org/wiki/Category:Image_viewer), [ALSA](https://wiki.gentoo.org/wiki/ALSA) only or ALSA + [PulseAudio](https://wiki.gentoo.org/wiki/PulseAudio); everything is under your control. Every. Thing.

# Gentoo's standing in the community
There is a thread on [Reddit](https://www.reddit.com/r/linuxmasterrace/comments/6sjjq3/how_i_feel_about_arch_vs_gentoo/) that made an apt comparison between Gentoo and Arch Linux:

<img src="https://i.redd.it/1q4q7ojpjnez.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Good comparison between Gentoo and Arch Linux"/>
<p class="text-center text-gray lh-condensed-ultra f6">Comparison between Arch and Gentoo | Source: <a href="https://www.reddit.com/r/linuxmasterrace/comments/6sjjq3/how_i_feel_about_arch_vs_gentoo/">Reddit</a></p>

Jokes aside, I don't have concrete evidence that can definitively prove Gentoo's good reputation online, although I personally think so. For it's flexibility and configurability, I would imagine that other privacy and security enthusiasts would also enjoy Gentoo as a daily driving operating system.

# Conclusion
I have installed Gentoo for over a week now, and am enjoying every second with it. If you like to dabble with operating systems, especially Linux, and don't mind sinking hours upon hours of time tweaking every aspect of your operating system, then I suggest you try out Gentoo, maybe you'd like it!

Happy Coding,

CodingIndex
