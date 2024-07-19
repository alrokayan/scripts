#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/rsync.sh | bash -s -- /mnt/disk1 /mnt/disk2
# $1 From
# $2 To
rsync -avzrlt --progress $1 $2
