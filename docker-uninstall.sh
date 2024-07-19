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
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-uninstall.sh | bash -s
apt purge -y docker-ce docker-buildx-plugin docker-ce-cli docker-ce-rootless-extras docker-compose-plugin
apt autoremove -y docker-ce docker-buildx-plugin docker-ce-cli docker-ce-rootless-extras docker-compose-plugin
rm -rf /var/lib/docker /etc/docker /var/run/docker.sock
groupdel docker
