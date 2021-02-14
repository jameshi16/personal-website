---
title: "ZeroTier OpenVPN NAT - Part 2"
date: 2021-02-14 21:29 +08:00
categories: [openvpn, zerotier, decentralized]
tags: [openvpn, zerotier, decentralized]
published: true
---

<img src="/images/20210214_3.png" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Architecture"/>
<p class="text-center text-gray lh-condensed-ultra f6">Uno Architecture</p>

[\<\< Take me back to Part 1](/2021/02/14/zerotier-openvpn-nat-part-1#bookmark)

In this part, we will be implementing Solution Uno. Solution Uno has the following main design goals:

- Connect from a device that can only have one VPN connection (like an Android device)
- Connect from a restricted device that only allows VPN configurations (like a ISP home router) 

# Step 0: Pre-requisites

You will need a low-powered host capable of hosting an OpenVPN Server and maintaining a ZeroTier connection, like a Single Board Computer. Preferably, you will want administrative privileges; this guide will assume that you've got your hands on a Raspberry Pi with some flavour of Linux installed, particularly, Debian/Ubuntu.

You will need administrative access to your ZeroTier network through ZeroTier Central or some equivalent (if you run your own controller).

# Step 1: Installing packages

```bash
curl -s https://install.zerotier.com | sudo bash
sudo apt-get -y install openvpn
```

After installing ZeroTier, configure it to join your network; a simple `sudo zerotier-cli join <networkID>` should do. Run:

```bash
sudo ip link | grep "zt"
```

Note down the full device name; it should look like this: `ztly52mmwy`.

# Step 2: Create files

In this step, we are going to create a SystemD unit file, and two scripts that the OpenVPN daemon will call when routes are being setup and torn down. If you are not using a flavour of Linux that uses SystemD, then adapt the files based on your favoured init system.

`/etc/systemd/system/zt2ovpn.service`:
```ini
[Unit]
Description=Binds ZeroTier tunnel to OpenVPN

[Service]
Type=simple
ExecStart=openvpn --cd /etc/openvpn/client --config <insert_vpn_conf_here>.conf --route-noexec --route-up /etc/openvpn/client/up-script.sh --route-pre-down /etc/openvpn/client/down-script.sh

[Install]
WantedBy=multi-user.target
```

Remember to replace `<insert_vpn_conf_here>.conf` with your VPN provider's configuration.

The most important part of this service is the command in the `ExecStart` directive:
```bash
openvpn --cd /etc/openvpn/client --config <insert_vpn_conf_here>.conf --route-noexec --route-up /etc/openvpn/client/up-script.sh --route-pre-down /etc/openvpn/client/down-script.sh
```

As long as there is some variant of this in the init system, the setup should work as expected. One peculiar flag you may notice is the `--route-noexec` flag; this flag prevents the VPN from writing to the route table. This is required to fulfill constraint #3, which states that the ZeroTier to OpenVPN tunnel should be otherwise unaffecting.

`/etc/openvpn/client/up-script.sh`:
```bash
#!/bin/bash

ZT_DEVICE="ztly52mmwy"
ZT_CIDR="172.25.0.0/16"

set -e

sysctl -w net.ipv4.ip_forward=1

touch /etc/iproute2/rt_tables.d/zt2ovpn.conf
echo "42069 zt2ovpn" > /etc/iproute2/rt_tables.d/zt2ovpn.conf

ip rule add from ${ZT_CIDR} table zt2ovpn
ip route add default via ${route_vpn_gateway} dev ${dev} table zt2ovpn
ip route add ${ZT_CIDR} dev ${ZT_DEVICE} table zt2ovpn

iptables -I INPUT -i ${ZT_DEVICE} -d 0.0.0.0/0 -j ACCEPT
iptables -I FORWARD -i ${ZT_DEVICE} -o ${dev} -d 0.0.0.0/0 -j ACCEPT
iptables -t nat -I POSTROUTING -o ${dev} -d 0.0.0.0/0 -j MASQUERADE
```
Edit `ZT_DEVICE` to whatever device name you've noted down in step 1, and `ZT_CIDR` to whatever you set in ZeroTier Central or equivalent.

This script will be executed by OpenVPN when a connection is up; since we told OpenVPN not to add routes, we have to do it manually in this script. The line `sysctl -w net.ipv4.ip_forward=1` enables IP forwarding on the system, which is required to forward packets between the ZeroTier adapter and the VPN tunnel. The next few lines adds a new route table effective only for `${ZT_CIDR}`: this is required as we do not want to affect the host system's routing, dictated by constraint #3. We set the default route to the VPN gateway, and properly route any connections to ZeroTier devices for the new table that we just created. The last few `iptables` lines essentially just accepts connections from the ZeroTier adapter, allow forwarding for that device, and allow any exiting connections to the OpenVPN tunnel adapter to be masqueraded.

For some systems, you may need to add a few lines to accept connections from the OpenVPN tunnel adapter:

(Optional addon for `/etc/openvpn/client/up-script.sh`)
```bash
iptables -I INPUT -i ${dev} -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -I FORWARD -i ${dev} -o ${ZT_DEVICE} -m state --state ESTABLISHED,RELATED -j ACCEPT
```

Next, create the down script.

`/etc/openvpn/client/down-script.sh`:
```bash
#!/bin/bash

ZT_DEVICE="ztly52mmwy"
ZT_CIDR="172.25.0.0/16"

ip rule delete from ${ZT_CIDR} table zt2ovpn
ip route delete default via ${route_vpn_gateway} dev ${dev} table zt2ovpn
ip route delete ${ZT_CIDR} dev ${ZT_DEVICE} table zt2ovpn

rm -f /etc/iproute2/rt_tables.d/zt2ovpn.conf

iptables -D INPUT -i ${ZT_DEVICE} -d 0.0.0.0/0 -j ACCEPT
iptables -D FORWARD -i ${ZT_DEVICE} -d 0.0.0.0/0 -j ACCEPT
iptables -t nat -D POSTROUTING -o ${dev} -d 0.0.0.0/0 -j MASQUERADE
```

The down script is essentially the opposite of the up script; it deletes the entries created by the up script. If you added the optional addons for `/etc/openvpn/client/up-script.sh`, then you may need these lines too:
```bash
iptables -D INPUT -i ${dev} -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -D FORWARD -i ${dev} -o ${ZT_DEVICE} -m state --state ESTABLISHED,RELATED -j ACCEPT
```

# Step 3: Enable & Start the service

Try starting the service with:
```bash
sudo systemctl daemon-reload
sudo systemctl start zt2ovpn
```

Hopefully, there would be no errors. If there are errors, then find out what they are:
```bash
sudo systemctl status zt2ovpn
sudo journalctl -u zt2ovpn -f
```

If everything is alright, enable the service to start it on system start:
```bash
sudo systemctl enable zt2ovpn
```

# Step 4: Add entry to ZeroTier Central (or equivalent)

Navigate to your network on ZeroTier, and add a Managed Route:

<img src="/images/20210214_6.png" style="max-width: 600px; width: 100%; margin: 0 auto; display: block;" alt="Adding a Managed Route"/>
<p class="text-center text-gray lh-condensed-ultra f6">Adding a Managed Route | Source: Me</p>

Under `(Via)` should be the IP address of the host (Single Board Computer) you are using; for me, it was `172.25.0.1`. Once done, click on Submit.

# Step 5: Testing

Now, test it on your devices. For any device with `zerotier-cli`, run:
```bash
sudo zerotier-cli set <networkId> allowDefault=1
```

For Android/iOS devices, find the "Route Via ZeroTier" option:
<img src="/images/20210214_7.jpg" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="Route Via ZeroTier"/>
<p class="text-center text-gray lh-condensed-ultra f6">Route Via ZeroTier option | Source: Me</p>

Check your IP address with your favourite method; if your VPN provider provides a way to check IP addresses, DNS and WebRTC leaks, use that instead.

# Conclusion

Congratulations! You've successfully set up Solution Uno. [Click here](/2021/02/14/zerotier-openvpn-nat-part-1#bookmark) to go back to Part 1; otherwise, if you are satisfied, then we're done here.

Happy Coding

CodingIndex
