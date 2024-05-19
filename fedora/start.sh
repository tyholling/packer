#!/bin/bash

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-cpu host \
-device virtio-scsi-device \
-device scsi-hd,drive=disk \
-display none \
-drive file=fedora.img,if=none,format=qcow2,id=disk \
-m 8192 \
-machine accel=hvf,highmem=on,type=virt \
-nic user,hostfwd=tcp::60622-:22 \
-smp 8 \
;
