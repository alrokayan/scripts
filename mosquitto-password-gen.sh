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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/mosquitto-config-gen.sh /mnt/nvme/kube-volumes/mosquitto USERNAME PASSWORD
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/mosquitto-password-gen.sh | bash -s -- /mnt/nvme/kube-volumes/mosquitto USERNAME PASSWORD
# $1 Path to mosquitto config/data volume
# $2 username
# $3 password
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <path> <username> <password>"
    echo "EXAMPLE: $0 /mnt/nvme/kube-volumes/mosquitto USERNAME PASSWORD"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will generate mosquitto password using docker"
        exit 0
    fi
    exit 1
fi
sudo docker run -it -v "$1":/mosquitto/config --rm eclipse-mosquitto mosquitto_passwd -c -b /mosquitto/config/passwordfile "$2" "$3"
sudo chmod 0700 "$1/passwordfile"
