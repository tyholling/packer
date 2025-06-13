#!/bin/bash

[ -f .macaddress ] || printf "0200%x\n" $(date +%s) | sed 's/../&:/g;s/:$//' > .macaddress
read macaddress < .macaddress

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-boot menu=on,splash-time=0 \
-cpu host \
-device virtio-rng-device \
-device virtio-scsi-device \
-device scsi-hd,drive=disk \
-display none \
-drive file=fedora.img,if=none,format=qcow2,id=disk \
-m 8192 \
-machine accel=hvf,highmem=on,type=virt \
-nic vmnet-shared,mac=$macaddress \
-smp 8 \
;
