#!/bin/bash -e

[ -z "$1" ] && set -- "ubuntu"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d "dirs=stdin:?type=application/json" -f ubuntu.pkr.hcl.tpl -o ubuntu.pkr.hcl

if [ ! -f "ubuntu.iso.sha256" ]; then
  curl -Ls https://cdimage.ubuntu.com/releases/25.10/release/SHA256SUMS \
  | sed -n 's/^\([a-z0-9]\{64\}\) \*ubuntu-25.10-live-server-arm64.iso$/\1  ubuntu.iso/p' \
  > ubuntu.iso.sha256
fi

if [ ! -f "ubuntu.iso" ]; then
  axel -o ubuntu.iso \
  https://cdimage.ubuntu.com/releases/25.10/release/ubuntu-25.10-live-server-arm64.iso

  shasum -c ubuntu.iso.sha256
fi

packer build ubuntu.pkr.hcl
rm ubuntu.pkr.hcl
