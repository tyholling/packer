#!/bin/bash

watch -t -n1 bash -c '"
pgrep qemu | xargs && echo
pr -mt -w $COLUMNS <(arp -an | grep 2:0:) <(cat /etc/hosts | grep 02:00:)
"'
