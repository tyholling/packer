#!/bin/bash -e

[ -z "$1" ] && set -- "debian"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d 'dirs=stdin:?type=application/json' -f debian.pkr.hcl.tpl -o debian.pkr.hcl

packer build debian.pkr.hcl
