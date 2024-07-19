#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/mount.sh | bash -s -- 10.0.0.1 /mnt/hdd/Nextcloud /nextcloud
# $1 = NFS server address
# $2 = NFS path
# $3 = Local mount point
SYSTEMD_ESCAPED_MOINT_POINT=$(systemd-escape --path "$3")
echo "-- Mounting: $1:$2 on $3 ($SYSTEMD_ESCAPED_MOINT_POINT)" >&3
mkdir -p "$3"
cat >/etc/systemd/system/$SYSTEMD_ESCAPED_MOINT_POINT.mount <<EOF
[Unit]
Description=Mount $2
Requires=rpcbind.service network-online.target
Wants=networking.service
#
# Replaces this line in fstab
#$1:$2   $3  nfs defaults,noatime,x-systemd.automount 0 0
#
[Mount]
What=$1:$2
Where=$3
Type=nfs
Options=defaults
TimeoutSec=30

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable $SYSTEMD_ESCAPED_MOINT_POINT.mount
systemctl start $SYSTEMD_ESCAPED_MOINT_POINT.mount
systemctl status $SYSTEMD_ESCAPED_MOINT_POINT.mount
