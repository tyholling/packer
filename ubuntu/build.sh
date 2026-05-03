#!/bin/bash -e -o pipefail

[ -f "ubuntu.img" ] && exit

if [ ! -f "ubuntu.iso.sha256" ]; then
  curl -Lfs https://cdimage.ubuntu.com/releases/26.04/release/SHA256SUMS \
  | sed -n 's/^\([a-z0-9]\{64\}\) \*ubuntu-26.04-live-server-arm64.iso$/\1  ubuntu.iso/p' \
  > ubuntu.iso.sha256
fi

if [ ! -f "ubuntu.iso" ]; then
  axel -o ubuntu.iso \
  https://cdimage.ubuntu.com/releases/26.04/release/ubuntu-26.04-live-server-arm64.iso

  shasum -c ubuntu.iso.sha256
fi

packer build -force ubuntu.pkr.hcl
