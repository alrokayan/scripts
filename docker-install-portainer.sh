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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/docker-install-portainer.sh /docker-volumes/portainer
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-install-portainer.sh | bash -s -- /docker-volumes/portainer
# $1 Volume Path
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <volume path>"
    echo "EXAMPLE: $0 /docker-volumes/portainer"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will install portainer"
        exit 0
    fi
    exit 1
fi
docker rm -f portainer
docker run -d \
           -p 9443:9443 \
           -p 9000:9000 \
           --name portainer \
           --restart=always \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v "$1:/data" \
           portainer/portainer-ce:latest