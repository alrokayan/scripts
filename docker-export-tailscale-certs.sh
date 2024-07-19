#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/docker-export-tailscale-certs.sh | bash -s -- /docker-volumes/tailscale /certs
# $1 Path to tailscale volume
# $2 Path to save certs on
wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O jq 
chmod +x jq
mv jq /usr/local/bin
# apt-get install -y jq
mkdir -p  /var/lib/tailscale/certs/
DOMAIN=`docker exec tailscale tailscale status --json | jq '.Self.DNSName | .[:-1]' -r`
docker exec tailscale tailscale cert --cert-file "/var/lib/tailscale/certs/${DOMAIN}.crt" \
                                     --key-file "/var/lib/tailscale/certs/${DOMAIN}.key" \
                                     "${DOMAIN}"
mkdir -p $2/certs
mkdir -p $2/private
cp $1/tailscale/certs/${DOMAIN}.crt $2/certs/${DOMAIN}.crt
cp $1/tailscale/certs/${DOMAIN}.key $2/private/${DOMAIN}.key
cp $1/tailscale/certs/${DOMAIN}.crt $2/certs/tailscale.crt
cp $1/tailscale/certs/${DOMAIN}.key $2/certs/tailscale.key