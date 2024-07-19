#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/docker-run-adguard.sh | bash -s -- /docker-volumes/adguard
# $1 Volume path
docker rm -f adguard
docker run -d \
    --name=adguard \
    -e TZ=Asia/Riyadh \
    -v $1/config:/opt/adguardhome/conf \
    -v $2/data:/opt/adguardhome/work \
    --net=host \
    --restart always \
    adguard/adguardhome