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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./glusterfs-install.sh 192.168.0.2 192.168.0.3 192.168.0.4 10.10.10.10/24 eth0 sdb
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-install.sh | bash -s --192.168.0.2 192.168.0.3 192.168.0.4 10.10.10.10/24 eth0 sdb
# $1 Server1 IP
# $2 Server2 IP
# $3 Server3 IP
# $4 SERVER PUBLIC IP WITH CIDR
# $5 NETWORK INTERFACE CARD FOR PUBLIC IPs
# $6 Disk (without /dev)
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
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
SERVER_IP_PUBLIC_CIDR=$4
NIC=$5
DISK=$6
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
    fi
}
cp /etc/samba/smb.conf /etc/samba/smb.conf.ORIGINAL
AddGlobalSMB='[global]\n    kernel share modes = no\n    kernel oplocks = no\n    map archive = no\n    map hidden = no\n    map read only = no\n    map system = no\n    store dos attributes = yes\n    clustering=yes'
sed -i "/\[global\]/c $AddGlobalSMB" /etc/samba/smb.conf
cat <<EOF >/var/lib/glusterd/groups/my-samba
cluster.self-heal-daemon=enable
cluster.data-self-heal=on
cluster.metadata-self-heal=on
cluster.entry-self-heal=on
cluster.force-migration=disable
performance.cache-invalidation=on
performance.parallel-readdir=on
performance.readdir-ahead=on
performance.nl-cache-timeout=600
performance.nl-cache=on
performance.md-cache-timeout=600
performance.stat-prefetch=on
performance.cache-samba-metadata=on
performance.write-behind=off
features.cache-invalidation-timeout=600
features.cache-invalidation=on
server.event-threads=4
client.event-threads=4
nfs.disable=on
user.smb=enable
user.cifs=enable
network.inode-lru-limit=200000
storage.batch-fsync-delay-usec=0
EOF
sed -i 's/META="all"/META="ctdb"/g' /var/lib/glusterd/hooks/1/start/post/S29CTDBsetup.sh
sed -i 's/META="all"/META="ctdb"/g' /var/lib/glusterd/hooks/1/stop/pre/S29CTDB-teardown.sh
cat <<EOF >/etc/ctdb/nodes
$SERVER1_IP
$SERVER2_IP
$SERVER3_IP
EOF
cat <<EOF >/etc/ctdb/public_addresses
$SERVER_IP_PUBLIC_CIDR $NIC
EOF
sed -i '/CTDB_SAMBA_SKIP_SHARE_CHECK/d' /etc/ctdb/script.options
echo 'CTDB_SAMBA_SKIP_SHARE_CHECK=yes' >>/etc/ctdb/script.options
gluster peer probe "$SERVER1_IP"
gluster peer probe "$SERVER2_IP"
gluster peer probe "$SERVER3_IP"
gluster peer status
gluster pool list

GFS_VOLUME="ctdb" && createGFS
GFS_VOLUME="gfs" && createGFS && gluster volume set ${GFS_VOLUME} group my-samba
gluster volume status
gluster volume info

apt update -y
apt upgrade -y
apt install ctdb -y
systemctl enable --now ctdb
systemctl status ctdb -l --no-pager
ctdb status
ctdb ip
ctdb ping
df -h /gluster/lock

apt update -y
apt upgrade -y
apt install samba -y
systemctl enable --now smbd
systemctl status smbd -l --no-pager
./scripts/glusterfs-client.sh
df -h /gfs
mkdir /gfs/smbshare
groupadd smbgroup
chgrp smbgroup /gfs/smbshare
usermod -aG smbgroup root
chmod 770 /gfs/smbshare
AddGFSSMB='[gluster-gfs]\n    writable = yes\n    valid users = @smbgroup\n    force create mode = 777\n    force directory mode = 777\n    inherit permissions = yes'
sed -i "/\[gluster-gfs\]/c $AddGFSSMB" /etc/samba/smb.conf
grep gluster-gfs /etc/samba/smb.conf
systemctl restart smbd
systemctl status smbd -l --no-pager
ufw allow samba
apt install smbclient cifs-utils -y
smbclient -L "$SERVER_IP_PUBLIC_CIDR" -U%
smbclient "//$SERVER_IP_PUBLIC_CIDR/gluster-gfs" -U root%M@jed2030











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
