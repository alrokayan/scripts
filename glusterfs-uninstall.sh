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
    systemctl daemon-reload
    rm -f /etc/systemd/system/$GFS_VOLUME.mount
    umount "/$GFS_VOLUME" 2>/dev/null
    sed -i '/glusterfs/d' /etc/fstab
    sed -i '/\/mnt\/'"${GFS_VOLUME}"'_disk/d' /etc/fstab
    sh -c "echo 'y' | gluster volume stop $GFS_VOLUME force"
    gluster volume delete $GFS_VOLUME force
    umount "/mnt/${GFS_VOLUME}_disk"
    sed -i '/'"${GFS_VOLUME}_disk"'/d' /etc/fstab
}
GFS_VOLUME="gfs"
removeGFS
GFS_VOLUME="ctdb"
removeGFS
systemctl disable glusterd
systemctl stop glusterd
apt purge glusterfs-client glusterfs-server ctdb samba -y
apt autoremove -y
rm -rf /var/lib/glusterd
rm -rf /var/lib/ctdb
rm -rf /var/lib/samba
rm -rf /etc/glusterfs
rm -rf /etc/ctdb
rm -rf /etc/samba