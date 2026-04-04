#!/bin/bash

[ -f .macaddress ] || {
  time=$(date +%s)
  while (( time )); do
    next=$(printf "%x" $(( time % 240 + 16 )))
    nums=($next ${nums[@]})
    time=$(( time / 240 ))
  done
  (IFS=:; echo "02:00:${nums[*]}" > .macaddress)
}
read macaddress < .macaddress

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-boot menu=on,splash-time=0 \
-cpu host \
-device virtio-net-device,netdev=net0,mac=$macaddress \
-device virtio-rng-device \
-device virtio-scsi-device \
-device scsi-hd,drive=disk \
-display none \
-drive file=fedora.img,if=none,format=raw,id=disk,cache=writethrough,discard=unmap \
-m 4096 \
-machine accel=hvf,highmem=on,type=virt \
-netdev vmnet-shared,id=net0,start-address=192.168.64.1,end-address=192.168.64.255,subnet-mask=255.255.255.0 \
-smp 4 \
;
