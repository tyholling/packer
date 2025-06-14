#!/bin/bash

[ -z "$1" ] && printf "usage: $0 hostname\n" && exit
hostname="$1"

packer build -force ubuntu.pkr.hcl

sudo ./start.sh &
until [ -f .macaddress ]; do sleep 1; done

macaddress=$(cat .macaddress | perl -pe 's/0(\w)/\1/g')
until arp -an | grep -q $macaddress; do sleep 1; done

ip_address=$(arp -an | grep $macaddress | grep -o -m1 "192.168.64.\d\+")
echo -e "[ubuntu]\n$ip_address ansible_user=root" > .inventory

ansible ubuntu -i .inventory -m wait_for_connection
ansible ubuntu -i .inventory -m hostname -a name=$hostname

ansible-playbook -l ubuntu -i .inventory ../ansible/script.yaml

ssh -l root $ip_address bash -s < kubelet.sh

echo "$ip_address $hostname" | sudo tee -a /etc/hosts
