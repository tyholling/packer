#!/bin/bash

[ $EUID -ne 0 ] && echo "error: root user required" && exit
[ ! -d "/opt/homebrew/opt/socket_vmnet" ] && echo "error: socket_vmnet not found" && exit

plist_dest="/Library/LaunchDaemons/socket_vmnet.bridged.en0.plist"
if [ -f $plist_dest ]; then
    launchctl bootout system $plist_dest
    rm -f $plist_dest
fi

rm -f /var/run/socket_vmnet.bridged.en0
