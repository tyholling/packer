#!/bin/bash

watch -t -n1 '
pgrep qemu | xargs && echo
arp -an | grep 2:0: && echo
cat /etc/hosts | grep 02:00:
'
