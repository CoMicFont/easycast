#!/bin/sh
sh $(dirname $0)/../../bin/reown $(dirname "$0") $1 $(whoami)
sh $(dirname $0)/../../bin/authorize-master-to-ssh

systemctl disable dnsmasq hostapd
systemctl unmask dhcpcd networking
systemctl enable dhcpcd networking
