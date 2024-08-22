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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/hostname.sh NEWHOSTNAME
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/hostname.sh | bash -s -- NEWHOSTNAME
# $1 New hostname
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <new hostname>"
    echo "EXAMPLE: $0 NEWHOSTNAME"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will change the hostname of the system"
        exit 0
    fi
    exit 1
fi
old_hostname=$(cat /etc/hostname)
hostnamectl --no-ask-password hostname "$1"
sed -i 's/'"$old_hostname"'/'"$1"'/g' /etc/hosts
cat /etc/hosts
echo "-- Your new hostname is $(hostname)"
echo "-- Please restart your system to apply changes"
