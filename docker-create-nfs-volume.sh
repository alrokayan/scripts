#!/bin/bash
# $1 NFS SERVER
# $2 PATH
# $3 NAME
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=$1,rw,nfsvers=4  \
  --opt device=:$2 \
  $3