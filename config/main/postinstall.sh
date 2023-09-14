#!/bin/sh
sh $(dirname $0)/../../bin/reown $(dirname "$0") $1 $(whoami)
su easycast -c "$(dirname $0)/../../bin/ensure-sshkey"
su easycast -c "$(dirname $0)/../../bin/authorize-self-to-ssh"

systemctl disable networking
systemctl unmask hostapd dhcpcd dnsmasq easycast easycast-config
systemctl enable hostapd dhcpcd dnsmasq easycast easycast-config
systemctl restart hostapd dhcpcd dnsmasq easycast easycast-config
