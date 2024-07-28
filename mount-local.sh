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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./mount-local.sh exfat /dev/sdX /nextcloud
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/mount-local.sh | bash -s -- exfat /dev/sdX /nextcloud
# $1 = Disk formate
# $2 = Disk path
# $3 = Local mount point
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <Disk formate> <Disk path> <Local mount point>"
    echo "EXAMPLE: $0 exfat /dev/sdX /nextcloud"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will mount local attached disk server"
        exit 0
    fi
    exit 1
fi
if [ "$1" == "exfat" ]; then
    echo "-- Installing exfat-utils and exfat-fuse"
    apt install "exfat-utils" "exfat-fuse"  -y
fi
if [ "$1" == "xfs" ]; then
    echo "-- Installing xfsprogs"
    apt install "xfsprogs" -y
fi
if [ "$1" == "zfs" ]; then
    echo "-- zfsutils-linux"
    apt install "zfsutils-linux" -y
fi
MOUNT_STRING="$2    $3    $1    defaults    0  0"
echo "-- MOUNT_STRING: $MOUNT_STRING"
if grep -e "$MOUNT_STRING" /etc/fstab; then
    echo "-- $MOUNT_STRING already exist in /etc/fstab"
else
    echo "-- Updating /etc/fstab with MOUNT_STRING"
    echo "$MOUNT_STRING" >> /etc/fstab
fi
cat /etc/fstab
mount -a