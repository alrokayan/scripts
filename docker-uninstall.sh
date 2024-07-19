#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/docker-uninstall.sh | bash -s
apt purge -y docker-ce docker-buildx-plugin docker-ce-cli docker-ce-rootless-extras docker-compose-plugin
apt autoremove -y docker-ce docker-buildx-plugin docker-ce-cli docker-ce-rootless-extras docker-compose-plugin
rm -rf /var/lib/docker /etc/docker /var/run/docker.sock
groupdel docker
