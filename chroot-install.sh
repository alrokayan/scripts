#!/bin/sh
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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./chroot-install.sh /mnt/iso /root
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/chroot-install.sh | bash -s -- /mnt/iso /root
# $1 ISO folder
# $2 rootfs parent folder
if [ -z "$1" ] || [ -z "$2" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <ISO folder> <rootfs parent folder>"
    echo "EXAMPLE: $0 /mnt/iso /root"
    if [ -z "$1" ]; then
        echo "ISO folder is required"
        exit 0
    fi
    exit 1
fi
ISO_FOLDER=$1
ROOT_FS_PARENT_FOLDER=$2
# initialize
umount -l "$ROOT_FS_PARENT_FOLDER/rootfs/dev" 2>/dev/null
umount "$ROOT_FS_PARENT_FOLDER/rootfs/dev" 2>/dev/null
umount "$ROOT_FS_PARENT_FOLDER/rootfs/proc" 2>/dev/null
umount "$ROOT_FS_PARENT_FOLDER/rootfs/sys" 2>/dev/null
umount /mnt/rootfs 2>/dev/null
umount /mnt/squashfs 2>/dev/null
umount /mnt/cdrom 2>/dev/null
rm -r /mnt/rootfs /mnt/squashfs /mnt/cdrom 2>/dev/null
cd "$ISO_FOLDER "|| exit
if [ ! -f CentOS-7-x86_64-Minimal-1503-01.iso ]; then
    wget https://ftp.iij.ad.jp/pub/linux/centos-vault/7.1.1503/isos/x86_64/CentOS-7-x86_64-Minimal-1503-01.iso
fi
cd "$ROOT_FS_PARENT_FOLDER" || exit
# mount install cd
mkdir -p /mnt/cdrom
mount "$ISO_FOLDER/CentOS-7-x86_64-Minimal-1503-01.iso" /mnt/cdrom -t iso9660 -o loop 2>/dev/null
# mount squashfs
mkdir -p /mnt/squashfs
mount /mnt/cdrom/LiveOS/squashfs.img /mnt/squashfs -t squashfs 2>/dev/null
# mount rootfs
mkdir -p /mnt/rootfs
mount /mnt/squashfs/LiveOS/rootfs.img /mnt/rootfs -t ext4 2>/dev/null
# copy rootfs
rm -rf "$ROOT_FS_PARENT_FOLDER/rootfs"
cp -r /mnt/rootfs "$ROOT_FS_PARENT_FOLDER/rootfs"
umount /mnt/rootfs 2>/dev/null
umount /mnt/squashfs 2>/dev/null
umount /mnt/cdrom 2>/dev/null
rm -r /mnt/rootfs /mnt/squashfs /mnt/cdrom 2>/dev/null
# mount dvd image under rootfs
mkdir "$ROOT_FS_PARENT_FOLDER/rootfs/mnt/cdrom"
mount "$ISO_FOLDER/CentOS-7-x86_64-Minimal-1503-01.iso" rootfs/mnt/cdrom -t iso9660 -o loop
# chroot
mount -o bind /dev "$ROOT_FS_PARENT_FOLDER/rootfs/dev/"
mount -t proc none "$ROOT_FS_PARENT_FOLDER/rootfs/proc/"
mount -o bind /sys "$ROOT_FS_PARENT_FOLDER/rootfs/sys/"
rm -f "$ROOT_FS_PARENT_FOLDER/rootfs/etc/resolv.conf"
cp /etc/resolv.conf "$ROOT_FS_PARENT_FOLDER/rootfs/etc/"
chroot "$ROOT_FS_PARENT_FOLDER/rootfs /bin/bash" -xe << _END_CHROOT_
cd /mnt/cdrom/Packages
rpm -ivh --nodeps rpm-4.11.1-25.el7.x86_64.rpm
rpm -ivh --nodeps yum-3.4.3-125.el7.centos.noarch.rpm
# add the cdrom image to yum repository
cat << _END_ > /etc/yum.repos.d/cdrom.repo
[cdrom]
name=Install CD-ROM 
baseurl=file:///mnt/cdrom
enabled=0
gpgcheck=1
gpgkey=file:///mnt/cdrom/RPM-GPG-KEY-CentOS-7
_END_
yum --disablerepo=\* --enablerepo=cdrom -y reinstall yum
yum --disablerepo=\* --enablerepo=cdrom -y groupinstall "Minimal Install"
# yum --disablerepo=\* --enablerepo=cdrom -y install <required packages>
rm /etc/yum.repos.d/cdrom.repo
_END_CHROOT_
# Clean up
umount "$ROOT_FS_PARENT_FOLDER/rootfs/mnt/cdrom"
umount "$ROOT_FS_PARENT_FOLDER/rootfs/dev"
umount "$ROOT_FS_PARENT_FOLDER/rootfs/proc"
umount "$ROOT_FS_PARENT_FOLDER/rootfs/sys"
