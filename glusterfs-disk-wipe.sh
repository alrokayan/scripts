#!/bin/bash
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
