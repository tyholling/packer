#!/bin/bash

apt-get install -y network-manager

sed -i '/enp0s1/s/^/# /' /etc/network/interfaces

nmcli connection add type ethernet ifname enp0s1 con-name enp0s1 \
ipv4.addresses $1/24 ipv4.dns 192.168.64.1 ipv4.gateway 192.168.64.1 ipv4.method manual

systemctl restart NetworkManager

nmcli connection up enp0s1

reboot
