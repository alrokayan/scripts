#!/bin/bash
# $1 Volume Path
docker rm -f portainer
docker run -d \
           -p 9443:9443 \
           -p 9000:9000 \
           --name portainer \
           --restart=always \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v $1:/data \
           portainer/portainer-ce:latest