#!/bin/bash

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-boot menu=on,splash-time=0 \
-cpu host \
-device virtio-rng-device \
-device virtio-scsi-device \
-device scsi-hd,drive=disk \
-display none \
-drive file=ubuntu.img,if=none,format=raw,id=disk \
-m 2048 \
-machine accel=hvf,highmem=on,type=virt \
-nic user,hostfwd=tcp::60522-:22 \
-smp 2 \
&

until ssh -q -l root -p 60522 localhost true; do sleep 1; done

ssh -l root -p 60522 localhost "
apt-get update -y
apt-get upgrade -y
apt-get autoremove -y
poweroff
"

ssh-keygen -R [localhost]:60522
