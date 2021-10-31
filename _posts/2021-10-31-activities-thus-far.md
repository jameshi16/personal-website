---
title: Activities Thus Far
date: 2021-10-31 16:44 +0800
published: true
categories: [general]
---

Happy Halloween! :tada:

It's been a while, huh? I've completely broke my [New Year's resolution](/2021/02/14/zerotier-openvpn-nat-part-1/) of delivering 1 blog post every month, gotten listless in my life, and generally lost a great chunk of motivation to maintain my Gentoo installation. In terms of recreation during my weekends, I spend a great deal of time playing Gacha video games (as a free-to-play because I'm broke) and watching a [bunch of anime](/anime/).

It has been a few months since I last touched code for recreation - something I regret greatly. Sometimes, in moments of panic and anxiety for the future, I would log into HackerRank just to practice. Recently, I've been slowly going through the [Rust Programming Language](https://doc.rust-lang.org/book/title-page.html) book, which has a notable "borrowing" concept to manage memory that piques my interest to explore it in the near future.

Of course, this isn't all I've been doing for the past few months. I've picked up chess puzzles (not chess itself), learnt how to solve the Rubik's cube, automated some parts of my job with simple excel skills, and:

- Found out my Maxtor External HDD died
- Repaired my HP 23es monitor
- Created a ephemeral Windows 10 LiveCD with WinPE

---

# Maxtor External HDD

This external HDD has been with me for three years, containing many projects and Linux containers used for academic purposes and hackathons. My laptop, while a powerhouse, has limited storage, and could not meet the storage demand required to archive these projects. Hence, I rely on the external HDD as-if it was a built-in drive, which meant that it was plugged in at every moment the laptop is online.

