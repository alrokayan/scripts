#!/bin/sh
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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/chroot-start.sh /root
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/chroot-start.sh | bash -s -- /root
# $1 rootfs parent folder
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <rootfs parent folder>"
    echo "EXAMPLE: $0 /root"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will start chroot environment"
        exit 0
    fi
    exit 1
fi
ROOTFS_PARENT_FOLDER=$1
if mount | awk '{if ($3 == "'"$ROOTFS_PARENT_FOLDER"'/rootfs/dev") { exit 0}} ENDFILE{exit -1}'; then
    echo "$ROOTFS_PARENT_FOLDER/rootfs/dev/ already mounted"
else
    mount -o bind /dev "$ROOTFS_PARENT_FOLDER/rootfs/dev/"
fi

if mount | awk '{if ($3 == "'"$ROOTFS_PARENT_FOLDER"'/rootfs/proc") { exit 0}} ENDFILE{exit -1}'; then
    echo "$ROOTFS_PARENT_FOLDER/rootfs/proc/ already mounted"
else
    mount -t proc none "$ROOTFS_PARENT_FOLDER/rootfs/proc/"
fi

if mount | awk '{if ($3 == "'"$ROOTFS_PARENT_FOLDER"'/rootfs/sys") { exit 0}} ENDFILE{exit -1}'; then
    echo "$ROOTFS_PARENT_FOLDER/rootfs/sys already mounted"
else
    mount -o bind /sys "$ROOTFS_PARENT_FOLDER/rootfs/sys"
fi
chroot "$ROOTFS_PARENT_FOLDER/rootfs" /bin/bash