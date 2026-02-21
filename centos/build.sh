#!/bin/bash -e -o pipefail

[ -f "centos.img" ] && exit

if [ ! -f "centos.iso.sha256" ]; then
  curl -Lfs https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM \
  | sed -n 's/^SHA256 (CentOS-Stream-10-latest-aarch64-dvd1.iso) = \([a-z0-9]\{64\}\)$/\1  centos.iso/p' \
  > centos.iso.sha256
fi

if [ ! -f "centos.iso" ]; then
  axel -o centos.iso \
  https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso

  shasum -c centos.iso.sha256
fi

packer build -force centos.pkr.hcl
