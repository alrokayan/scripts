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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./mount.sh 10.0.0.1 /mnt/hdd/Nextcloud /nextcloud
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/mount.sh | bash -s -- 10.0.0.1 /mnt/hdd/Nextcloud /nextcloud
# $1 = NFS server address
# $2 = NFS path
# $3 = Local mount point
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <NFS server address> <NFS path> <Local mount point>"
    echo "EXAMPLE: $0 10.0.0.1 /mnt/hdd/Nextcloud /nextcloud"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will mount NFS server"
        exit 0
    fi
    exit 1
fi
SYSTEMD_ESCAPED_MOUNT_POINT=$(systemd-escape --path "$3")
echo "-- Mounting: $1:$2 on $3 ($SYSTEMD_ESCAPED_MOUNT_POINT)" >&3
mkdir -p "$3"
cat >"/etc/systemd/system/$SYSTEMD_ESCAPED_MOUNT_POINT.mount" <<EOF
[Unit]
Description=Mount $2
Requires=rpcbind.service network-online.target
Wants=networking.service
#
# Replaces this line in fstab
#$1:$2   $3  nfs defaults,noatime,x-systemd.automount 0 0
#
[Mount]
What=$1:$2
Where=$3
Type=nfs
Options=defaults
TimeoutSec=30

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable "$SYSTEMD_ESCAPED_MOUNT_POINT.mount"
systemctl start "$SYSTEMD_ESCAPED_MOUNT_POINT.mount"
systemctl status "$SYSTEMD_ESCAPED_MOUNT_POINT.mount"
