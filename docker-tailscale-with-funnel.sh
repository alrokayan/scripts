#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/docker-tailscale-with-funnel.sh | bash -s -- AUTHKEY 8123
# $1 Tailscale authkey
# $2 Port to funnel
docker stop tailscale
sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sed -i '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
ip link delete tailscale0
docker pull tailscale/tailscale:stable
docker start tailscale
sleep 5s
docker exec tailscale tailscale up \
       --accept-dns=false \
       --advertise-exit-node=false \
       --authkey=$1 \
       --reset
docker exec tailscale tailscale funnel --bg http://127.0.0.1:$2
