#!/bin/bash

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-cpu host \
-display none \
-drive file=fedora.img \
-m 8192 \
-machine accel=hvf,highmem=on,type=virt \
-nic vmnet-bridged,ifname=en1,mac=2:0:0:0:0:0 \
-smp 8 \
;
