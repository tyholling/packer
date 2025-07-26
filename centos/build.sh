#!/bin/bash -e

[ -z "$1" ] && set -- "centos"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d "dirs=stdin:?type=application/json" -f centos.pkr.hcl.tpl -o centos.pkr.hcl

if [ ! -f "CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM" ]; then
  axel https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM
fi
if [ ! -f "CentOS-Stream-10-latest-aarch64-dvd1.iso" ]; then
  axel https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso
fi

packer build centos.pkr.hcl
