#!/bin/sh
ROOTFS_PARENT_FOLDER=/root

umount -l $ROOTFS_PARENT_FOLDER/rootfs/dev
umount $ROOTFS_PARENT_FOLDER/rootfs/proc
umount $ROOTFS_PARENT_FOLDER/rootfs/sys
df | grep rootfs