#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#  
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# HOW TO (Mac):
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./pi-enable-ssh.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/pi-enable-ssh.sh | bash -s
#
# HOW TO (Linux):
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./pi-enable-ssh.sh /dev/disk4s2
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/pi-enable-ssh.sh | bash -s -- /dev/disk4s2
# $1 Path to disk (only for Linux)
if [[ "$(uname -s)" == *"Darwin"* ]]; then
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will enable ssh in raspios disk"
        echo "For mac Download and install extFS for mac from https://www.paragon-software.com/us/home/extfs-mac/"
        exit 0
    fi
    echo " -- Mac OS detected"
    touch "/Volumes/bootfs/ssh" && ls -al "/Volumes/bootfs/ssh" && echo " -- ssh enabled successfully"
    echo "$HOME/.ssh/id_rsa.pub" >> /Volumes/rootfs/root/.ssh/authorized_keys
    cat /Volumes/rootfs/root/.ssh/authorized_keys
    sed -i '/#PermitRootLogin prohibit-password/c\PermitRootLogin yes' /Volumes/rootfs/etc/ssh/sshd_config
    sed -i '/PasswordAuthentication no/c\PasswordAuthentication yes' /Volumes/rootfs/etc/ssh/sshd_config
    sed -i '/#   StrictHostKeyChecking ask/c\    StrictHostKeyChecking no' /Volumes/rootfs/etc/ssh/ssh_config
    sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /Volumes/rootfs/etc/sysctl.conf
    sed -i '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' /Volumes/rootfs/etc/sysctl.conf
    sed -i '/#DefaultTimeoutStopSec=90s/c\DefaultTimeoutStopSec=10s' /Volumes/rootfs/etc/systemd/system.conf
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\"/&usbcore.autosuspend=-1 /' /Volumes/rootfs/etc/default/grub
    sed -i '/.*#DNSStubListener=.*/ c\DNSStubListener=no' /Volumes/rootfs/etc/systemd/resolved.conf
    echo " -- ssh configured successfully"
    sudo diskutil unmountDisk "$1"
    echo " -- Disk unmounted successfully"
fi
if [[ "$(uname -s)" == *"Linux"* ]]; then
    if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: $0 <path-to-disk>"
        echo "EXAMPLE: $0 /dev/disk4s2"
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            echo "This script will enable ssh in raspios disk"
            echo "For mac Download and install extFS for mac from https://www.paragon-software.com/us/home/extfs-mac/"
            exit 0
        fi
        exit 1
    fi
    echo " -- Linux OS detected" 
    TMP_MNT_PATH="/mnt/raspios"
    rmdir "$TMP_MNT_PATH"
    mkdir -p "$TMP_MNT_PATH"
    echo "-- Running: mount -t ext4 $1 $TMP_MNT_PATH"
    mount -t ext4 "$1" "$TMP_MNT_PATH" && echo " -- Disk mounted successfully" && touch "$TMP_MNT_PATH/ssh" && echo " -- ssh enabled successfully"
    echo "$HOME/.ssh/id_rsa.pub" >> $TMP_MNT_PATH/root/.ssh/authorized_keys
    cat $TMP_MNT_PATH/root/.ssh/authorized_keys
    sed -i '/#PermitRootLogin prohibit-password/c\PermitRootLogin yes' $TMP_MNT_PATH/etc/ssh/sshd_config
    sed -i '/PasswordAuthentication no/c\PasswordAuthentication yes' $TMP_MNT_PATH/etc/ssh/sshd_config
    sed -i '/#   StrictHostKeyChecking ask/c\    StrictHostKeyChecking no' $TMP_MNT_PATH/etc/ssh/ssh_config
    sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' $TMP_MNT_PATH/etc/sysctl.conf
    sed -i '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' $TMP_MNT_PATH/etc/sysctl.conf
    sed -i '/#DefaultTimeoutStopSec=90s/c\DefaultTimeoutStopSec=10s' $TMP_MNT_PATH/etc/systemd/system.conf
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\"/&usbcore.autosuspend=-1 /' $TMP_MNT_PATH/etc/default/grub
    sed -i '/.*#DNSStubListener=.*/ c\DNSStubListener=no' $TMP_MNT_PATH/etc/systemd/resolved.conf
    echo " -- ssh configured successfully"
    sudo umount -f -v "$1"
    echo " -- Disk unmounted successfully"

fi
for mount_point in $(df | grep -e "$1" | awk '{print $9}'); do
    echo " -- Unmounting $mount_point"
    sudo umount -f -v "$mount_point"
done
