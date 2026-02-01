#!/bin/bash -e

[ ! -f "fedora.img" ] || exit

if [ ! -f "fedora.iso.sha256" ]; then
  curl -Ls https://download.fedoraproject.org/pub/fedora/linux/releases/43/Server/aarch64/iso/Fedora-Server-43-1.6-aarch64-CHECKSUM \
  | sed -n 's/^SHA256 (Fedora-Server-dvd-aarch64-43-1.6.iso) = \([a-z0-9]\{64\}\)$/\1  fedora.iso/p' \
  > fedora.iso.sha256
fi

if [ ! -f "fedora.iso" ]; then
  axel -o fedora.iso \
  https://download.fedoraproject.org/pub/fedora/linux/releases/43/Server/aarch64/iso/Fedora-Server-dvd-aarch64-43-1.6.iso

  shasum -c fedora.iso.sha256
fi

packer build -force fedora.pkr.hcl
