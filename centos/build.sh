#!/bin/bash -e

if [ ! -s "centos.iso.sha256" ]; then
  curl -LSfs -o centos.iso.sha256 \
  https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM

  sed -n -i '' -e 's/^SHA256 (CentOS-Stream-10-latest-aarch64-dvd1.iso) = \([a-z0-9]\{64\}\)$/\1  centos.iso/p' centos.iso.sha256
fi

if [ ! -s "centos.iso" ]; then
  axel -o centos.iso \
  https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso

  shasum -c centos.iso.sha256
fi

[ -s "centos.img" ] || packer build -force centos.pkr.hcl
