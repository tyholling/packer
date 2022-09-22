#!/bin/bash

qemu-system-aarch64 \
-bios uefi.img \
-cpu host \
-display none \
-drive file=fedora.img,format=qcow2 \
-m 8192 \
-machine type=virt,highmem=on,accel=hvf \
-nic user,hostfwd=tcp::22-:22 \
-smp 8 \
;
