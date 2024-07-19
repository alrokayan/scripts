#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/hostname.sh | bash -s -- NEWHOSTNAME
# $1 New hostname
old_hostname=$(cat /etc/hostname)
hostnamectl --no-ask-password hostname $1
sed -i 's/'$old_hostname'/'$1'/g' /etc/hosts
cat /etc/hosts
echo "-- Your new hostname is $(hostname)"
echo "-- Please restart your system to apply changes"
