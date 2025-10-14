#!/bin/bash -e

[ -z "$1" ] && set -- "centos"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d "dirs=stdin:?type=application/json" -f centos.pkr.hcl.tpl -o centos.pkr.hcl

if [ ! -f "CentOS-Stream-10-latest-aarch64-dvd1.iso.sha256" ]; then
  axel https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM
  cat CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM \
  | sed -n 's/^SHA256 (\(CentOS-Stream-10-latest-aarch64-dvd1.iso\)) = \([a-z0-9]\{64\}\)$/\2  \1/p' \
  > CentOS-Stream-10-latest-aarch64-dvd1.iso.sha256
  rm CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM
fi

if [ ! -f "CentOS-Stream-10-latest-aarch64-dvd1.iso" ]; then
  axel https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso
fi

packer build centos.pkr.hcl
