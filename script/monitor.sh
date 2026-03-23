#!/bin/bash

watch -tx -n1 bash -c "
pgrep qemu | xargs; echo
pr -mt -w \$COLUMNS <(arp -an | grep -E -o '.* 2:0:\S+') <(grep 02:00: /etc/hosts); echo
grep -v '#' ~/.ssh/known_hosts | awk '{ print \$1 }' | xargs
"
