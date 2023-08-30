#!/bin/sh
sh $(dirname $0)/../../bin/reown $(dirname "$0") $1 $(whoami)
sh $(dirname $0)/../../bin/authorize-master-to-ssh

systemctl disable dnsmasq hostapd easycast
systemctl unmask dhcpcd networking easycast-config
systemctl enable dhcpcd networking easycast-config
systemctl restart dhcpcd networking easycast-config
