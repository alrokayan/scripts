#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/mosquitto-config-gen.sh | bash -s -- /mnt/nvme/kube-volumes/mosquitto
# $1 Path
mkdir -p $1
echo 'persistence true
persistence_location /mosquitto/config/data
log_dest file /mosuqitto/config/log/mosquitto.log
per_listener_settings true

listener 1883 0.0.0.0
allow_anonymous false
password_file /mosquitto/config/passwordfile

listener 1880 127.0.0.1
allow_anonymous true' > $1/mosquitto.conf
sudo chown -R 1883:1883 $1