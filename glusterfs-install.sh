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
function createGFS {
    echo "GFS_VOLUME: ${GFS_VOLUME}"
    gluster volume create ${GFS_VOLUME} replica 3 arbiter 1 transport tcp \
    "$SERVER1_IP":/mnt/${GFS_VOLUME}_disk/brick \
    "$SERVER2_IP":/mnt/${GFS_VOLUME}_disk/brick \
    "$SERVER3_IP":/mnt/${GFS_VOLUME}_disk/brick \
    force
    gluster volume start ${GFS_VOLUME}
    systemctl stop glusterd
    cd /var/lib/glusterd/vols/${GFS_VOLUME}/ || exit
    mv "${GFS_VOLUME}.$SERVER1_IP.mnt-${GFS_VOLUME}_disk-brick.vol" "${GFS_VOLUME}.$SERVER1_NAME.mnt-${GFS_VOLUME}_disk-brick.vol"
    mv "${GFS_VOLUME}.$SERVER2_IP.mnt-${GFS_VOLUME}_disk-brick.vol" "${GFS_VOLUME}.$SERVER2_NAME.mnt-${GFS_VOLUME}_disk-brick.vol"
    mv "${GFS_VOLUME}.$SERVER3_IP.mnt-${GFS_VOLUME}_disk-brick.vol" "${GFS_VOLUME}.$SERVER3_NAME.mnt-${GFS_VOLUME}_disk-brick.vol"
    cd /var/lib/glusterd/vols/${GFS_VOLUME}/bricks || exit
    mv "$SERVER1_IP:-mnt-${GFS_VOLUME}_disk-brick" "$SERVER1_NAME:-mnt-${GFS_VOLUME}_disk-brick"
    mv "$SERVER2_IP:-mnt-${GFS_VOLUME}_disk-brick" "$SERVER2_NAME:-mnt-${GFS_VOLUME}_disk-brick"
    mv "$SERVER3_IP:-mnt-${GFS_VOLUME}_disk-brick" "$SERVER3_NAME:-mnt-${GFS_VOLUME}_disk-brick"
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
    gluster volume status
    gluster volume info
}
apt update -y
apt upgrade -y
apt install samba -y
apt install ctdb -y
cat << EOF > /var/lib/glusterd/groups/my-samba
cluster.self-heal-daemon=enable
performance.cache-invalidation=on
server.event-threads=4
client.event-threads=4
performance.parallel-readdir=on
performance.readdir-ahead=on
performance.nl-cache-timeout=600
performance.nl-cache=on
network.inode-lru-limit=200000
performance.md-cache-timeout=600
performance.stat-prefetch=on
performance.cache-samba-metadata=on
features.cache-invalidation-timeout=600
features.cache-invalidation=on
nfs.disable=on
user.smb=enable
cluster.data-self-heal=on
cluster.metadata-self-heal=on
cluster.entry-self-heal=on
cluster.force-migration=disable
EOF
SERVER1_IP=10.10.1.10
SERVER2_IP=10.10.1.11
SERVER3_IP=10.10.1.12
SERVER1_NAME=$(grep "$SERVER1_IP" /etc/hosts | awk '{print $2}')
SERVER2_NAME=$(grep "$SERVER2_IP" /etc/hosts | awk '{print $2}')
SERVER3_NAME=$(grep "$SERVER3_IP" /etc/hosts | awk '{print $2}')
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
gluster peer probe "$SERVER1_IP"
gluster peer probe "$SERVER2_IP"
gluster peer probe "$SERVER3_IP"
gluster peer status
gluster pool list
GFS_VOLUME="gfs"
createGFS
# gluster volume set ${GFS_VOLUME} group my-samba
# GFS_VOLUME="ctdb"
# sed -i 's/META="all"/META="ctdb"/g' /var/lib/glusterd/hooks/1/start/post/S29CTDBsetup.sh
# sed -i 's/META="all"/META="ctdb"/g' /var/lib/glusterd/hooks/1/stop/pre/S29CTDB-teardown.sh
# createGFS
# cat << EOF > /etc/ctdb/nodes
# $SERVER1_IP
# $SERVER2_IP
# $SERVER3_IP
# EOF
# cat << EOF > /etc/ctdb/public_addresses
# 10.10.1.10/16 eno1
# 10.10.1.11/16 eno1
# 10.10.1.12/16 eno1
# EOF
# sed -i '/CTDB_SAMBA_SKIP_SHARE_CHECK/d' /etc/ctdb/script.options
# echo 'CTDB_SAMBA_SKIP_SHARE_CHECK=yes' >> /etc/ctdb/script.options
# systemctl enable --now ctdb
# systemctl status ctdb -l --no-pager
# ctdb status
# ctdb ip
# ctdb ping
# cp /etc/samba/smb.conf /etc/samba/smb.conf.ORIGINAL
# cat << EOF >> /etc/samba/smb.conf
# kernel share modes = no
# kernel oplocks = no
# map archive = no
# map hidden = no
# map read only = no
# map system = no
# store dos attributes = yes
# EOF
# systemctl enable --now ctdb
# systemctl status ctdb -l --no-pager
# systemctl enable --now samba-ad-dc
# systemctl status samba-ad-dc -l --no-pager
