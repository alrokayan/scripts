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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./glusterfs-install.sh 192.168.0.2 192.168.0.3 192.168.0.4
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-install.sh | bash -s -- 192.168.0.2 192.168.0.3 192.168.0.4
# $1 Server1 IP
# $2 Server2 IP
# $3 Server3 IP
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <Server1 IP> <Server2 IP> <Server3 IP>"
    echo "EXAMPLE: $0 192.168.0.2 192.168.0.3 192.168.0.4"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will install glusterfs"
        exit 0
    fi
    exit 1
fi
export SERVER1_IP=${1}
export SERVER2_IP=${2}
export SERVER3_IP=${3}
SERVER1_NAME=$(grep "$SERVER1_IP"/etc/hosts | awk '{print $2}')
export SERVER1_NAME
SERVER2_NAME=$(grep "$SERVER2_IP" /etc/hosts | awk '{print $2}')
export SERVER2_NAME
SERVER3_NAME=$(grep "$SERVER3_IP" /etc/hosts | awk '{print $2}')
export SERVER3_NAME
echo "SERVER1_NAME: $SERVER1_NAME"
echo "SERVER1_IP: $SERVER1_IP"
echo "SERVER2_NAME: $SERVER2_NAME"
echo "SERVER2_IP: $SERVER2_IP"
echo "SERVER3_NAME: $SERVER3_NAME"
echo "SERVER3_IP: $SERVER3_IP"
if [ -z "$SERVER1_NAME" ] || [ -z "$SERVER2_NAME" ] || [ -z "$SERVER3_NAME" ]; then
    echo "/etc/hosts does not contain the following IPs: $SERVER1_IP $SERVER2_IP $SERVER3_IP"
    exit 1
fi
apt install xfsprogs glusterfs-server glusterfs-client -y
systemctl enable --now glusterd
gluster peer probe "$SERVER2_IP"
gluster peer probe "$SERVER3_IP"
gluster peer status
gluster pool list
systemctl stop glusterd.service
cd /var/lib/glusterd/vols/gfs/ || exit
mv "gfs.$SERVER1_IP.mnt-gfs_disk-brick1.vol" "gfs.$SERVER1_NAME.mnt-gfs_disk-brick1.vol"
mv "gfs.$SERVER2_IP.mnt-gfs_disk-brick1.vol" "gfs.$SERVER2_NAME.mnt-gfs_disk-brick1.vol"
mv "gfs.$SERVER3_IP.mnt-gfs_disk-brick1.vol" "gfs.$SERVER3_NAME.mnt-gfs_disk-brick1.vol"
cd /var/lib/glusterd/vols/gfs/bricks || exit
mv "$SERVER1_IP:-mnt-gfs_disk-brick1" "$SERVER1_NAME:-mnt-gfs_disk-brick1"
mv "$SERVER2_IP:-mnt-gfs_disk-brick1" "$SERVER2_NAME:-mnt-gfs_disk-brick1"
mv "$SERVER3_IP:-mnt-gfs_disk-brick1" "$SERVER3_NAME:-mnt-gfs_disk-brick1"
cd /var/lib/glusterd || exit
find . -type f -exec sed -i "s/$SERVER1_IP/$SERVER1_NAME/g" {} \;
find . -type f -exec sed -i "s/$SERVER2_IP/$SERVER2_NAME/g" {} \;
find . -type f -exec sed -i "s/$SERVER3_IP/$SERVER3_NAME/g" {} \;
grep -rnw . -e "$SERVER1_IP"
grep -rnw . -e "$SERVER2_IP"
grep -rnw . -e "$SERVER3_IP"
systemctl enable --now glusterd
systemctl status glusterd -l --no-pager
gluster peer status
gluster volume create gfs replica 3 arbiter 1 transport tcp \
  "$SERVER1_IP":/mnt/gfs_disk/brick1 \
  "$SERVER2_IP":/mnt/gfs_disk/brick1 \
  "$SERVER3_IP":/mnt/gfs_disk/brick1 \
  force
gluster volume start gfs
gluster volume heal gfs full
gluster volume heal gfs info
gluster volume quota gfs enable
gluster volume status
gluster volume info
gluster volume status
gluster volume info

