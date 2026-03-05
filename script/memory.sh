#!/bin/bash

echo

for s in $@; do
  ssh $s 'hostnamectl | grep -Pio "system: \K.*"; free -h'
  echo
done
