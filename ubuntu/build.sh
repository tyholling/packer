#!/bin/bash -e

[ -z "$1" ] && set -- "ubuntu"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d "dirs=stdin:?type=application/json" -f ubuntu.pkr.hcl.tpl -o ubuntu.pkr.hcl

if [ ! -f "ubuntu-25.10-live-server-arm64.iso.sha256" ]; then
  axel https://cdimage.ubuntu.com/releases/25.10/release/SHA256SUMS
  cat SHA256SUMS \
  | sed -n 's/^\([a-z0-9]\{64\}\) \*\(ubuntu-25.10-live-server-arm64.iso\)$/\1  \2/p' \
  > ubuntu-25.10-live-server-arm64.iso.sha256
  rm SHA256SUMS
fi

if [ ! -f "ubuntu-25.10-live-server-arm64.iso" ]; then
  axel https://cdimage.ubuntu.com/releases/25.10/release/ubuntu-25.10-live-server-arm64.iso
fi

packer build ubuntu.pkr.hcl
rm ubuntu.pkr.hcl
