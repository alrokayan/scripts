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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/ha-lovelace.sh /kube-volumes/homeassistant/data
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/ha-lovelace.sh | bash -s -- /kube-volumes/homeassistant/data
# $1 Path to home assistant data volume
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <home assistant data volume path>"
    echo "EXAMPLE: $0 /kube-volumes/homeassistant/data"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will export tailscale certs"
        exit 0
    fi
    exit 1
fi
cd "$1" || exit
mkdir -p "$1/www/"
curl -fsSL https://raw.githubusercontent.com/thomasloven/lovelace-fold-entity-row/master/fold-entity-row.js -o "$1/www/fold-entity-row.js"
curl -fsSL https://raw.githubusercontent.com/thomasloven/lovelace-auto-entities/master/auto-entities.js -o "$1/www/auto-entities.js"
if ! cat configuration.yaml | grep "fold-entity-row.js"; then
  echo "-- Adding fold-entity-row.js and auto-entities.js to configuration.yaml"
  echo '
frontend:
  extra_module_url:
    - /local/fold-entity-row.js
    - /local/auto-entities.js
' >> configuration.yaml
fi
cat configuration.yaml
