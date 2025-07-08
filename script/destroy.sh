#!/bin/bash -o pipefail

shopt -s nullglob

cd ..

for distro in centos debian fedora ubuntu; do
  pushd $distro > /dev/null
  for machine in */; do
    machine="${machine%/}"
    [ -d $machine ] && pushd $machine > /dev/null || continue
    ssh -q -l root $machine poweroff
    ssh-keygen -R $machine &> /dev/null
    if [ -f .macaddress ]; then
      sudo sed -i '' "/$(cat .macaddress)/d" /etc/hosts
    fi
    popd > /dev/null
    sudo rm -rf $machine
  done
  popd > /dev/null
done

while pgrep qemu | xargs; do sleep 1; done

[ -f /var/db/dhcpd_leases ] && sudo rm -i /var/db/dhcpd_leases
