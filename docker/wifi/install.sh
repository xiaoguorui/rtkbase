#----------------------------------------------------
cd / &&
git clone https://github.com/jancelin/rtkbase.git

#wifi
apt-get install -y dnsmasq hostapd bridge-utils 
cp /rtkbase/docker/wifi/NetworkManager.conf /etc/NetworkManager/
cp /rtkbase/docker/wifi/dhcpcd.conf /etc
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig 
cp /rtkbase/docker/wifi/dnsmasq.conf /etc
cp /rtkbase/docker/wifi/hostapd.conf /etc/hostapd
cp /rtkbase/docker/wifi/hostapd /etc/default
cp /rtkbase/docker/wifi/sysctl.conf /etc
mv /etc/iptables.ipv4.nat /etc/iptables.ipv4.nat.orig
cp /rtkbase/docker/wifi/iptables.ipv4.nat /etc
cp /rtkbase/docker/wifi/rc.local /etc
chmod +x  /etc/rc.local 
brctl addbr br0 
brctl addif br0 eth0 
cp /rtkbase/docker/wifi/bridge-br0.netdev /etc/systemd/network/
cp /rtkbase/docker/wifi/bridge-br0-slave.network /etc/systemd/network/
cp /rtkbase/docker/wifi/bridge-br0.network /etc/systemd/network/

#disable resolved.service for dnsmasq
systemctl disable systemd-resolved.service 
systemctl stop systemd-resolved.service 
rm /etc/resolv.conf 
#----------------------------------------------------

$ cat  /etc/resolv.conf
# Generated by dhcpcd from eth0.dhcp
# /etc/resolv.conf.head can replace this line
nameserver 192.168.1.1
# /etc/resolv.conf.tail can replace this line

https://it.izero.fr/linux-remplacer-resolver-dns-systemd-resolved-par-dnsmasq/
https://wiki.debian.org/dnsmasq
https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md

apt-get update && \
sudo systemctl disable systemd-resolved.service && sudo systemctl stop systemd-resolved.service && \
sudo rm /etc/resolv.conf && \
sudo apt install -y dnsmasq hostapd && \

sudo nano /etc/NetworkManager/NetworkManager.conf

[main]
dns=dnsmasq


sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

sudo nano /etc/dhcpcd.conf

interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
denyinterfaces wlan0
denyinterfaces eth0


sudo service dhcpcd restart

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo nano /etc/dnsmasq.conf

interface=wlan0      # Use the require wireless interface - usually wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h

sudo systemctl start dnsmasq
sudo systemctl reload dnsmasq

sudo nano /etc/hostapd/hostapd.conf

interface=wlan0
bridge=br0
driver=nl80211
ssid=Centipede
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=centipede
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

sudo nano /etc/default/hostapd

DAEMON_CONF="/etc/hostapd/hostapd.conf"

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd

sudo nano /etc/sysctl.conf

net.ipv4.ip_forward=1

sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERAD


sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"


sudo nano /etc/rc.local


#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
iptables-restore < /etc/iptables.ipv4.nat  
exit 0

sudo apt install -y hostapd bridge-utils

sudo brctl addbr br0

sudo brctl addif br0 eth0

sudo nano /etc/systemd/network/bridge-br0.netdev

[NetDev]
Name=br0
Kind=bridge

sudo nano /etc/systemd/network/bridge-br0-slave.network


[Match]
Name=eth0

[Network]
Bridge=br0

sudo nano /etc/systemd/network/bridge-br0.network

[Match]
Name=br0

[Network]
Address=192.168.10.100/24
Gateway=192.168.10.1
DNS=8.8.8.8


sudo systemctl restart systemd-networkd



