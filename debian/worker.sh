#!/bin/bash

[ -f "worker.img" ] && exit || cp -cn debian.img worker.img

qemu-system-aarch64 \
-bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd \
-boot menu=on,splash-time=0 \
-cpu host \
-device virtio-net,netdev=net0 \
-device virtio-rng-device \
-device virtio-scsi-device \
-device scsi-hd,drive=disk \
-display none \
-drive file=worker.img,if=none,format=raw,id=disk,cache=writethrough \
-m 4096 \
-machine accel=hvf,highmem=on,type=virt \
-netdev user,id=net0,hostfwd=tcp::60322-:22 \
-smp 4 \
&

until ssh -q -l root -p 60322 localhost true; do sleep 1; done

ssh -l root -p 60322 localhost bash -s < kubelet.sh
scp -P 60322 crio-images.conf root@localhost:/etc/crio/crio.conf.d/50-registries.conf
scp -P 60322 crio-mirror.conf root@localhost:/etc/containers/registries.conf.d/crio.conf
ssh -l root -p 60322 localhost poweroff

ssh-keygen -R [localhost]:60322
