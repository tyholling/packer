#!/bin/bash

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-cpu host \
-display none \
-drive file=ubuntu.img \
-m 8192 \
-machine accel=hvf,highmem=on,type=virt \
-nic vmnet-shared \
-smp 8 \
;
