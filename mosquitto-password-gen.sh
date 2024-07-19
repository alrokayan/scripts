#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/mosquitto-password-gen.sh | bash -s -- /mnt/nvme/kube-volumes/mosquitto USERNAME PASSWORD
# $1 Path to mosquitto config/data volume
# $2 username
# $3 password
sudo docker run -it -v $1:/mosquitto/config --rm eclipse-mosquitto mosquitto_passwd -c -b /mosquitto/config/passwordfile $2 $3
sudo chmod 0700 $1/passwordfile
