#!/bin/bash

qemu-system-aarch64 \
-M virt,highmem=on \
-accel hvf \
-bios uefi.img \
-cdrom Fedora-Server-dvd-aarch64-36-1.5.iso \
-cpu host \
-device intel-hda \
-device hda-duplex \
-device qemu-xhci \
-device usb-kbd \
-device usb-tablet \
-device virtio-gpu-pci \
-display default,show-cursor=on \
-drive file=fedora.img,format=raw,if=virtio,cache=writethrough \
-m 8192 \
-nic user \
-smp 8 \
;
