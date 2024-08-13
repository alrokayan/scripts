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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./umount-nfs.sh /nextcloud
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/umount-nfs.sh | bash -s -- /nextcloud
# $1 = Local mount point
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0  <Local mount point>"
    echo "EXAMPLE: $0 /nextcloud"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will unmount NFS server"
        exit 0
    fi
    exit 1
fi
SYSTEMD_ESCAPED_MOUNT_POINT=$(systemd-escape --path "$1")
echo "-- Unmounting: $1 ($SYSTEMD_ESCAPED_MOUNT_POINT)"
systemctl stop "$SYSTEMD_ESCAPED_MOUNT_POINT.mount"
systemctl disable "$SYSTEMD_ESCAPED_MOUNT_POINT.mount"
systemctl daemon-reload
rm -f "/etc/systemd/system/$SYSTEMD_ESCAPED_MOUNT_POINT.mount"
df -h | grep "$1"