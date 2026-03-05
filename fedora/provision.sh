#!/bin/bash

hostname="${1:-fedora}"
image="${2:-fedora.img}"

sudo -u $SUDO_USER mkdir $hostname
cp -cn $image $hostname/fedora.img
cd $hostname

../start.sh &
until [ -f .macaddress ]; do sleep 1; done
read mac_address < .macaddress

mac_reduced=$(echo $mac_address | perl -pe 's/0(\w)/\1/g')
until arp -an | grep -q " $mac_reduced "; do sleep 1; done

ip_address=$(arp -an | grep " $mac_reduced " | grep -o -m1 "192.168.64.\d\+")
flock /etc/hosts printf '%-15s %s # %s\n' $ip_address $hostname $mac_address >> /etc/hosts

export ANSIBLE_HOST_PATTERN_MISMATCH=ignore

sudo -E -u $SUDO_USER sh -c "
printf \"[_]\nfedora ansible_host=$hostname ansible_user=root\n\n[all:vars]\n\" > .inventory
printf \"ansible_python_interpreter = auto_silent\n\" >> .inventory
printf \"ansible_ssh_common_args = '-o StrictHostKeyChecking=no'\n\" >> .inventory
ansible all -i .inventory -m wait_for_connection
ansible-playbook -i .inventory ../../ansible/locale.yaml
"

[ -z "$3" ] && exit
ip_updated="$3"

sudo -E -u $SUDO_USER sh -c "
ansible-playbook -i .inventory ../../ansible/static.yaml -e ip_address=$ip_updated
ansible all -i .inventory -m hostname -a name=$hostname
ssh -l root $hostname reboot
"

flock /etc/hosts sed -i -e "/$mac_address/s/.\{15\}/$(printf %-15s $ip_updated)/" /etc/hosts
sudo -u $SUDO_USER sh -c "ansible all -i .inventory -m wait_for_connection"
