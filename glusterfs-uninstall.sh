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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./glusterfs-uninstall.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-uninstall.sh | bash -s
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "This script will uninstall glusterfs"
    exit 1
fi
function removeGFS {
    systemctl disable "$GFS_VOLUME.mount"
    systemctl stop "$GFS_VOLUME.mount"
    systemctl status "$GFS_VOLUME.mount" -l --no-pager
    rm -f /etc/systemd/system/$GFS_VOLUME.mount
    systemctl daemon-reload
    umount -f "/$GFS_VOLUME" 2>/dev/null
    sh -c "echo 'y' | sleep 1 | gluster volume stop $GFS_VOLUME force"
    gluster volume delete $GFS_VOLUME force
}
GFS_VOLUME="gfs"
removeGFS
GFS_VOLUME="ctdb"
removeGFS
systemctl disable glusterd
systemctl stop glusterd
sed -i '/glusterfs/d' /etc/fstab
sed -i '/mnt/gluster_disk/d' /etc/fstab
umount -f "/mnt/gluster_disk_*"
apt purge glusterfs-client glusterfs-server ctdb samba -y
apt autoremove -y
rm -rf /var/lib/glusterd
rm -rf /var/lib/ctdb
rm -rf /var/lib/samba
rm -rf /etc/glusterfs
rm -rf /etc/ctdb
rm -rf /etc/samba