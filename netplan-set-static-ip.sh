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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./netplan-set-static-ip.sh eth0 10.10.0.99 10.10.0.1 10.10.0.1 1.1.1.1
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/netplan-set-static-ip.sh | bash -s -- eth0 10.10.0.99 10.10.0.1 10.10.0.1 1.1.1.1
# $1 NIC
# $2 staticip
# $3 staticgateway
# $4 staticdns
# $5 staticdns2
NIC=$1
staticip=$2
staticgateway=$3
staticdns=$4
staticdns2=$5

# check if user is root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi
# check if netplan is installed
if [ ! -f /etc/netplan/01-netcfg.yaml ]; then
  echo "Netplan is not installed"
  exit 1
fi
if [ -n "$1" ] || [ -n "$2" ] || [ -n "$3" ] || [ -n "$4" ] || [ -n "$5" ]; then
  echo "Usage: $0 [NIC] [staticip] [staticgateway] [staticdns] [staticdns2]"
  exit 1
fi
cat > /etc/netplan/99-${NIC}-static-ip-config.yaml <<__EOF__
network:
  version: 2
  renderer: networkd
  ethernets:
    $NIC:
      addresses:
        - $staticip
      routes:
        - to: default
          via: $staticgateway
      nameservers:
          addresses: [$staticdns, $staticdns2]
__EOF__
# confirm settings
echo "Static IP configuration file created"
echo "------------ /etc/netplan/99-${NIC}-static-ip-config.yaml ------------"
cat /etc/netplan/99-${NIC}-static-ip-config.yaml
echo "---------------------------------------------------------------------"
echo "Do you want to apply the settings now? (y/N)"
read applySettings
if [ -z $apply ]; then
  applySettings="n"
fi
if [ $applySettings == "y" ]; then
  chmod 600 /etc/netplan/*
  netplan apply
fi
