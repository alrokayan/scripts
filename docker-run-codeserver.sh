#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/docker-run-codeserver.sh | bash -s -- /docker-volumes/code-server PASSWORD example.com
# $1 Volume path
# $2 Password
# $3 Proxy domain
docker rm -f codeserver
docker run -d --name=codeserver \
-p 8377:8443 \
-e PUID=1026 \
-e PGID=100 \
-e TZ=Asia/Riyadh \
-e PASSWORD=$2 \
-e PROXY_DOMAIN=$3 \
-e SUDO_PASSWORD=$2 \
-v $1/config:/config \
--privileged \
--restart always \
ghcr.io/linuxserver/code-server