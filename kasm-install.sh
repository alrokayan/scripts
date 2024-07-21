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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./kasm-install.sh PASSWORD
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/kasm-install.sh | bash -s -- PASSWORD
# $1 Password
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <password>"
    echo "EXAMPLE: $0 PASSWORD"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will install Kasm on docker"
        exit 0
    fi
    exit 1
fi
KASM_UID=$(id kasm -u)
export KASM_UID
KASM_GID=$(id kasm -g)
export KASM_GID
echo "-- Deleting Kasm containers"
/opt/kasm/current/bin/stop
echo "-- Downloading Kasm in /tmp"
cd /tmp || exit
rm -f kasm.tar.gz
curl -L https://kasm-static-content.s3.amazonaws.com/kasm_release_1.15.0.06fdc8.tar.gz -o kasm.tar.gz
rm -rf kasm_release
tar -xf kasm.tar.gz 
IP=$(hostname -I | awk '{print $1}')
export IP
export PORT=10443
export KASM_PASSWORD=$1
echo "-- Installing Kasm on $IP:$PORT (SSL)"
mkdir -p /opt/Kasm
./kasm_release/install.sh noninteractive \
                          --slim-images \
                          --admin-password "$KASM_PASSWORD" \
                          --user-password "$KASM_PASSWORD" \
                          --accept-eula \
                          --default-images \
                          --proxy-port "$PORT"

echo "-- SETUP KASM: https://$IP:3000 (TEMPORARY)"
echo "-------------------------------------------"
echo "-- Login: https://$IP:$PORT"
echo "-- Username: admin@kasm.local"
echo "-- Password: $KASM_PASSWORD"
echo ""
echo "-- Login: https://$IP:$PORT"
echo "-- Username: user@kasm.local"
echo "-- Password: $KASM_PASSWORD"


