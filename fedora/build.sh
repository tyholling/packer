#!/bin/bash -e

[ -z "$1" ] && set -- "fedora"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d "dirs=stdin:?type=application/json" -f fedora.pkr.hcl.tpl -o fedora.pkr.hcl

if [ ! -f "Fedora-Server-dvd-aarch64-43-1.6.iso.sha256" ]; then
  axel https://download.fedoraproject.org/pub/fedora/linux/releases/43/Server/aarch64/iso/Fedora-Server-43-1.6-aarch64-CHECKSUM
  cat Fedora-Server-43-1.6-aarch64-CHECKSUM \
  | sed -n 's/^SHA256 (\(Fedora-Server-dvd-aarch64-43-1.6.iso\)) = \([a-z0-9]\{64\}\)$/\2  \1/p' \
  > Fedora-Server-dvd-aarch64-43-1.6.iso.sha256
  rm Fedora-Server-43-1.6-aarch64-CHECKSUM
fi

if [ ! -f "Fedora-Server-dvd-aarch64-43-1.6.iso" ]; then
  axel https://download.fedoraproject.org/pub/fedora/linux/releases/43/Server/aarch64/iso/Fedora-Server-dvd-aarch64-43-1.6.iso
fi

packer build fedora.pkr.hcl
