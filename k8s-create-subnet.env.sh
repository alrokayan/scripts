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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/k8s-create-subnet.env.sh 10.244 0
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/k8s-create-subnet.env.sh | bash -s -- 10.244 0
# $1 First and second octet
# $2 Third octet
if [ -z "$1" ] || [ -z "$2" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <First and second octet> <Third octet>"
    echo "EXAMPLE: $0 10.244 0"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will create a subnet.env file"
        exit 0
    fi
    exit 1
fi
mkdir -p /run/flannel
cat << EOF > /run/flannel/subnet.env
FLANNEL_NETWORK=$1.0.0/16
FLANNEL_SUBNET=$1.$2.0/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF