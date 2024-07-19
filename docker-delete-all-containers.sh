#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-delete-all-containers.sh | bash -s
docker rm  -f `docker ps -qa`
