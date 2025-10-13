#!/bin/bash

hostname=$1

cd ../$1
./build.sh $hostname
sudo ./provision.sh $hostname 254

ssh $hostname uptime

rm -rf $1.pkr.hcl
pushd $hostname > /dev/null
ssh -q -l root $hostname poweroff
ssh-keygen -R $hostname &> /dev/null
if [ -f .macaddress ]; then
  sudo sed -i '' "/$(cat .macaddress)/d" /etc/hosts
fi
popd > /dev/null
rm -rf $hostname
