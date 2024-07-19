#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/docker-delete-all-containers.sh | bash -s
docker rm  -f `docker ps -qa`
