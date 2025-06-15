#!/bin/bash

[ -z "$1" ] && printf "usage: $0 hostname\n" && exit
hostname="$1"

./start.sh &
until [ -f .macaddress ]; do sleep 1; done

macaddress=$(cat .macaddress | perl -pe 's/0(\w)/\1/g')
until arp -an | grep -q $macaddress; do sleep 1; done

ip_address=$(arp -an | grep $macaddress | grep -o -m1 "192.168.64.\d\+")
printf "%-15s %s\n" $ip_address $hostname | tee -a /etc/hosts > /dev/null
printf "[all]\n$hostname ansible_user=root\n" > .inventory

sudo -u $SUDO_USER sh -c "
ansible all -i .inventory -m wait_for_connection --ssh-common-args='-o StrictHostKeyChecking=no'
ansible all -i .inventory -m hostname -a name=$hostname
ansible-playbook -l $hostname -i .inventory ../ansible/script.yaml
"
