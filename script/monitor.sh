#!/bin/bash

watch -ct -n1 '
cat ~/.ssh/known_hosts | awk "{ print \$1; }" | uniq | xargs && echo
pgrep qemu | xargs && echo
arp -an | grep 2:0: && echo
tail -n+5 /etc/hosts && echo
'
