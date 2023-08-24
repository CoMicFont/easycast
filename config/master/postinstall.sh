#!/bin/sh
sh $(dirname $0)/../../bin/reown $(dirname "$0") $1 $(whoami)
sh $(dirname $0)/../../bin/ensure-sshkey
su pi -c 'cp /home/pi/.ssh/id_ed25519.pub /home/pi/.ssh/authorized_keys'

systemctl disable networking
systemctl unmask hostapd dhcpcd dnsmasq
systemctl enable hostapd dhcpcd dnsmasq
systemctl restart hostapd dhcpcd dnsmasq
