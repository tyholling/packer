#!/bin/bash

hostname="${1:-debian}"
image="${2:-debian.img}"

mkdir $hostname
cp -cn $image $hostname/debian.img
cd $hostname

../start.sh &
until [ -s .macaddress ]; do sleep 1; done
read mac_address < .macaddress

mac_reduced=$(echo $mac_address | perl -pe 's/0(\w)/\1/g')
until arp -an | grep -q " $mac_reduced "; do sleep 1; done

ip_address=$(arp -an | sed -E -n "/ $mac_reduced /s/.*\(([0-9.]{7,})\).*/\1/p")
printf '%-15s %s # %s\n' $ip_address $hostname $mac_address | sudo tee -a /etc/hosts

export ANSIBLE_HOST_PATTERN_MISMATCH=ignore

printf "[_]\ndebian ansible_host=$hostname ansible_user=root\n\n[all:vars]\n" > .inventory
printf "ansible_python_interpreter = /usr/bin/python3\n" >> .inventory
printf "ansible_ssh_common_args = '-o StrictHostKeyChecking=no'\n" >> .inventory
ansible all -i .inventory -m wait_for_connection
ansible-playbook -i .inventory ../../ansible/locale.yaml

[ -z "$3" ] && exit
ip_updated="$3"

ansible-playbook -i .inventory ../../ansible/static.yaml -e ip_address=$ip_updated
ansible all -i .inventory -m hostname -a name=$hostname
ssh -l root $hostname reboot || true

sudo sed -i -e "/$mac_address/s/.\{15\}/$(printf %-15s $ip_updated)/" /etc/hosts
ansible all -i .inventory -m wait_for_connection

sudo arp -d $ip_address
