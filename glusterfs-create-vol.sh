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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/glusterfs-create-vol.sh 192.168.0.2 192.168.0.3 192.168.0.4 sdb
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-create-vol.sh | bash -s --192.168.0.2 192.168.0.3 192.168.0.4 sdb
# $1 Server1 IP
# $2 Server2 IP
# $3 Server3 IP
# $4 Disk (without /dev)
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <Server1 IP> <Server2 IP> <Server3 IP> <Server Public IP with CIDR> <Network Interface Card> <Disk to wipe>"
    echo "EXAMPLE: $0 192.168.0.2 192.168.0.3 192.168.0.4 10.10.10.10/24 eth0 sdb"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will install glusterfs"
        exit 0
    fi
    exit 1
fi
SERVER1_IP=$1
SERVER2_IP=$2
SERVER3_IP=$3
DISK=$4
function createGFS() {
    echo "GFS_VOLUME: ${GFS_VOLUME}"
    if ! gluster volume info ${GFS_VOLUME} &>/dev/null; then
        echo "Creating and starting ${GFS_VOLUME} volume"
        gluster volume create ${GFS_VOLUME} replica 3 \
            "$SERVER1_IP:/mnt/gluster_disk_$DISK/${GFS_VOLUME}_brick1" \
            "$SERVER2_IP:/mnt/gluster_disk_$DISK/${GFS_VOLUME}_brick1" \
            "$SERVER3_IP:/mnt/gluster_disk_$DISK/${GFS_VOLUME}_brick1" \
            force
        gluster volume start ${GFS_VOLUME}
        gluster volume set ${GFS_VOLUME} group my-samba
    fi
    gluster volume status ${GFS_VOLUME}
    gluster volume info ${GFS_VOLUME}
}
gluster peer probe "$SERVER1_IP"
gluster peer probe "$SERVER2_IP"
gluster peer probe "$SERVER3_IP"
gluster peer status && gluster pool list
GFS_VOLUME="ctdb" && createGFS
GFS_VOLUME="gfs" && createGFS
systemctl restart smbd
systemctl restart ctdb
systemctl restart glusterd
systemctl status smbd -l --no-pager
systemctl status ctdb -l --no-pager
systemctl status glusterd -l --no-pager












# umount -f /gfs
# rmdir /gfs
# mkdir -p /gfs
# mount -t glusterfs localhost:/gfs /gfs
# df -h /gfs
# mkdir /gfs/smbshare
# groupadd smbgroup
# chgrp smbgroup /gfs/smbshare
# usermod -aG smbgroup root
# chmod 770 /gfs/smbshare
# umount -f /gfs

# systemctl stop glusterd
# cd /var/lib/glusterd/vols/${GFS_VOLUME}/ || exit
# mv "${GFS_VOLUME}.$SERVER1_IP.mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1.vol" "${GFS_VOLUME}.$SERVER1_NAME.mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1.vol"
# mv "${GFS_VOLUME}.$SERVER2_IP.mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1.vol" "${GFS_VOLUME}.$SERVER2_NAME.mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1.vol"
# mv "${GFS_VOLUME}.$SERVER3_IP.mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1.vol" "${GFS_VOLUME}.$SERVER3_NAME.mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1.vol"
# cd /var/lib/glusterd/vols/${GFS_VOLUME}/bricks || exit
# mv "$SERVER1_IP:-mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1" "$SERVER1_NAME:-mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1"
# mv "$SERVER2_IP:-mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1" "$SERVER2_NAME:-mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1"
# mv "$SERVER3_IP:-mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1" "$SERVER3_NAME:-mnt-gluster_disk_$DISK-${GFS_VOLUME}_brick1"
# cd /var/lib/glusterd || exit
# find . -type f -exec sed -i "s/$SERVER1_IP/$SERVER1_NAME/g" {} \;
# find . -type f -exec sed -i "s/$SERVER2_IP/$SERVER2_NAME/g" {} \;
# find . -type f -exec sed -i "s/$SERVER3_IP/$SERVER3_NAME/g" {} \;
# grep -rnw . -e "$SERVER1_IP"
# grep -rnw . -e "$SERVER2_IP"
# grep -rnw . -e "$SERVER3_IP"
# systemctl start glusterd
