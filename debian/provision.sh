#!/bin/bash

[ -z "$1" ] && printf "usage: $0 hostname\n" && exit || hostname="$1"
cd $hostname

../start.sh &
until [ -f .macaddress ]; do sleep 1; done
read mac_address < .macaddress

mac_reduced=$(echo $mac_address | perl -pe 's/0(\w)/\1/g')
until arp -an | grep -q " $mac_reduced "; do sleep 1; done

ip_address=$(arp -an | grep " $mac_reduced " | grep -o -m1 "192.168.64.\d\+")
ip_updated="192.168.64.$2"

sudo -u $SUDO_USER sh -c "
printf \"[debian]\n$hostname ansible_host=$ip_address ansible_user=root\n\" > .inventory
ansible all -i .inventory -m wait_for_connection --ssh-common-args='-o StrictHostKeyChecking=no'
ansible-playbook -i .inventory ../../ansible/static.yaml -e ip_address=$ip_updated
ssh -l root $ip_address reboot
ssh-keygen -R $ip_address

printf \"[debian]\n$hostname ansible_host=$ip_updated ansible_user=root\n\" > .inventory
ansible all -i .inventory -m wait_for_connection --ssh-common-args='-o StrictHostKeyChecking=no'
ansible all -i .inventory -m hostname -a name=$hostname
ansible-playbook -i .inventory ../../ansible/locale.yaml
ansible-playbook -i .inventory ../../ansible/update.yaml
ssh-keygen -R $ip_updated
"
arp -d $ip_address
printf "%-15s %s # %s\n" $ip_updated $hostname $mac_address >> /etc/hosts
