---
title: "ZeroTier OpenVPN NAT - Part 1"
date: 2021-02-14 21:31 +08:00
categories: [openvpn, zerotier, decentralized]
tags: [openvpn, zerotier, decentralized]
published: true
---

Happy New Year :fireworks:! What, New Year was one month ago, and I've henceforth lost all right to celebrate it?

Well, as they (read: _I_) say, the day doesn't end until you go to sleep; and I've been awake for a really, _really_ long time :coffee:. Regardless of the late and obligatory greeting, my New Year's resolution is to deliver interesting blog posts every month of the year - let's hope I don't run out of unconventional ideas to blog about. Also, January doesn't count as a month.

Enjoy!

# Preface (Skippable)

[SKIP: I don't have the time, bring me to the next section :angry:](#goal)

Decentralized networks are quite interesting. Instead of a star-like topology like in traditional client-server models, decentralized networks are usually peer-to-peer (P2P), meaning they have a spider-web-like topology.

<img src="/images/20210214_1.svg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Star Model"/>
<p class="text-center text-gray lh-condensed-ultra f6">Traditional Client-Server Model | Source: <a href="https://en.wikipedia.org/wiki/Peer-to-peer">Wikipedia</a></p>

<img src="/images/20210214_2.svg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Spider-web Model"/>
<p class="text-center text-gray lh-condensed-ultra f6">Peer-to-Peer Model | Source: <a href="https://en.wikipedia.org/wiki/Peer-to-peer">Wikipedia</a></p>

There are many arguments online about which model is better than the other in terms of network performance, redundancy and host stability; you can read more about a standardized response to "Client-Server Model vs Peer-to-Peer model" [through this link](https://cio-wiki.org/wiki/Client_Server_Architecture#Advantages_and_Disadvantages_of_the_Client_Server_Architecture.5B7.5D).

In this decade, we saw the rise of Bitcoin, a cryptocurrency that uses Blockchain technology, as a decentralized payment alternative to standard bank transfers / credit card payments. Many began to ride on the bandwagon, inventing new cryptocurrencies, merging Blockchain technology with the supply chain, and applying the idea of decentralization into every nook and cranny of technology.

One such impacted technology is Virtual Private Networks (VPNs). Recently, the consumer definition of VPNs are "a more privacy oriented internet connection that can be used to bypass geological restrictions"; however, this is not the original purpose or definition of VPN. Instead, VPNs, by definition from [Cisco](https://www.cisco.com/c/en/us/products/security/vpn-endpoint-security-clients/what-is-vpn.html), are extensions of another network by making it available on the internet; a user can securely access the resources on a private network via a VPN service.

An advantage of accessing the private network over exposing the services to the internet is the battle-tested authentication & encryption tunnel created for the connection: no matter what protocol the services in the private network use, be it encrypted or not, they can all be securely accessed via a VPN tunnel over the network. Moreover, given a properly configured firewall for each host in the network, creating and hosting new services becomes a simple task, as private networks are implicitly trusted by many applications.

Before 2011, most users or corporates leveraged the power of (true) VPNs either by hosting it themselves, or via a managed decentralized P2P service like [LogMeIn Hamachi](https://en.wikipedia.org/wiki/LogMeIn_Hamachi); as a side-note reminiscing my past, Hamachi was one of the services I used frequently, as it was one of the easier ways to host a Minecraft server without port-forwarding. It is also worth it to note that Hamachi's selling point was not it's decentralization, but it's ability to create a VLAN. In 2011, a lesser-known alternative sprung up, known as [ZeroTier](https://www.zerotier.com/).

Unlike Hamachi, ZeroTier has less restrictions on the number of hosts per network (5 vs 50 at the time of writing), has Software-Defined Networking (i.e. something like kernel IPTables and iproute2), allowed for Full Bridging Mode (i.e. tunnel all internet connection to a host on the Software-Defiend network), and is mostly open-source; this means that the technology behind the core aspects of ZeroTier, such as using [STUN](https://en.wikipedia.org/wiki/STUN), [UDP Hole Punching](https://en.wikipedia.org/wiki/UDP_hole_punching), route discovery and tunnel encryption are under public scrutiny, which helps to create a more secure service. Moreover, ZeroTier is constantly evolving to become more decentralized; with the introduction of [Moons](https://www.zerotier.com/manual/#4_4), it is ZeroTier's aim to achieve infrastructure federation, i.e. little to no reliance on ZeroTier's root servers. In a nutshell, the main difference between Hamachi and ZeroTier is their emphasis on decentralization.

Personally, I believe that true decentralization can only occur when the community is heavily involved in the project; barring conspiracy, projects such as the [Tor Project](https://en.wikipedia.org/wiki/Tor_(network)) or [I2P](https://geti2p.net/en/) can only achieve their "freedom of internet via anonymity" goal through peer-hosted servers or clients. Hence, it makes sense for more users to jump aboard the decentralization train - so that we may ideally achieve a freer internet with less surveillance.

---

# Goal

On almost all of my devices (which includes one Single Board Computer akin to a Raspberry Pi), I have a VPN connection to a provider I trust, and an installation of ZeroTier. The VPN provider connects me to the internet, while ZeroTier gives me access to services on my VLAN; however, there are two main problems with this setup:

1. Android devices cannot dual-wield VPN connections; in other words, I cannot connect to my VPN provider and ZeroTier at the same time;
2. For _true_ decentralization & federation, this setup relies too much on UDP connectivity - despite being in 2021, several locations (universities, coffee shops) still block UDP connections.

As my goal is to achieve peak decentralization, **and** retain my VPN connection to my VPN provider, it falls on me to implement a solution that can combine the best of both worlds. Additionally, there are the following constraints:

1. I cannot port-forward. My solution must rely on resources most people can access; routers have subjective access levels for each individual. Moreover, dynamic IP addresses are a thing; any solution that requires the exposure of a service to the plain internet is out of the question.
2. One device. The solution must be implementable on a single device; money (and hence, resources) does not grow on trees.
3. Otherwise unaffecting. The solution must not disrupt the default gateways on the implemented devices; in other words, the device can still have plain internet access _alongside_ hosting whatever solution I implement.
4. Free. The solution cannot cost extra money.

These constraints will help make my solutions implementable across a wider audience, irregardless of how complex a given country's NAT systems or firewalls are. After racking my head for a bit, I came up with two possible solutions, but none of them perfectly mitigates the problems above; if you decide to implement them, read the text carefully.

> **NOTE**: For all the solutions, I'm assuming that the subnet for ZeroTier is `172.25.0.0/16`.

## Solution Uno

Solution Uno requires a device on your local LAN; a small Single Board Computer (SBC) is good enough. By some clever masquerade and manipulation of the Kernel IP Tables, it is possible to send all internet-bound connections from the ZeroTier adapter to an OpenVPN `tun` adapter. Hence, all one needs to do is to establish an OpenVPN connection to the VPN provider while ensuring it does not affect the route table (constraint #3), and create suitable entries in the route table to facilitate forwarding between ZeroTier and OpenVPN.

<img src="/images/20210214_3.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Device -> ZeroTier -> SBC -> OpenVPN -> OpenVPN Provider"/>
<p class="text-center text-gray lh-condensed-ultra f6">Architecture for Solution Uno | Source: Me</p>

Solution Uno's downside occurs when a network restricts UDP connectivity, and hence prevents ZeroTier from achieving P2P connections; the device will instead be using a root server as a relay, which docks some points in federation.

## Solution Duo

Cloud Computing providers fiercely compete with one another, offering unprecedented prices for infinite scalability, fault tolerance and availability. For non-business consumers like us, we benefit from the competition through the free-tier offerings; for Solution Duo, we utilize Oracle Cloud's "Always Free Tier", which allows us to have two `VM.Standard.E2.1.Micro` VMs for the low price of absolutely free.

<img src="/images/20210214_4.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Device -> OpenVPN -> Oracle Cloud VM -> OpenVPN -> OpenVPN Provider"/>
<p class="text-center text-gray lh-condensed-ultra f6">Architecture for Solution Duo | Source: Me</p>

By configuring an OpenVPN server and ZeroTier on an Oracle Cloud VM, it becomes possible to set up routes to forward packets to and fro the OpenVPN `tun` and ZeroTier adapter. Taking care not to disrupt the default gateway (constraint #3), an OpenVPN client connection can be established from within the VM, connecting to the VPN provider. In essence, an external device will be connecting to a OpenVPN proxy that also happens to route ZeroTier addresses.

The main downside of this approach is the connection speed; Oracle Cloud does not have datacenters in certain parts of the world, which may increase latency of any given VPN connection.

## Bonus: Solution Dinosaur

As a bonus solution (and if you have time), both Solution Uno and Solution Duo can be implemented together, forming something akin a multi-directional bridge. If the device has an unrestricted internet connection, and is also an Android device, then simply connecting to the ZeroTier network via the official Android app will connect it to both the VPN provider and the ZeroTier network. If you want to maximize federation, and the device has an internet connection that blocks UDP connections, then connecting to the Oracle Cloud VM via an OpenVPN app will also connect the device to both the VPN and the ZeroTier network.

<img src="/images/20210214_5.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Device -> OpenVPN -> Oracle Cloud VM -> ZeroTier -> SBC -> OpenVPN -> OpenVPN Provider"/>
<p class="text-center text-gray lh-condensed-ultra f6">Architecture for Solution Dinosaur | Source: Me</p>

While it is an abomination, I personally use this method. A more ideal solution would be to host a ZeroTier moon on Oracle Cloud, and then getting the device to orbit it, but such a feature is unavailable on Android at the time of writing.

> **NOTE**: There is a rumor that this feature will come in ZeroTier 2.0, according to this [Reddit post](https://www.reddit.com/r/zerotier/comments/d9xuv3/force_zerotier_client_to_only_use_your_own_moons/).

---

# Bookmark

I will implement all three solutions in different parts:

- [Part 2](/2021/02/14/zerotier-openvpn-nat-part-2) - Solution Uno
- [Part 3](/2021/02/14/zerotier-openvpn-nat-part-3) - Solution Duo
- [Part 4](/2021/02/14/zerotier-openvpn-nat-part-4) - Solution Dinosaur

You can bookmark [this link](#bookmark) to come back later.

---

# Conclusion

While decentralization is an important step forward for the internet, a large part of the world is still resisting those changes; by disrupting UDP connectivity, peer-to-peer connections are difficult, if not, impossible to establish, hindering the progress towards a freer and open internet.

I hope that by coming up with solutions to workaround these disruptions, we can bridge the missing gaps required to get everyone on decentralized networks, private or not.

This was a particularly long series of blog posts - if you find any mistakes in the posts, please tweet [@me](https://twitter.com/jameshi16).

Happy Coding

CodingIndex
