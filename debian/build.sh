#!/bin/bash -e

if [ ! -s "debian.iso.sha256" ]; then
  curl -LOSfs https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/SHA256SUMS
  cp SHA256SUMS debian.iso.sha256

  sed -n -i '' -e 's/^\([a-z0-9]\{64\}\)  debian-.*-arm64-DVD-1.iso$/\1  debian.iso/p' debian.iso.sha256
fi

if [ ! -s "debian.iso" ]; then
  axel -o debian.iso \
  https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/$(grep 'DVD-1.iso' SHA256SUMS | awk '{ print $2 }')

  shasum -c debian.iso.sha256
fi

[ -s "debian.img" ] || packer build -force debian.pkr.hcl
