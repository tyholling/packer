#!/bin/bash

function mac_address {
  sleep 2
  local time=$(date +%s) next nums=()
  while (( time )); do
    next=$(printf "%x" $(( time % 240 + 16 )))
    nums=($next ${nums[@]})
    time=$(( time / 240 ))
  done
  local IFS=:
  echo "02:00:${nums[*]}"
}

[ -s .macaddress0 ] || mac_address > .macaddress0
read macaddress0 < .macaddress0
[ -s .macaddress1 ] || mac_address > .macaddress1
read macaddress1 < .macaddress1

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-boot menu=on,splash-time=0 \
-cpu host \
-device virtio-net-device,netdev=net1,mac=$macaddress1 \
-device virtio-net-device,netdev=net0,mac=$macaddress0 \
-device virtio-rng-device \
-device virtio-scsi-device,hotplug=off,packed=on \
-device scsi-hd,drive=disk,physical_block_size=4096 \
-display none \
-drive file=fedora.img,if=none,format=raw,id=disk,cache=writethrough,discard=unmap \
-m 4096 \
-machine accel=hvf,highmem=on,type=virt \
-netdev vmnet-shared,id=net0,start-address=192.168.64.1,end-address=192.168.64.255,subnet-mask=255.255.255.0 \
-netdev vmnet-bridged,id=net1,ifname=en0 \
-smp 4 \
;
