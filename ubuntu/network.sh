#!/bin/bash

sed -i -e '3i\  renderer: NetworkManager' -e /dhcp4/s/true/false/ /etc/netplan/50-cloud-init.yaml

apt-get install -y network-manager

nmcli connection modify netplan-enp0s1 connection.id enp0s1 \
ipv4.addresses $1/24 ipv4.dns 192.168.64.1 ipv4.gateway 192.168.64.1 ipv4.method manual

nmcli connection up enp0s1

reboot
