#!/bin/bash -e

[[ $# -ne 2 ]] && printf "usage: sudo ./provision.sh <hostname> <ip>\n" && exit

hostname="$1"
sudo -u $SUDO_USER mkdir $hostname
cp fedora.img $hostname/
cd $hostname

../start.sh &
until [ -f .macaddress ]; do sleep 1; done
read mac_address < .macaddress

mac_reduced=$(echo $mac_address | perl -pe 's/0(\w)/\1/g')
until arp -an | grep -q " $mac_reduced "; do sleep 1; done

ip_address=$(arp -an | grep " $mac_reduced " | grep -o -m1 "192.168.64.\d\+")
ip_updated="$2"
printf '%-15s %s # %s\n' $ip_address $hostname $mac_address >> /etc/hosts

sudo -u $SUDO_USER sh -c "
export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
export ANSIBLE_HOST_PATTERN_MISMATCH=ignore

printf \"[_]\nfedora ansible_host=$hostname ansible_user=root\n\n[all:vars]\n\" > .inventory
printf \"ansible_python_interpreter = auto_silent\n\" >> .inventory
printf \"ansible_ssh_common_args = '-o StrictHostKeyChecking=no'\n\" >> .inventory

ansible all -i .inventory -m wait_for_connection
ansible-playbook -i .inventory ../../ansible/static.yaml -e ip_address=$ip_updated
ansible-playbook -i .inventory ../../ansible/locale.yaml
ansible all -i .inventory -m hostname -a name=$hostname
ssh -l root $hostname reboot

sudo sed -i -e '/$mac_address/s/.\{15\}/$(printf %-15s $ip_updated)/' /etc/hosts
ansible all -i .inventory -m wait_for_connection
"
arp -d $ip_address
