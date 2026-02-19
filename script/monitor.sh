#!/bin/bash

watch -t -n1 bash -c '"
pgrep -d\" \" qemu && echo
pr -mt -w \\$COLUMNS <(arp -an | grep 2:0:) <(grep 02:00: /etc/hosts)
echo && cat ~/.ssh/known_hosts
"'
