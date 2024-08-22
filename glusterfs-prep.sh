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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/glusterfs-prep.sh 192.168.0.2 192.168.0.3 192.168.0.4 10.10.10.10/24 eth0 sdb
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-prep.sh | bash -s --192.168.0.2 192.168.0.3 192.168.0.4 10.10.10.10/24 eth0 sdb
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
        echo "This script will prepare host for glusterfs"
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
## TESTING VALUES
# SERVER1_IP=10.0.0.10
# SERVER2_IP=10.0.0.11
# SERVER3_IP=10.0.0.12
# SERVER_IP_PUBLIC_CIDR=10.10.10.10/16
# NIC=eno1
# DISK=sda
## Disk Prep
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
GFS_VOLUME="ctdb"
mkdir "/mnt/gluster_disk_$DISK/${GFS_VOLUME}_brick1"
df -h | grep "gluster_disk_$DISK"
## Install SAMBA, CTDB, GLUSTERFS
apt update -y
apt upgrade -y
apt install xfsprogs glusterfs-server glusterfs-client samba ctdb smbclient cifs-utils -y
## SAMBA Files Prep
cp /etc/samba/smb.conf /etc/samba/smb.conf.ORIGINAL
AddGlobalSMB='[global]\n    kernel share modes = no\n    kernel oplocks = no\n    map archive = no\n    map hidden = no\n    map read only = no\n    map system = no\n    store dos attributes = yes\n    clustering = yes'
sed -i "/\[global\]/c\ $AddGlobalSMB" /etc/samba/smb.conf
AddGFSSMB='[gluster-gfs]\n    writable = yes\n    valid users = @smbgroup\n    force create mode = 777\n    force directory mode = 777\n    inherit permissions = yes'
sed -i "/\[gluster-gfs\]/c $AddGFSSMB" /etc/samba/smb.conf
## CTDB Files Preps
cp /etc/ctdb/nodes /etc/ctdb/nodes.ORIGINAL
cp /etc/ctdb/public_addresses /etc/ctdb/public_addresses.ORIGINAL
cp /etc/ctdb/script.options /etc/ctdb/script.options.ORIGINAL
cp /etc/ctdb/ctdb.conf /etc/ctdb/ctdb.conf.ORIGINAL
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
AddCTDB='[cluster]\n        CTDB_SET_DeterministicIPs=1'
sed -i "/\[cluster\]/c $AddCTDB" /etc/ctdb/ctdb.conf
## Gluster Files Prerp
cp /var/lib/glusterd/groups/samba /var/lib/glusterd/groups/samba.ORIGINAL
cp /var/lib/glusterd/hooks/1/start/post/S29CTDBsetup.sh /var/lib/glusterd/hooks/1/start/post/S29CTDBsetup.sh.ORIGINAL
cp /var/lib/glusterd/hooks/1/stop/pre/S29CTDB-teardown.sh /var/lib/glusterd/hooks/1/stop/pre/S29CTDB-teardown.sh.ORIGINAL
cat <<EOF >/var/lib/glusterd/groups/samba
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
sed -i'' 's/META="all"/META="ctdb"/g' /var/lib/glusterd/hooks/1/start/post/S29CTDBsetup.sh
sed -i'' 's/META="all"/META="ctdb"/g' /var/lib/glusterd/hooks/1/stop/pre/S29CTDB-teardown.sh
## Enable ans Start
echo "pusing for 5 seconds" && sleep 5s
systemctl enable smbd
systemctl restart smbd
systemctl status smbd -l --no-pager
echo "pusing for 5 seconds" && sleep 5s
systemctl enable ctdb
systemctl restart ctdb
systemctl status ctdb -l --no-pager
echo "pusing for 5 seconds" && sleep 5s
systemctl enable glusterd
systemctl restart glusterd
systemctl status glusterd -l --no-pager
echo "pusing for 5 seconds" && sleep 5s
## Testing
echo "----- TESTING3 DISK -----"
df -h | grep "/mnt/gluster_disk_$DISK"
echo "----- TESTING1 CTDB -----"
ip a | grep "$SERVER_IP_PUBLIC_CIDR"
echo "----- TESTING2 CTDB -----"
df -h | grep /gluster/lock
echo "----- TESTING4 CTDB -----"
ctdb status
ctdb ip
ctdb ping
echo "----- TESTING5 CTDB -----"
systemctl status smbd -l --no-pager
systemctl status ctdb -l --no-pager
systemctl status glusterd -l --no-pager
