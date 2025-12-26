#!/bin/bash -e

[ -z "$1" ] && set -- "debian"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d "dirs=stdin:?type=application/json" -f debian.pkr.hcl.tpl -o debian.pkr.hcl

if [ ! -f "debian-13.2.0-arm64-DVD-1.iso.sha256" ]; then
  axel https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/SHA256SUMS
  cat SHA256SUMS \
  | sed -n 's/^\([a-z0-9]\{64\}\)  \(debian-13.2.0-arm64-DVD-1.iso\)$/\1  \2/p' \
  > debian-13.2.0-arm64-DVD-1.iso.sha256
  rm SHA256SUMS
fi

if [ ! -f "debian-13.2.0-arm64-DVD-1.iso" ]; then
  axel https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/debian-13.2.0-arm64-DVD-1.iso
fi

packer build debian.pkr.hcl
