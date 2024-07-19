#!/bin/bash
# $1 Server1 IP
# $2 Server2 IP
# $3 Server3 IP
apt install xfsprogs glusterfs-server glusterfs-client -y
systemctl enable glusterd
systemctl start glusterd
systemctl status glusterd
gluster peer probe $2
gluster peer probe $3
gluster peer status
gluster pool list
gluster volume create gfs replica 3 arbiter 1 transport tcp \
  $1:/mnt/gfs_disk/brick1 \
  $2:/mnt/gfs_disk/brick1 \
  $3:/mnt/gfs_disk/brick1 \
  force
gluster volume start gfs
gluster volume status
gluster volume info
