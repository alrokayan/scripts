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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./glusterfs-install.sh 192.168.0.2 192.168.0.3 192.168.0.4
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-install.sh | bash -s -- 192.168.0.2 192.168.0.3 192.168.0.4
# $1 Server1 IP
# $2 Server2 IP
# $3 Server3 IP
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <Server1 IP> <Server2 IP> <Server3 IP>"
    echo "EXAMPLE: $0 192.168.0.2 192.168.0.3 192.168.0.4"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will install glusterfs"
        exit 0
    fi
    exit 1
fi
apt install xfsprogs glusterfs-server glusterfs-client -y
systemctl enable glusterd
systemctl start glusterd
systemctl status glusterd -l --no-pager
gluster peer probe "$2"
gluster peer probe "$3"
gluster peer status
gluster pool list
gluster volume create gfs replica 3 arbiter 1 transport tcp \
  "$1":/mnt/gfs_disk/brick1 \
  "$2":/mnt/gfs_disk/brick1 \
  "$3":/mnt/gfs_disk/brick1 \
  force
gluster volume start gfs
gluster volume status
gluster volume info
