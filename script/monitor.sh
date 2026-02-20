#!/bin/bash

watch -tx -n1 bash -c "
pgrep qemu | xargs; echo
pr -mt -w \$COLUMNS <(arp -an | grep 2:0:) <(grep 02:00: /etc/hosts); echo
awk '{ print \$1 }' ~/.ssh/known_hosts | xargs
"
