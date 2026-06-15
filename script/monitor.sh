#!/bin/bash

watch -tx -n1 bash -c "
find * -name '*.img' -exec dirname {} \; | sort -u | xargs; echo
pgrep qemu | xargs; echo
pr -mt -w \$COLUMNS <(arp -an | grep -E -o '\(.*\) at 2:0:\S+') <(grep '#' /etc/hosts); echo
grep -v '#' ~/.ssh/known_hosts | awk '{ print \$1 }' | xargs
"
