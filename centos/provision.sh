#!/bin/bash

[ -z "$1" ] && printf "usage: $0 hostname\n" && exit
hostname="$1"

./start.sh &
until [ -f .macaddress ]; do sleep 1; done

mac_address=$(cat .macaddress)
mac_reduced=$(echo $mac_address | perl -pe 's/0(\w)/\1/g')
until arp -an | grep -q $mac_reduced; do sleep 1; done

ip_address=$(arp -an | grep $mac_reduced | grep -o -m1 "192.168.64.\d\+")
printf "%-15s %s # %s\n" $ip_address $hostname $mac_address | tee -a /etc/hosts > /dev/null
printf "[centos]\n$hostname ansible_user=root\n" > .inventory

sudo -u $SUDO_USER sh -c "
ansible centos -i .inventory -u root -m wait_for_connection --ssh-common-args='-o StrictHostKeyChecking=no'
ansible centos -i .inventory -u root -m hostname -a name=$hostname
ansible-playbook -l centos -i .inventory -u root ../ansible/script.yaml
ssh -l root $hostname bash -s < kubelet.sh
"
