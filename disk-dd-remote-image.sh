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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./disk-dd-remote-image.sh https://downloads.raspberrypi.com/raspios_full_arm64/images/raspios_full_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-full.img.xz /dev/disk4
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/disk-dd-remote-image.sh | bash -s -- https://downloads.raspberrypi.com/raspios_full_arm64/images/raspios_full_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-full.img.xz /dev/disk4
# $1 Image URL
# $2 Path to disk
if [ -z "$1" ] && [ -z "$2" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <image-url> <path-to-disk>"
    echo "EXAMPLE: $0 https://downloads.raspberrypi.com/raspios_full_arm64/images/raspios_full_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-full.img.xz /dev/disk4"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will write the image to the disk."
        exit 0
    fi
    exit 1
fi
echo "-- Unmounting disk $2"
sudo diskutil unmountDisk "$2"
if [ "${1##*.}" == "img" ] || [ "${1##*.}" == "iso" ]; then
    echo "Writing $1 to disk $2, please wait..."
    curl -fL "$1" | sudo dd of="$2" bs=4M conv=notrunc,noerror status=progress
else
    echo "Downloading, extracting $1 and writing to disk $2, please wait..."
    curl -fL "$1" | gunzip --force --verbose --stdout | sudo dd of="$2" bs=4M conv=notrunc,noerror status=progress
fi
echo "-- Unmounting disk $2"
sudo diskutil unmountDisk "$2"



mkdir -p tmp
curl -OJL "$1"
if [ "${1##*.}" != "img" ]; then
    DIR="$(dirname "${1}")"
    FILE="$(basename "${1}")"
    FILE_IMG="${FILE%.*}"
    IMAGE_FILE="$DIR/$FILE_IMG"
    echo "Extracting $DIR/$FILE_IMG, please wait..."
    gunzip -vf "$1"
else
    IMAGE_FILE="$1"
fi
sudo diskutil unmountDisk "$2"
sudo dd if=tmp/image.img.xz of="$2" bs=4M conv=notrunc,noerror status=progress
sudo diskutil unmountDisk "$2"
