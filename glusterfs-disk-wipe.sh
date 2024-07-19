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
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-disk-wipe.sh | bash -s -- /dev/sdb
# $1 Disk to wipe, xfs formate, and mount
DISK=$1
systemctl stop iptables
systemctl disable iptables
systemctl status iptables
apt install xfsprogs glusterfs-server glusterfs-client -y
systemctl enable glusterd
systemctl start glusterd
systemctl status glusterd
mkfs.xfs $DISK -f
wipefs -a $DISK
mkfs.xfs $DISK -f
mkdir /mnt/gfs_disk
echo "$DISK /mnt/gfs_disk xfs defaults 1 2" >> /etc/fstab
systemctl daemon-reload
mount -a
mount | grep mnt/gfs_disk
mkdir /mnt/gfs_disk/brick1
df
