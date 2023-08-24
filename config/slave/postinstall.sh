#!/bin/sh
sh $(dirname $0)/../../bin/reown $(dirname "$0") $1 $(whoami)
sh $(dirname $0)/../../bin/ensure-sshkey

systemctl disable dnsmasq hostapd
systemctl unmask dhcpcd networking
systemctl enable dhcpcd networking
