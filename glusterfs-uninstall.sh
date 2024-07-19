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

# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-uninstall.sh | bash -s
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