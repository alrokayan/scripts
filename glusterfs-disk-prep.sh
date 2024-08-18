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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./glusterfs-disk-prep.sh sdb
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-disk-prep.sh | bash -s -- sdb
# $1 Disk (without /dev) to wipe, xfs formate, and mount
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <disk to wipe>"
    echo "EXAMPLE: $0 sdb"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will wipe, format, and mount a disk for glusterfs"
        exit 0
    fi
    exit 1
fi
apt update -y
apt upgrade -y
apt install xfsprogs -y
DISK=$1
umount "/dev/$DISK" -f
sh -c "echo 'w' | sleep 1 | fdisk /dev/$DISK -w always -W always"
wipefs -a "/dev/$DISK"
mkfs.xfs "/dev/$DISK" -f
rm -rf "/mnt/gluster_disk_$DISK"
mkdir "/mnt/gluster_disk_$DISK"
echo "/dev/$DISK /mnt/gluster_disk_$DISK xfs defaults 1 2" >> /etc/fstab
systemctl daemon-reload
mount -a
mount | grep "/mnt/gluster_disk_$DISK"
GFS_VOLUME="gfs"
mkdir "/mnt/gluster_disk_$DISK/${GFS_VOLUME}_brick1"
mkdir "/mnt/gluster_disk_$DISK/${GFS_VOLUME}_brick2"
GFS_VOLUME="ctdb"
mkdir "/mnt/gluster_disk_$DISK/${GFS_VOLUME}_brick1"
df -h | grep "gluster_disk_$DISK"
apt install glusterfs-server -y
systemctl enable --now glusterd
systemctl status glusterd -l --no-pager