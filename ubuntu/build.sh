#!/bin/bash -e

if [ ! -s "ubuntu.iso.sha256" ]; then
  curl -LSfs -o ubuntu.iso.sha256 \
  https://cdimage.ubuntu.com/releases/26.04/release/SHA256SUMS

  sed -n -i '' -e 's/^\([a-z0-9]\{64\}\) \*ubuntu-26.04-live-server-arm64.iso$/\1  ubuntu.iso/p' ubuntu.iso.sha256
fi

if [ ! -s "ubuntu.iso" ]; then
  axel -o ubuntu.iso \
  https://cdimage.ubuntu.com/releases/26.04/release/ubuntu-26.04-live-server-arm64.iso

  shasum -c ubuntu.iso.sha256
fi

[ -s "ubuntu.img" ] || packer build -force ubuntu.pkr.hcl
