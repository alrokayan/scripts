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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./disk-install-ext4-and-raspios-enable-ssh.sh /dev/disk4
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/disk-install-ext4-and-raspios-enable-ssh.sh | bash -s -- /dev/disk4
# $1 Path to disk
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <path-to-disk>"
    echo "EXAMPLE: $0 /dev/disk4"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will enable ssh in raspios disk"
        echo "For mac you have to download and install MacFuse (https://osxfuse.github.io) or install via brew (brew install ext4fuse)"
        exit 0
    fi
    exit 1
fi
TMP_MNT_PATH="tmp/raspios"
sudo diskutil unmountDisk "$1"
rmdir "$TMP_MNT_PATH"
if mkdir "$TMP_MNT_PATH"; then
    BASE_PATH=$(printf "%q\n" "$(pwd)")
    if ! [ -f tmp/ext4fuse/ext4fuse ]; then
        mkdir -p tmp
        cd tmp || exit
        rm -f pkgconfig.tgz
        curl https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.tar.gz -o pkgconfig.tgz
        rm -rf pkg-config-0.29
        tar -zxf pkgconfig.tgz
        cd pkg-config-0.29 || exit
        ./configure --with-internal-glib && make install
        cd "$BASE_PATH/tmp" || exit
        rm -rf ext4fuse
        git clone https://github.com/gerard/ext4fuse.git
        cd ext4fuse || exit
        make
    fi
    cd "$BASE_PATH" || exit
    ./tmp/ext4fuse/ext4fuse "$1" $TMP_MNT_PATH -o allow_other
    touch "$TMP_MNT_PATH/ssh"
    sudo diskutil unmountDisk "$1"
    rm -rf "$TMP_MNT_PATH"
else
    echo "-- Error while creating $TMP_MNT_PATH"
    exit 1
fi