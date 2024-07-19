#!/bin/bash
# $1 New hostname
old_hostname=$(cat /etc/hostname)
hostnamectl --no-ask-password hostname $1
sed -i 's/'$old_hostname'/'$1'/g' /etc/hosts
cat /etc/hosts
echo "-- Your new hostname is $(hostname)"
echo "-- Please restart your system to apply changes"
