#!/bin/bash

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-cpu host \
-daemonize \
-display none \
-drive file=fedora.img \
-m 8192 \
-machine accel=hvf,highmem=on,type=virt \
-nic vmnet-shared \
-smp 8 \
;
