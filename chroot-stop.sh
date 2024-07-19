#!/bin/sh
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/chroot-stop.sh | bash -s
ROOTFS_PARENT_FOLDER=/root
umount -l $ROOTFS_PARENT_FOLDER/rootfs/dev
umount $ROOTFS_PARENT_FOLDER/rootfs/proc
umount $ROOTFS_PARENT_FOLDER/rootfs/sys
df | grep rootfs