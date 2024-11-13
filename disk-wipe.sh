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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/disk-wipe.sh /dev/disk4 exfat
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/disk-wipe.sh | bash -s -- /dev/disk4 exfat
# $1 Path to disk
# $2 File system
if [ -z "$1" ] || [ -z "$2" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <path-to-disk> <file-system>"
    echo "EXAMPLE: $0 /dev/disk4 exfat"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will wipe the disk."
        exit 0
    fi
    exit 1
fi
echo "-- unmounting $1/*"
sudo umount "$1/*"
echo "-- wiping $1"
wipefs -a "$1"
echo "-- creating $2 file system on $1"
"mkfs.$2" -f "$1"
echo "-- dd $1 to $2"
sudo dd if="$1" of="$2" bs=4M conv=notrunc,noerror status=progress
echo "-- unmounting $1/*"
sudo umount "$1/*"

# download windows 11 iso file then extract it then rename all txr files to remove the unsupported chaaracters burn it to usb
wget https://software-download.microsoft.com/download/pr/22000.194.210604-1628.co_release_CLIENT_CONSUMER_x64FRE_en-us.iso
7z x 22000.194.210604-1628.co_release_CLIENT_CONSUMER_x64FRE_en-us.iso
find . -name "*.txr" -exec rename 's/[^a-zA-Z0-9_.-]//g' {} \;
sudo dd if=22000.194.210604-1628.co_release_CLIENT_CONSUMER_x64FRE_en-us.iso of=/dev/disk4 bs=4M conv=notrunc,noerror status=progress
