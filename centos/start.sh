#!/bin/bash

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-cpu host \
-device virtio-scsi-device \
-display none \
-drive file=centos.img,if=none,format=qcow2,id=disk \
-device scsi-hd,drive=disk,bootindex=0 \
-m 8192 \
-machine accel=hvf,highmem=on,type=virt \
-nic user,hostfwd=tcp::60322-:22 \
-nic vmnet-shared,mac=2:0:0:0:0:3 \
-smp 8 \
;
