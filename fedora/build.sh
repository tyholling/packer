#!/bin/bash -e

if [ ! -s "fedora.iso.sha256" ]; then
  curl -LSfs -o fedora.iso.sha256 \
  https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Server/aarch64/iso/Fedora-Server-44-1.7-aarch64-CHECKSUM

  sed -n -i '' -e 's/^SHA256 (Fedora-Server-dvd-aarch64-44-1.7.iso) = \([a-z0-9]\{64\}\)$/\1  fedora.iso/p' fedora.iso.sha256
fi

if [ ! -s "fedora.iso" ]; then
  axel -o fedora.iso \
  https://download.fedoraproject.org/pub/fedora/linux/releases/44/Server/aarch64/iso/Fedora-Server-dvd-aarch64-44-1.7.iso

  shasum -c fedora.iso.sha256
fi

[ -s "fedora.img" ] || packer build -force fedora.pkr.hcl
