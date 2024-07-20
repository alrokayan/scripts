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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./docker-tailscale-with-funnel.sh AUTHKEY 8123
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-tailscale-with-funnel.sh | bash -s -- AUTHKEY 8123
# $1 Tailscale authkey
# $2 Port to funnel
docker stop tailscale
sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sed -i '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
ip link delete tailscale0
docker pull tailscale/tailscale:stable
docker start tailscale
sleep 5s
docker exec tailscale tailscale up \
       --accept-dns=false \
       --advertise-exit-node=false \
       --authkey=$1 \
       --reset
docker exec tailscale tailscale funnel --bg http://127.0.0.1:$2
