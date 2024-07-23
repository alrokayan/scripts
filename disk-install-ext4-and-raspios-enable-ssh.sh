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
# HOW TO:
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./disk-install-ext4-and-raspios-enable-ssh.sh /dev/disk4
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/disk-install-ext4-and-raspios-enable-ssh.sh | bash -s -- /dev/disk4
# $1 Path to disk
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <path-to-disk>"
    echo "EXAMPLE: $0 /dev/disk4"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will enable ssh in raspios disk"
        echo "For mac you have to download and install MacFuse (https://osxfuse.github.io) or install via brew (brew install ext4fuse)"
        exit 0
    fi
    exit 1
fi
TMP_MNT_PATH="/Users/alrokayan/raspios"
diskutil unmountDisk "$1"
for mount_point in $(df | grep -e raspios | awk '{print $9}'); do
    echo " -- Unmounting $mount_point"
    umount -f -v "$mount_point"
done
df -h
if [[ "$(uname -s)" == *"Darwin"* ]]; then
    echo " -- Mac OS detected"
    EXT4FUSE_EXE="/opt/ext4fuse/ext4fuse"
    if ! [ -f "$EXT4FUSE_EXE" ]; then
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/alrokayan/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        brew install --cask macfuse
        brew install pkg-config
        EXT4FUSE_DIR_PATH="$(dirname "$EXT4FUSE_EXE")"
        rm -rf "$EXT4FUSE_DIR_PATH"
        mkdir -p "$EXT4FUSE_DIR_PATH"
        git clone https://github.com/gerard/ext4fuse.git "$EXT4FUSE_DIR_PATH"
        make -C "$EXT4FUSE_DIR_PATH"
    fi
    echo "-- Running: $EXT4FUSE_EXE $1 $TMP_MNT_PATH -o allow_other,uid=$(id -u),gid=$(id -g),force"
    rmdir "$TMP_MNT_PATH"
    mkdir "$TMP_MNT_PATH"
    $EXT4FUSE_EXE "$1" "$TMP_MNT_PATH" -o allow_other,uid="$(id -u)",gid="$(id -g)",force
fi
if [[ "$(uname -s)" == *"Linux"* ]]; then
    echo " -- Linux OS detected" 
    echo "-- Running: mount -t ext4 $1 $TMP_MNT_PATH"
    rmdir "$TMP_MNT_PATH"
    mount -t ext4 "$1" "$TMP_MNT_PATH"
fi
if df | grep "$TMP_MNT_PATH"; then
    echo " -- Disk mounted successfully"
    df -h
    touch "$TMP_MNT_PATH/ssh"
    ls -al "$TMP_MNT_PATH"
    diskutil unmountDisk "$1"
    for mount_point in $(df | grep -e raspios | awk '{print $9}'); do
        echo " -- Unmounting $mount_point"
        umount -f -v "$mount_point"
        rmdir "$TMP_MNT_PATH"
    done
    df -h
else
    echo " -- Error while mounting disk"
    exit 1
fi