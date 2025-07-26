#!/bin/bash -e

[ -z "$1" ] && set -- "fedora"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d "dirs=stdin:?type=application/json" -f fedora.pkr.hcl.tpl -o fedora.pkr.hcl

if [ ! -f "Fedora-Server-42-1.1-aarch64-CHECKSUM" ]; then
  axel https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/aarch64/iso/Fedora-Server-42-1.1-aarch64-CHECKSUM
fi
if [ ! -f "Fedora-Server-dvd-aarch64-42-1.1.iso" ]; then
  axel https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/aarch64/iso/Fedora-Server-dvd-aarch64-42-1.1.iso
fi

packer build fedora.pkr.hcl
