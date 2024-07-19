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
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-run-codeserver.sh | bash -s -- /docker-volumes/code-server PASSWORD example.com
# $1 Volume path
# $2 Password
# $3 Proxy domain
docker rm -f codeserver
docker run -d --name=codeserver \
-p 8377:8443 \
-e PUID=1026 \
-e PGID=100 \
-e TZ=Asia/Riyadh \
-e PASSWORD=$2 \
-e PROXY_DOMAIN=$3 \
-e SUDO_PASSWORD=$2 \
-v $1/config:/config \
--privileged \
--restart always \
ghcr.io/linuxserver/code-server