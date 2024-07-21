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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./docker-export-tailscale-certs.sh /docker-volumes/tailscale /certs
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-export-tailscale-certs.sh | bash -s -- /docker-volumes/tailscale /certs
# $1 Path to tailscale volume
# $2 Path to save certs on
if [ -z "$1" ] || [ -z "$2" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <tailscale volume path> <certs path>"
    echo "EXAMPLE: $0 /docker-volumes/tailscale /certs"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will export tailscale certs"
        exit 0
    fi
    exit 1
fi
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O jq 
chmod +x jq
mv jq /usr/local/bin
# apt-get install -y jq
mkdir -p  /var/lib/tailscale/certs/
DOMAIN=$(docker exec tailscale tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)
docker exec tailscale tailscale cert --cert-file "/var/lib/tailscale/certs/${DOMAIN}.crt" \
                                     --key-file "/var/lib/tailscale/certs/${DOMAIN}.key" \
                                     "${DOMAIN}"
mkdir -p "$2/certs"
mkdir -p "$2/private"
cp "$1/tailscale/certs/$DOMAIN.crt" "$2/certs/$DOMAIN.crt"
cp "$1/tailscale/certs/$DOMAIN.key" "$2/private/$DOMAIN.key"
cp "$1/tailscale/certs/$DOMAIN.crt" "$2/certs/tailscale.crt"
cp "$1/tailscale/certs/$DOMAIN.key" "$2/certs/tailscale.key"