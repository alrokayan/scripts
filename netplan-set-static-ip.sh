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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/netplan-set-static-ip.sh eth0 10.10.0.99 10.10.0.1 10.10.0.1 1.1.1.1
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/netplan-set-static-ip.sh | bash -s -- eth0 10.10.0.99 10.10.0.1 10.10.0.1 1.1.1.1
# $1 NIC
# $2 Static IP
# $3 Gateway
# $4 DNS1
# $5 DNS2
if [[ "$(uname -s)" == *"Darwin"* ]]; then
    echo "This script is not supported in macOS"
    exit 1
fi
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <NIC> <Static IP> <Gateway> <DNS1> <DNS2>"
    echo "EXAMPLE: $0 eth0 10.10.0.99 10.10.0.1 10.10.0.1 1.1.1.1"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will set static IP configuration for the specified NIC"
        exit 0
    fi
    exit 1
fi
NIC=$1
IP=$2
GW=$3
DNS1=$4
DNS2=$5
cat > "/etc/netplan/99-$NIC-static-ip-config.yaml" <<__EOF__
network:
  version: 2
  ethernets:
    $NIC:
      addresses:
        - $IP
      routes:
        - to: default
          via: $GW
      nameservers:
          addresses: [$DNS1, $DNS2]
__EOF__
# confirm settings
echo "Static IP configuration file created"
echo "------------ /etc/netplan/99-${NIC}-static-ip-config.yaml ------------"
cat "/etc/netplan/99-$NIC-static-ip-config.yaml"
echo "---------------------------------------------------------------------"
echo "Do you want to apply the settings now? (y/N)"
read -r applySettings
if [ -z "$apply" ]; then
  applySettings="n"
fi
if [ "$applySettings" == "y" ]; then
  chmod 600 /etc/netplan/*
  netplan apply
fi
