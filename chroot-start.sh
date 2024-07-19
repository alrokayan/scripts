#!/bin/sh
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/chroot-start.sh | bash -s
ROOTFS_PARENT_FOLDER=/root
if mount | awk '{if ($3 == "'$ROOTFS_PARENT_FOLDER'/rootfs/dev") { exit 0}} ENDFILE{exit -1}'; then
    echo "$ROOTFS_PARENT_FOLDER/rootfs/dev/ already mounted"
else
    mount -o bind /dev $ROOTFS_PARENT_FOLDER/rootfs/dev/
fi

if mount | awk '{if ($3 == "'$ROOTFS_PARENT_FOLDER'/rootfs/proc") { exit 0}} ENDFILE{exit -1}'; then
    echo "$ROOTFS_PARENT_FOLDER/rootfs/proc/ already mounted"
else
    mount -t proc none $ROOTFS_PARENT_FOLDER/rootfs/proc/
fi

if mount | awk '{if ($3 == "'$ROOTFS_PARENT_FOLDER'/rootfs/sys") { exit 0}} ENDFILE{exit -1}'; then
    echo "$ROOTFS_PARENT_FOLDER/rootfs/sys already mounted"
else
    mount -o bind /sys $ROOTFS_PARENT_FOLDER/rootfs/sys
fi
chroot $ROOTFS_PARENT_FOLDER/rootfs /bin/bash