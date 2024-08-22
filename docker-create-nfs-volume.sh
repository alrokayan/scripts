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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/docker-create-nfs-volume.sh 10.0.0.1 /mnt/hdd/Nextcloud nextcloud
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-create-nfs-volume.sh | bash -s -- 10.0.0.1 /mnt/hdd/Nextcloud nextcloud
# $1 NFS SERVER
# $2 PATH
# $3 NAME
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <NFS SERVER> <PATH> <NAME>"
    echo "EXAMPLE: $0 10.0.0.1 /mnt/hdd/Nextcloud nextcloud"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will create a docker volume using NFS"
        exit 0
    fi
    exit 1
fi
docker volume create --driver local \
  --opt type=nfs \
  --opt "o=addr=$1,rw,nfsvers=4"  \
  --opt "device=:$2" \
  "$3"