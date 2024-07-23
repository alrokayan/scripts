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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./pi-enable-ssh.sh /Volumes/boot
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/pi-enable-ssh.sh | bash -s -- /Volumes/boot
#
# HOW TO (Linux):
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./pi-enable-ssh.sh /dev/disk4s2
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/pi-enable-ssh.sh | bash -s -- /dev/disk4s2
# $1 Path to disk
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <path-to-disk>"
    echo "Linux EXAMPLE: $0 /dev/disk4s2"
    echo "macOS EXAMPLE: $0 /Volumes/boot"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will enable ssh in raspios disk"
        echo "For mac Download and install extFS for mac from https://www.paragon-software.com/us/home/extfs-mac/"
        exit 0
    fi
    exit 1
fi
if [[ "$(uname -s)" == *"Darwin"* ]]; then
    echo " -- Mac OS detected"
    touch "$1/ssh" && ls -al "$1/ssh" && echo " -- ssh enabled successfully"
    sudo diskutil unmountDisk "$1"
fi
if [[ "$(uname -s)" == *"Linux"* ]]; then
    echo " -- Linux OS detected" 
    TMP_MNT_PATH="/Users/alrokayan/raspios"
    rmdir "$TMP_MNT_PATH"
    echo "-- Running: mount -t ext4 $1 $TMP_MNT_PATH"
    mount -t ext4 "$1" "$TMP_MNT_PATH" && echo " -- Disk mounted successfully" && touch "$TMP_MNT_PATH/ssh" && echo " -- ssh enabled successfully"
fi
for mount_point in $(df | grep -e "$1" | awk '{print $9}'); do
    echo " -- Unmounting $mount_point"
    sudo umount -f -v "$mount_point"
done
