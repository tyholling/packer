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
-device virtio-rng-device \
-device virtio-scsi-device \
-device scsi-hd,drive=disk \
-display none \
-drive file=centos.img,if=none,format=qcow2,id=disk \
-m 8192 \
-machine accel=hvf,highmem=on,type=virt \
-nic vmnet-shared,mac=$macaddress \
-smp 8 \
;
