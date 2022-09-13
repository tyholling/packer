#!/bin/bash

qemu-system-aarch64 \
-accel hvf \
-bios uefi.img \
-cpu host \
-drive file=fedora.img,format=qcow2 \
-m 8192 \
-machine virt,highmem=on \
-nic user,hostfwd=tcp::22-:22 \
-nographic \
-smp 8 \
;
