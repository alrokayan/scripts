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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./disk-restore-rootfs.sh /mnt/backup-rootfs/pi-rootfs.fsa /dev/sda
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/disk-backup-rootfs.sh | bash -s -- /mnt/backup-rootfs/pi-rootfs.fsa /dev/sda
# $1 Backup file
# $2 Disk with rootfs
if [ -z "$1" ] || [ -z "$2" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <backup-file> <disk-with-rootfs>"
    echo "EXAMPLE: $0 /mnt/backup-rootfs/pi-rootfs.fsa /dev/sda"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will restore a backed up rootfs to the disk."
        exit 0
    fi
    exit 1
fi
apt install fsarchiver -y
fsarchiver archinfo "$1"
fsarchiver restfs "$1" "id=0,dest=${2}1" "id=1,dest=${2}2"