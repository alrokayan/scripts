#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/backup.tar.gz.sh | bash -s -- /mnt/hdd/Backups /mnt/nvme/kube-volumes
# $1 Backup folder path
# $2 Target path to backup
DATE_FOLDER=$(date +%Y_%m_%d)
DATATIME_FILE="$(date +%Y_%m_%d-%H-%M-%S)"
BACKUP_PATH=$1
TARGET=$2
mkdir -p "$BACKUP_PATH/$DATE_FOLDER"
tar --exclude='**/MediaCover/*' \
    --exclude='**/.cache/*' \
    --exclude='**/.gnupg/*' \
    --exclude='**/logs/*' \
    --exclude='*.log' \
    --exclude='*.sock' \
    --exclude='**/plex/config/Library' \
    --exclude='**/kasm/data' \
    -Pcpzf "$BACKUP_PATH/$DATE_FOLDER/$TARGET/$DATATIME_FILE.tar.gz" \
    $TARGET
rm -rf "$(find $BACKUP_PATH -maxdepth 1 -type d -ctime +30)"
