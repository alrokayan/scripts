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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./disk-image.sh /Users/USER/Downloads/2024-07-04-raspios-bookworm-arm64.img.xz /dev/disk4
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/disk-image.sh | bash -s /Users/USER/Downloads/2024-07-04-raspios-bookworm-arm64.img.xz /dev/disk4
# $1 Path to image
# $2 Path to disk
if [ -z "$1" ] && [ -z "$2" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <path-to-image> <path-to-disk>"
    echo "EXAMPLE: $0 /Users/USER/Downloads/2024-07-04-raspios-bookworm-arm64.img.xz /dev/disk4"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will 
        exit 0
    fi
    exit 1
fi
sudo diskutil unmountDisk $2
(pv -n $1 | sudo dd of=$2 bs=128M conv=notrunc,noerror) 2>&1 \
| dialog --gauge "Running dd command (cloning), please wait..." 10 70 0