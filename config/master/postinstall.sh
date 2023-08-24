#!/bin/sh
sh $BASEDIR/../../bin/reown $(dirname "$0") $1 $(whoami)

systemctl disable networking
systemctl unmask hostapd dhcpcd dnsmasq
systemctl enable hostapd dhcpcd dnsmasq
