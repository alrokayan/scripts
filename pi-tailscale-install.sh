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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./pi-tailscale-install.sh ts_1234567890abcdef
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/pi-tailscale-install.sh | bash -s -- ts_1234567890abcdef
# $1 Tailscale authkey
# $2 Tailscale port to expose (optional)
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <tailscale authkey> <port - optional>" 
    echo "EXAMPLE: $0 ts_1234567890abcdef 8443"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will install tailscale on bookwarm raspbian"
        exit 0
    fi
    exit 1
fi
apt-get install apt-transport-https
mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bookworm.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
apt-get update -y && apt-get install tailscale -y
# ip link delete tailscale0
systemctl enable --now tailscaled
tailscale up \
       --accept-dns=false \
       --advertise-exit-node=false \
       --authkey="$1" \
       --accept-routes=true \
       --reset
if [ -n "$2" ]; then
    tailscale funnel --bg http://127.0.0.1:"$2"
fi
tailscale ip -4
tailscale status