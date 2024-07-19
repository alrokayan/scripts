#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-install.sh | bash -s -- 192.168.0.2 192.168.0.3 192.168.0.4
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
