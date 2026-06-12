#!/bin/bash

[ $EUID -ne 0 ] && echo "error: root user required" && exit
[ ! -d "/opt/homebrew/opt/socket_vmnet" ] && echo "error: socket_vmnet not found" && exit

plist_path="/opt/homebrew/opt/socket_vmnet/share/doc/socket_vmnet/launchd"
plist_name="io.github.lima-vm.socket_vmnet.bridged.en0"
plist_dest="/Library/LaunchDaemons/socket_vmnet.bridged.en0.plist"

if [ ! -f "$plist_dest" ]; then
    cp "$plist_path/$plist_name.plist" $plist_dest
    sed -i '' -e 's|/opt/socket_vmnet/bin|/opt/homebrew/opt/socket_vmnet/bin|g' $plist_dest
    launchctl bootstrap system $plist_dest
    launchctl enable "system/$plist_name"
fi

launchctl kickstart -k "system/$plist_name"
printf "waiting for socket: "

socket="/var/run/socket_vmnet.bridged.en0"
until [ -S $socket ]; do sleep 1; done
[ -S $socket ] && echo ready && exit || echo error
echo

launchctl print "system/$plist_name"