Despite knowing that [the typical hard drive lasts for 3 to 5 years](https://www.newegg.com/insider/how-long-do-hard-drives-and-ssds-last/), I thought that there was no need to do predictive maintenance (like backing up) on the drive; furthermore, S.M.A.R.T was still returning an "ok" a few weeks prior to the failure. Alas, it failed spectacularly, and I was unable to recover the data on the drive with tools like `dd` and Live Recovery CDs like [CloneZilla](https://clonezilla.org/).

To troubleshoot further, I thought about what an external (implied: portable) HDD is typically made up of:
1. SATA to USB3.0 converter;
2. 2.5" HDD

Cracking open my Maxtor drive, I found out that my Maxtor's internal HDD uses a 1TB harddrive from Seagate. Inputting the serial number into the Seagate warranty website suggests that the internal HDD was made particularly for Maxtor HDDs.

<img src="/images/20211031_1.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Internal HDD photo"/>
<p class="text-center text-gray lh-condensed-ultra f6">Internal HDD bundled with the adapter | Source: Me</p>

<img src="/images/20211031_2.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="SATA to USB3"/>
<p class="text-center text-gray lh-condensed-ultra f6">SATA to USB3.0 adapter | Source: Me</p>

I took the Maxtor internal HDD and plugged it into a desktop with a SATA cable to try recovering the data again.

<img src="/images/20211031_3.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Plugging in the HDD"/>
<p class="text-center text-gray lh-condensed-ultra f6">Plugging in the HDD | Source: Me</p>

To my dismay, it didn't work: all of the sectors after the header sector is completely unreadable; furthermore, I've encrypted the drive with VeraCrypt, so chances are, the data is impractical to recover.

## Harddrive Lifespan

It may seem like I am barking up the wrong tree here, but I am quite disappointed in the performance of Seagate drives in general. A majority of the drives in my possession are from Western Digital, which are fantastic drives that have lasted me 5 - 6 years since I've acquired them.

And it's not just me; a majority of those in the tech community agrees that WD drives (particularly WD Black) are very reliable hard drives. In my life, I've owned two Seagate drives; both of them have failed, despite being newer than my WD Blue drives. I also own an old WD Passport from 2015, which has outlasted everything I've had in my possession, although it is an unfair comparison since I don't run the drive unless necessary.

## Solution

In the first place, relying on the external HDD for daily, I/O intensive stuff is generally a bad idea :tm:. So, I decided to solve the root cause: my laptop did not have enough storage capacity for my needs. My laptop has a 512GB Samsung 960 M.2 SSD, which is partitioned somewhat in half for dual-booting Windows & Ubuntu. This meant around 230GB for each operating system for programs, documents, Machine Learning models, and highly bloated IDEs.

Hence, I decided to get a 1TB Samsung 980 M.2 SSD:

<img src="/images/20211031_4.webp" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Samsung 980"/>
<p class="text-center text-gray lh-condensed-ultra f6">Samsung 980 M.2 SSD | Source: <a href="https://www.samsung.com/sg/memory-storage/nvme-ssd/980-pro-pcle-4-0-nvme-m-2-ssd-1tb-mz-v8p1t0bw/">Samsung Official Site</a></p>

I also decided to replace the external HDD with a new WD Passport, to archive projects that I won't be working on anymore. This new management of storage will allow my HDD to last much longer, and allow me to bring items with my laptop to do productive work. Furthermore, the upgrade even increased my boot times quite a bit.

---

# HP 23es Monitor

One day, my display ceased to function. To troubleshoot it, I decided to open up both of my monitors and swap parts until I figured out that:

1. The panel itself was still functional;
2. The power supply still outputs the correct voltage;
3. The motherboard couldn't output to the functional panel & functional power supply.

This is the motherboard in question:

<img src="/images/20211031_5.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="23es Motherboard"/>
<p class="text-center text-gray lh-condensed-ultra f6">23es Motherboard | Source: Me</p>

I bought the monitor in a sale for $150, which is an insanely good price because on Amazon, it costs about $250. However, because I have basic repair skills, I instead bought the motherboard on [Aliexpress](https://aliexpress.ru/item/1005002610876248.html?sku_id=12000021382193912&spm=a2g2w.productlist.0.0.2cf2f060HjY9rb) for $30.

Sure enough, swapping out the parts fixed the issue; however, seeing as how this (perfectly normal, cool-less) monitor's motherboard broke down after a mere 4 years of usage, the problem by and large is likely the humid yet dry environment the monitor is operating in, which causes wear and tear in its components. At the same time, I have an Acer monitor that has lived longer - hopefully, this was just a one-time fluke in the operating life expectancy of the HP 23es monitor.

---

# Ephemeral Windows 10 LiveCD

Windows is a widely used operating system used worldwide in various environments and settings. Hence, there are games and tools built specifically for Windows alone. Linux has many tools to try and bridge the gap between Windows applications and the Linux operating system, either by porting the application, building an alternative, using WINE, or optimizing virtual machines to run only for Windows applications.

The last option stated above has gotten _really_ good recently; by applying a technique known as [Single GPU passthrough](https://github.com/joeknock90/Single-GPU-Passthrough), Linux users can use applications that require hardware acceleration, most notably in video games or professional video editing software. However, this technique does not work on CPUs prior to Intel Broadwell, which is unfortunately exactly what I have on my [x220](/2019/05/01/thinkpad-x220/).

As an advocate of privacy, I love the concept of ephemeral runtimes: whatever changes done by any applications within an ephemeral runtime will not be committed to the system, which makes it simple to run "throwaway" applications should I only need them occasionally, rather than frequently. When I am done with the application, I can simply shutdown the system, and it was like I never used the application in the first place. Furthermore, it does not take up space in the harddrive like a traditional operating system would, meaning that I can have more space storing the files and application that affect my day-to-day life, which makes my setup more organized and purposeful.

Hence, I decided to create my own ephemeral Windows 10 LiveCD, using a tool called [Winbuilder](https://en.wikipedia.org/wiki/WinBuilder). To support 3D applications and as wide of an application spectrum as possible, I ensured that the following feaures were enabled:

- Logon as Administrator
- DirectX
- DotNet
- VC++ redistributable

Another consideration, when choosing which project to run within Winbuilder, is the difference between WinRE and WinPE. RE stands for Recovery Environment, while PE stands for Pre-installation Environment.

Even though WinRE is based on WinPE, WinPE loads network drivers and is a more complete environment compared to WinRE, which provides more recovery tools than operating system utility ([Toms' Guide](https://www.tomsguide.com/us/winpe-winre-bootable,review-1191-6.html)). Since what I need is essentially as complete of a Windows 10 environment as possible, the natural right answer is WinPE. Furthermore, in my testing, there were some applications that just refuses to run on WinRE, but runs perfectly fine on WinPE.

---

Happy Coding

CodingIndex
