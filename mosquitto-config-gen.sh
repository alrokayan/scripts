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

# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/mosquitto-config-gen.sh | bash -s -- /mnt/nvme/kube-volumes/mosquitto
# $1 Path
mkdir -p $1
echo 'persistence true
persistence_location /mosquitto/config/data
log_dest file /mosuqitto/config/log/mosquitto.log
per_listener_settings true

listener 1883 0.0.0.0
allow_anonymous false
password_file /mosquitto/config/passwordfile

listener 1880 127.0.0.1
allow_anonymous true' > $1/mosquitto.conf
sudo chown -R 1883:1883 $1