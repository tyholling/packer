#!/bin/bash

apt-get install -y network-manager

sed -i '/enp0s1/s/^/# /' /etc/network/interfaces

nmcli connection add type ethernet ifname enp0s1 con-name enp0s1 autoconnect yes ipv4.addresses 192.168.64.3/24 ipv4.gateway 192.168.64.1 ipv4.method manual

systemctl restart NetworkManager

nmcli connection up enp0s1

reboot
