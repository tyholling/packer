#!/bin/bash

[[ $# -ne 2 ]] && printf "usage: sudo ./provision.sh <hostname> <ip>\n" && exit

hostname="$1"
cd $hostname

../start.sh &
until [ -f .macaddress ]; do sleep 1; done
read mac_address < .macaddress

mac_reduced=$(echo $mac_address | perl -pe 's/0(\w)/\1/g')
until arp -an | grep -q " $mac_reduced "; do sleep 1; done

ip_address=$(arp -an | grep " $mac_reduced " | grep -o -m1 "192.168.64.\d\+")
ip_updated="$2"

sudo -u $SUDO_USER sh -c "
printf \"[centos]\n$hostname ansible_user=root ansible_host=$ip_address\n\n\" > .inventory
printf \"[centos:vars]\nansible_python_interpreter = auto_silent\n\" >> .inventory
printf \"ansible_ssh_common_args = '-o StrictHostKeyChecking=no'\n\" >> .inventory
ansible all -i .inventory -m wait_for_connection
ansible-playbook -i .inventory ../../ansible/static.yaml -e ip_address=$ip_updated
ansible-playbook -i .inventory ../../ansible/locale.yaml
ansible all -i .inventory -m hostname -a name=$hostname
ssh -l root $ip_address reboot
ssh-keygen -R $ip_address

sed -i -e 's/$ip_address/$ip_updated/' .inventory
ansible all -i .inventory -m wait_for_connection
ssh-keygen -R $ip_updated
"
arp -d $ip_address
printf '%-15s %s # %s\n' $ip_updated $hostname $mac_address >> /etc/hosts

sudo -u $SUDO_USER sh -c "
sed -i -e 's/ ansible_host=$ip_updated//' .inventory
ansible all -i .inventory -m wait_for_connection
"
