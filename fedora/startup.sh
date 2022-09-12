#!/bin/bash

qemu-system-aarch64 \
-M virt,highmem=on \
-accel hvf \
-bios uefi.img \
-cpu host \
-drive file=fedora.img,format=raw,if=virtio,cache=writethrough \
-m 8192 \
-nic user,hostfwd=tcp::22-:22 \
-nographic \
-smp 8 \
;
