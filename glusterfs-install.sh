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
function createGFS {
    echo "GFS_VOLUME: ${GFS_VOLUME}"
    echo "SERVER1_NAME: $SERVER1_NAME"
    echo "SERVER1_IP: $SERVER1_IP"
    gluster peer probe "$SERVER1_IP"
    gluster peer status
    gluster pool list
    gluster volume create ${GFS_VOLUME} replica 1 arbiter 1 transport tcp \
    "$SERVER1_IP":/mnt/${GFS_VOLUME}_disk/brick \
    force
    gluster volume start ${GFS_VOLUME}
    systemctl stop glusterd
    cd /var/lib/glusterd/vols/${GFS_VOLUME}/ || exit
    mv "${GFS_VOLUME}.$SERVER1_IP.mnt-${GFS_VOLUME}_disk-brick.vol" "${GFS_VOLUME}.$SERVER1_NAME.mnt-${GFS_VOLUME}_disk-brick.vol"
    cd /var/lib/glusterd/vols/${GFS_VOLUME}/bricks || exit
    mv "$SERVER1_IP:-mnt-${GFS_VOLUME}_disk-brick" "$SERVER1_NAME:-mnt-${GFS_VOLUME}_disk-brick"
    cd /var/lib/glusterd || exit
    find . -type f -exec sed -i "s/$SERVER1_IP/$SERVER1_NAME/g" {} \;
    grep -rnw . -e "$SERVER1_IP"
    grep -rnw . -e "$SERVER1_NAME"
    systemctl enable --now glusterd
    systemctl status glusterd -l --no-pager
    gluster volume set ${GFS_VOLUME} group my-samba
    gluster peer status
    gluster volume status ${GFS_VOLUME}
    gluster volume info ${GFS_VOLUME}
}
apt update -y
apt upgrade -y
apt install glusterfs-server glusterfs-client ctdb samba -y
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
systemctl enable --now glusterd
systemctl status glusterd -l --no-pager
GFS_VOLUME="gfs"
SERVER1_IP=$1
SERVER1_NAME=$(grep "$SERVER1_IP" /etc/hosts | awk '{print $2}')
createGFS
GFS_VOLUME="ctdb"
sed -i 's/META="all"/META="ctdb"/g' /var/lib/glusterd/hooks/1/start/post/S29CTDBsetup.sh
sed -i 's/META="all"/META="ctdb"/g' /var/lib/glusterd/hooks/1/stop/pre/S29CTDB-teardown.sh
createGFS

systemctl enable --now samba-ad-dc
systemctl status samba-ad-dc -l --no-pager
systemctl enable --now ctdb
systemctl status ctdb -l --no-pager


cat /etc/fstab | grep ctdb
ls -al /etc/sysconfig/ctdb