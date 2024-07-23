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
#######################################
#######################################
######### FUNCTION binInstall #########
#######################################
#######################################
function ENABLE_CONFIG_SSH() {
    echo "-- ROOT_MNT_PATH: $ROOT_MNT_PATH"
    echo "-- BOOT_MNT_PATH: $BOOT_MNT_PATH"
    if ! df | grep -q "$ROOT_MNT_PATH" || ! df | grep -q "$BOOT_MNT_PATH" ; then
        echo " -- Disk is not mounted. Try to unplug and re-plug the disk"
        exit 1
    fi
    df -h | grep -E "$ROOT_MNT_PATH|$BOOT_MNT_PATH"
    touch "$BOOT_MNT_PATH/ssh" && echo " -- ssh enabled successfully"
    if ! [ -f "$BOOT_MNT_PATH/userconf" ]; then
        echo "-- Please enter the password for the root user"
        echo "root:$(openssl passwd -6)" > "$BOOT_MNT_PATH/userconf"
    fi
    echo "-- User configuration file ($BOOT_MNT_PATH/userconf) content: "
    cat "$BOOT_MNT_PATH/userconf"
    mkdir -p "$ROOT_MNT_PATH/root/.ssh"
    cat "$HOME/.ssh/id_rsa.pub" > $ROOT_MNT_PATH/root/.ssh/authorized_keys
    cat "$ROOT_MNT_PATH/root/.ssh/authorized_keys"
    sed -i.BACKUP 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "$ROOT_MNT_PATH/etc/ssh/sshd_config"
    grep "PermitRootLogin yes" "$ROOT_MNT_PATH/etc/ssh/sshd_config"
    sed -i.BACKUP 's/PasswordAuthentication no/PasswordAuthentication yes/' "$ROOT_MNT_PATH/etc/ssh/sshd_config"
    sed -i.BACKUP 's/#PasswordAuthentication yes/PasswordAuthentication yes/' "$ROOT_MNT_PATH/etc/ssh/sshd_config"
    grep "PasswordAuthentication yes" "$ROOT_MNT_PATH/etc/ssh/sshd_config"
    sed -i.BACKUP 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/' "$ROOT_MNT_PATH/etc/ssh/ssh_config"
    grep "StrictHostKeyChecking no" -B 14 "$ROOT_MNT_PATH/etc/ssh/ssh_config" 
    sed -i.BACKUP 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' "$ROOT_MNT_PATH/etc/sysctl.conf"
    grep "net.ipv4.ip_forward=1" "$ROOT_MNT_PATH/etc/sysctl.conf"
    sed -i.BACKUP 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/' "$ROOT_MNT_PATH/etc/sysctl.conf"
    grep "net.ipv6.conf.all.forwarding=1" "$ROOT_MNT_PATH/etc/sysctl.conf"
    sed -i.BACKUP 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=10s/' "$ROOT_MNT_PATH/etc/systemd/system.conf"
    grep "DefaultTimeoutStopSec=10s" "$ROOT_MNT_PATH/etc/systemd/system.conf"
    mkdir -p $ROOT_MNT_PATH/root/BACKED_FILES
    mv $ROOT_MNT_PATH/etc/ssh/sshd_config.BACKUP $ROOT_MNT_PATH/root/BACKED_FILES/
    mv $ROOT_MNT_PATH/etc/sysctl.conf.BACKUP $ROOT_MNT_PATH/root/BACKED_FILES/
    mv $ROOT_MNT_PATH/etc/systemd/system.conf.BACKUP $ROOT_MNT_PATH/root/BACKED_FILES/
    ls -al $ROOT_MNT_PATH/root/BACKED_FILES/
    echo " -- ssh configured successfully"
    sudo umount -f -v $ROOT_MNT_PATH
    sudo umount -f -v $BOOT_MNT_PATH
    if ! df -h | grep -E "$ROOT_MNT_PATH|$BOOT_MNT_PATH"; then
        echo " -- Disk unmounted successfully, you can UNPLUG the disk now"
    else
        echo " -- Disk failed to be unmounted"
    fi
}

if [[ "$(uname -s)" == *"Darwin"* ]]; then
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will enable ssh for raspeberry using it's pi disk"
        echo "For mac Download and install extFS for mac from https://www.paragon-software.com/us/home/extfs-mac/"
        exit 0
    fi
    echo " -- Mac OS detected"
    if ! openssl version | grep -q 'OpenSSL'; then
        echo " -- openssl is not installed"
        brew install openssl
    fi
    ROOT_MNT_PATH="/Volumes/rootfs"
    BOOT_MNT_PATH="/Volumes/bootfs"
    ENABLE_CONFIG_SSH
fi
if [[ "$(uname -s)" == *"Linux"* ]]; then
    if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: $0 <path-to-disk>"
        echo "EXAMPLE: $0 /dev/disk4"
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            echo "This script will enable ssh for raspeberry using it's pi disk"
            exit 0
        fi
        exit 1
    fi
    echo " -- Linux OS detected"
    ROOT_MNT_PATH="/mnt/rootfs"
    BOOT_MNT_PATH="/mnt/bootfs"
    umount -f $ROOT_MNT_PATH
    umount -f $BOOT_MNT_PATH
    rmdir "$ROOT_MNT_PATH"
    rmdir "$BOOT_MNT_PATH"
    mkdir -p "$ROOT_MNT_PATH"
    mkdir -p "$BOOT_MNT_PATH"
    echo "-- Running: mount -t ext4 ${1}s1 $BOOT_MNT_PATH"
    echo "-- Running: mount -t ext4 ${1}s2 $ROOT_MNT_PATH"
    mount -t ext4 "${1}s1" "$BOOT_MNT_PATH" && echo " -- Bootfs disk mounted successfully"
    mount -t ext4 "${1}s2" "$ROOT_MNT_PATH" && echo " -- Rootfs disk mounted successfully"
    ENABLE_CONFIG_SSH
fi
