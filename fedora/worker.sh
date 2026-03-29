#!/bin/bash

[ -f "worker.img" ] && exit || cp -cn fedora.img worker.img

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-boot menu=on,splash-time=0 \
-cpu host \
-device virtio-rng-device \
-device virtio-scsi-device \
-device scsi-hd,drive=disk \
-display none \
-drive file=worker.img,if=none,format=raw,id=disk \
-m 2048 \
-machine accel=hvf,highmem=on,type=virt \
-nic user,hostfwd=tcp::60422-:22 \
-smp 2 \
&

until ssh -q -l root -p 60422 localhost true; do sleep 1; done

ssh -l root -p 60422 localhost bash -s < kubelet.sh
scp -P 60422 crio-images.conf root@localhost:/etc/crio/crio.conf.d/50-registries.conf
scp -P 60422 crio-mirror.conf root@localhost:/etc/containers/registries.conf.d/crio.conf
ssh -l root -p 60422 localhost poweroff

ssh-keygen -R [localhost]:60422
