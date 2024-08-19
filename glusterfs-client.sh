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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./glusterfs-client.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/glusterfs-client.sh | bash -s
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "This script will install glusterfs client"
    exit 1
fi
apt install -y glusterfs-client
umount /gfs -f 2>/dev/null
rm -rf /gfs
mkdir /gfs
echo "-- Mounting /gfs"
# sed -i '/glusterfs/d' /etc/fstab
# echo 'localhost:/gfs /gfs glusterfs defaults,_netdev 0 0' >> /etc/fstab
# mount -a
cat >"/etc/systemd/system/gfs.mount" <<EOF
[Unit]
Description=Mounting /gfs
Requires=network-online.target
After=glusterd.service
Wants=glusterd.service

[Mount]
RemainAfterExit=true
ExecStartPre=/usr/sbin/gluster volume list
ExecStart=/bin/mount -a -t glusterfs
Restart=always
RestartSec=3
TimeoutSec=10s
What=localhost:gfs
Where=/gfs
Type=glusterfs
Options=defaults,_netdev

[Install]
WantedBy=multi-user.target
EOF
touch /etc/systemd/system/gfs.automount
systemctl daemon-reload
systemctl enable --now "gfs.mount"
systemctl status "gfs.mount" -l --no-pager
ls -al /gfs
df -h | grep gfs
