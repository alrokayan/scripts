#!/bin/sh
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/chroot-install.sh | bash -s
ISO_SR=/run/sr-mount/d6818f51-40ac-b1f3-cd6c-d658d9e4fd21
ROOTFS_PARENT_FOLDER=/root
# initialize
umount -l $ROOTFS_PARENT_FOLDER/rootfs/dev 2>/dev/null
umount $ROOTFS_PARENT_FOLDER/rootfs/dev 2>/dev/null
umount $ROOTFS_PARENT_FOLDER/rootfs/proc 2>/dev/null
umount $ROOTFS_PARENT_FOLDER/rootfs/sys 2>/dev/null
umount /mnt/rootfs 2>/dev/null
umount /mnt/squashfs 2>/dev/null
umount /mnt/cdrom 2>/dev/null
rm -r /mnt/rootfs /mnt/squashfs /mnt/cdrom 2>/dev/null
cd $ISO_SR
if [ ! -f CentOS-7-x86_64-Minimal-1503-01.iso ]; then
    wget https://ftp.iij.ad.jp/pub/linux/centos-vault/7.1.1503/isos/x86_64/CentOS-7-x86_64-Minimal-1503-01.iso
fi
cd $ROOTFS_PARENT_FOLDER
# mount install cd
mkdir -p /mnt/cdrom
mount $ISO_SR/CentOS-7-x86_64-Minimal-1503-01.iso /mnt/cdrom -t iso9660 -o loop 2>/dev/null
# mount squashfs
mkdir -p /mnt/squashfs
mount /mnt/cdrom/LiveOS/squashfs.img /mnt/squashfs -t squashfs 2>/dev/null
# mount rootfs
mkdir -p /mnt/rootfs
mount /mnt/squashfs/LiveOS/rootfs.img /mnt/rootfs -t ext4 2>/dev/null
# copy rootfs
rm -rf $ROOTFS_PARENT_FOLDER/rootfs
cp -r /mnt/rootfs $ROOTFS_PARENT_FOLDER/rootfs
umount /mnt/rootfs 2>/dev/null
umount /mnt/squashfs 2>/dev/null
umount /mnt/cdrom 2>/dev/null
rm -r /mnt/rootfs /mnt/squashfs /mnt/cdrom 2>/dev/null
# mount dvd image under rootfs
mkdir $ROOTFS_PARENT_FOLDER/rootfs/mnt/cdrom
mount $ISO_SR/CentOS-7-x86_64-Minimal-1503-01.iso rootfs/mnt/cdrom -t iso9660 -o loop
# chroot
mount -o bind /dev $ROOTFS_PARENT_FOLDER/rootfs/dev/
mount -t proc none $ROOTFS_PARENT_FOLDER/rootfs/proc/
mount -o bind /sys $ROOTFS_PARENT_FOLDER/rootfs/sys/
rm -f $ROOTFS_PARENT_FOLDER/rootfs/etc/resolv.conf
cp /etc/resolv.conf $ROOTFS_PARENT_FOLDER/rootfs/etc/
chroot $ROOTFS_PARENT_FOLDER/rootfs /bin/bash -xe << _END_CHROOT_
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
umount $ROOTFS_PARENT_FOLDER/rootfs/mnt/cdrom
umount $ROOTFS_PARENT_FOLDER/rootfs/dev
umount $ROOTFS_PARENT_FOLDER/rootfs/proc
umount $ROOTFS_PARENT_FOLDER/rootfs/sys
