#!/bin/bash

shopt -s nullglob

cd ..

for distro in centos debian fedora ubuntu; do
  pushd $distro > /dev/null
  for machine in */; do
    machine="${machine%/}"
    [ -f $machine/.delete ] && pushd $machine > /dev/null || {
      echo "skipped: $distro/$machine"
      continue
    }
    ssh -q -l root $machine poweroff
    ssh-keygen -R $machine &> /dev/null
    if [ -f .macaddress ]; then
      read macaddress < .macaddress
      sudo arp -d $(grep $macaddress /etc/hosts | awk '{ print $1 }') > /dev/null
      sudo sed -i '' "/$macaddress/d" /etc/hosts
    fi
    popd > /dev/null
    rm -rf $machine
    echo "deleted: $distro/$machine"
  done
  rm -f $distro.pkr.hcl
  popd > /dev/null
done
