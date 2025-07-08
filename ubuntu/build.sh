#!/bin/bash -e

[ -z "$1" ] && set -- "ubuntu"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d 'dirs=stdin:?type=application/json' -f ubuntu.pkr.hcl.tpl -o ubuntu.pkr.hcl

packer build ubuntu.pkr.hcl
