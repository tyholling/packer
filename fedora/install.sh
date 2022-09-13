#!/bin/bash

qemu-system-aarch64 \
-accel hvf \
-bios uefi.img \
-cdrom Fedora-Server-dvd-aarch64-36-1.5.iso \
-cpu host \
-drive file=fedora.img,format=qcow2 \
-m 8192 \
-machine virt,highmem=on \
-nic user \
-nographic \
-smp 8 \
;
