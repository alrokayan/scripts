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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./backup.tar.gz.sh /mnt/hdd/Backups /mnt/nvme/kube-volumes
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/backup.tar.gz.sh | bash -s -- /mnt/hdd/Backups /mnt/nvme/kube-volumes
# $1 Backup folder path
# $2 Target path to backup
# if -h or --help is passed as an argument, print the following help message
if [ -z "$1" ] || [ -z "$2" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <backup folder path> <target path to backup>"
    echo "EXAMPLE: $0 /mnt/hdd/Backups /mnt/nvme/kube-volumes"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will backup the target path to the backup folder path"
        exit 0
    fi
    exit 1
fi
DATE_FOLDER=$(date +%Y_%m_%d)
DATATIME_FILE="$(date +%Y_%m_%d-%H-%M-%S)"
BACKUP_PATH=$1
TARGET=$2
mkdir -p "$BACKUP_PATH/$DATE_FOLDER"
tar --exclude='**/MediaCover/*' \
    --exclude='**/.cache/*' \
    --exclude='**/.gnupg/*' \
    --exclude='**/logs/*' \
    --exclude='*.log' \
    --exclude='*.sock' \
    --exclude='**/plex/config/Library' \
    --exclude='**/kasm/data' \
    -Pcpzf "$BACKUP_PATH/$DATE_FOLDER/$TARGET/$DATATIME_FILE.tar.gz" \
    "$TARGET"
rm -rf "$(find "$BACKUP_PATH" -maxdepth 1 -type d -ctime +30)"
