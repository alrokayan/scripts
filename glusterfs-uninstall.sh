#!/bin/bash
umount /gfs
sed -i '/glusterfs/d' /etc/fstab
apt remove glusterfs-client -y

gluster volume stop gfs force
gluster volume delete gfs force
systemctl disable glusterd
systemctl stop glusterd

umount /mnt/gfs_disk
sed -i '/gfs_disk/d' /etc/fstab
apt remove glusterfs-server -y