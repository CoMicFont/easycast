#!/bin/sh
sh $(dirname $0)/../../bin/reown $(dirname "$0") $1 $(whoami)
sh $(dirname $0)/../../bin/ensure-sshkey
sh $(dirname $0)/../../bin/authorize-self-to-ssh

systemctl disable networking
systemctl unmask hostapd dhcpcd dnsmasq
systemctl enable hostapd dhcpcd dnsmasq
systemctl restart hostapd dhcpcd dnsmasq
