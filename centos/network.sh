#!/bin/bash

nmcli connection modify enp0s1 ipv4.addresses 192.168.64.2/24 ipv4.gateway 192.168.64.1 ipv4.method manual

reboot
