#!/bin/bash

qemu-system-aarch64 \
-bios uefi.img \
-cpu host \
-display none \
-drive file=fedora.img,format=qcow2 \
-m 8192 \
-machine accel=hvf,highmem=on,type=virt \
-nic user,hostfwd=tcp::22-:22 \
-smp 8 \
;
