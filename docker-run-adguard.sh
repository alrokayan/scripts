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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/docker-run-adguard.sh /docker-volumes/adguard /docker-volumes/adguard
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-run-adguard.sh | bash -s -- /docker-volumes/adguard
# $1 Volume path
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <volume path>"
    echo "EXAMPLE: $0 /docker-volumes/adguard"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will run adguard on docker"
        exit 0
    fi
    exit 1
fi
docker rm -f adguard
docker run -d \
    --name=adguard \
    -e TZ=Asia/Riyadh \
    -v "$1/config:/opt/adguardhome/conf" \
    -v "$2/data:/opt/adguardhome/work" \
    --net=host \
    --restart always \
    adguard/adguardhome