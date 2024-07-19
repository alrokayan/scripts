#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-create-nfs-volume.sh | bash -s -- 10.0.0.1 /mnt/hdd/Nextcloud nextcloud
# $1 NFS SERVER
# $2 PATH
# $3 NAME
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=$1,rw,nfsvers=4  \
  --opt device=:$2 \
  $3