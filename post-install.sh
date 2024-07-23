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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./post-install.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/post-install.sh | bash -s
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "This script will install post-install"
    exit 0
fi
if [ "$(id -un -u 1000)" -ne 0 ]; then
    echo "-- Enable sudo without password for $(id -un -u 1000)"
    echo "$(id -un -u 1000) ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi
apt update -y
apt upgrade -y
apt autoclean -y
apt autoremove -y
apt install curl util-linux coreutils gnupg git nfs-common nano cifs-utils -y
sed -i '/#PermitRootLogin prohibit-password/c\PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication no/c\PasswordAuthentication yes' /etc/ssh/sshd_config
sed -i '/#   StrictHostKeyChecking ask/c\    StrictHostKeyChecking no' /etc/ssh/ssh_config
systemctl reload ssh
sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sed -i '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf
sed -i '/#DefaultTimeoutStopSec=90s/c\DefaultTimeoutStopSec=10s' /etc/systemd/system.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\"/&usbcore.autosuspend=-1 /' /etc/default/grub
update-grub
sed -i '/.*#DNSStubListener=.*/ c\DNSStubListener=no' /etc/systemd/resolved.conf
systemctl restart systemd-resolved