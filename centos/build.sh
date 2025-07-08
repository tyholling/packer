#!/bin/bash -e

[ -z "$1" ] && set -- "centos"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d 'dirs=stdin:?type=application/json' -f centos.pkr.hcl.tpl > centos.pkr.hcl

packer build centos.pkr.hcl
