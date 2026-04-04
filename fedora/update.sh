#!/bin/bash

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-boot menu=on,splash-time=0 \
-cpu host \
-device virtio-net-device,netdev=net0 \
-device virtio-rng-device \
-device virtio-scsi-device \
-device scsi-hd,drive=disk \
-display none \
-drive file=fedora.img,if=none,format=raw,id=disk,cache=writethrough \
-m 4096 \
-machine accel=hvf,highmem=on,type=virt \
-netdev user,id=net0,hostfwd=tcp::60422-:22 \
-smp 4 \
&

until ssh -q -l root -p 60422 localhost true; do sleep 1; done

ssh -l root -p 60422 localhost "
dnf update -y
dnf autoremove -y
poweroff
"

ssh-keygen -R [localhost]:60422
