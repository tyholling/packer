#!/bin/bash -e

[ -z "$1" ] && set -- "debian"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d "dirs=stdin:?type=application/json" -f debian.pkr.hcl.tpl -o debian.pkr.hcl

if [ ! -f "debian.iso.sha256" ]; then
  curl -Ls https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/SHA256SUMS \
  | sed -n 's/^\([a-z0-9]\{64\}\)  debian-13.3.0-arm64-DVD-1.iso$/\1  debian.iso/p' \
  > debian.iso.sha256
fi

if [ ! -f "debian.iso" ]; then
  axel -o debian.iso \
  https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/debian-13.3.0-arm64-DVD-1.iso

  shasum -c debian.iso.sha256
fi

packer build debian.pkr.hcl
rm debian.pkr.hcl
