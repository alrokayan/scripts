#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-client.sh | bash -s
apt install -y glusterfs-client
mkdir /gfs
echo "localhost:gfs /gfs glusterfs defaults,_netdev 0 0" >> /etc/fstab
mount -a