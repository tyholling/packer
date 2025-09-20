#!/bin/bash

watch -ct -n1 '
cat ~/.ssh/known_hosts | awk "{ print \$1 }" | uniq | xargs && echo
pgrep qemu | xargs && echo
arp -an | grep 2:0: && echo
cat /etc/hosts | grep 02:00:
'
