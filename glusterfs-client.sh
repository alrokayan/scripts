#!/bin/bash
apt install -y glusterfs-client
mkdir /gfs
echo "localhost:gfs /gfs glusterfs defaults,_netdev 0 0" >> /etc/fstab
mount -a