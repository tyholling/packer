#!/bin/bash -e

[ -z "$1" ] && set -- "fedora"

jq -cn '$ARGS.positional' --args $@ \
| gomplate -d 'dirs=stdin:?type=application/json' -f fedora.pkr.hcl.tpl > fedora.pkr.hcl

packer build fedora.pkr.hcl
