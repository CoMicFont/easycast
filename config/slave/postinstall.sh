#!/bin/sh
sh $(dirname $0)/../../bin/reown $(dirname "$0") $1 $(whoami)

systemctl disable dnsmasq hostapd
systemctl unmask dhcpcd networking
systemctl enable dhcpcd networking
