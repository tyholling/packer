#!/bin/bash

cd $(dirname $0)/..

for machine in "$@"; do
  for distro in centos debian fedora ubuntu; do
    [[ -d $distro/$machine ]] && pushd $distro/$machine > /dev/null || continue
    ssh -q -l root -o ConnectTimeout=1 $machine poweroff
    if [[ -f .macaddress ]]; then
      read macaddress < .macaddress
      sudo arp -d $macaddress
      sudo sed -i -e "/$macaddress/d" /etc/hosts
    fi
    popd > /dev/null
    rm -rf $distro/$machine
    echo "deleted: $distro/$machine"
  done
  ssh-keygen -R $machine &> /dev/null
done
