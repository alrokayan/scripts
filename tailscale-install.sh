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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./tailscale-install.sh ts_1234567890abcdef
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/tailscale-install.sh | bash -s -- ts_1234567890abcdef
# $1 Tailscale authkey
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <tailscale authkey>"
    echo "EXAMPLE: $0 ts_1234567890abcdef"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will install tailscale"
        exit 0
    fi
    exit 1
fi
curl -fsSL https://tailscale.com/install.sh | sh
sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sed -i '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
# ip link delete tailscale0
systemctl enable --now tailscaled
systemctl status tailscaled
tailscale up \
       --accept-dns=false \
       --advertise-exit-node=false \
       --authkey="$1" \
       --accept-routes=true \
       --reset
# tailscale funnel --bg http://127.0.0.1
