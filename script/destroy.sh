#!/bin/bash

shopt -s nullglob

cd ..

for machine in "$@"; do
  for distro in centos debian fedora ubuntu; do
    [[ -d $distro/$machine ]] && pushd $distro/$machine > /dev/null || continue
    ssh -q -l root -o ConnectTimeout=1 $machine poweroff
    ssh-keygen -R $machine &> /dev/null
    if [[ -f .macaddress ]]; then
      read macaddress < .macaddress
      sudo arp -d $(grep $macaddress /etc/hosts | awk '{ print $1 }') > /dev/null
      sudo sed -i '' "/$macaddress/d" /etc/hosts
    fi
    popd > /dev/null
    rm -rf $distro/$machine
    echo "deleted: $distro/$machine"
  done
done
