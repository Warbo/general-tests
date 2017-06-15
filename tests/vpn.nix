{ helpers, pkgs }:
with pkgs;
runCommand "dummy" {} "exit 1"

/*
#!/usr/bin/env bash

# Bail out if we're not connected to Dundee Uni WiFi
if ! nmcli c show --active | grep "UoD" > /dev/null
then
    echo "Not on UoD_Wifi, so not checking VPN or samba"
    exit 0
fi

# Make sure we're on the VPN
if ! nmcli c show --active | grep "Dundee Computing" > /dev/null
then
    echo "Not on VPN" 1>&2
    exit 1
fi

# Make sure our Samba share is mounted
if ! mount | grep "Uni" > /dev/null
then
    echo "Samba share not mounted" 1>&2
    exit 1
fi
*/
