#!/bin/bash
# curl https://raw.githubusercontent.com/alrokayan/scripts/main/tailscale-install.sh | bash -s -- AUTHKEY
# $1 Tailscale authkey
curl -fsSL https://tailscale.com/install.sh | sh
sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sed -i '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
ip link delete tailscale0
tailscale up \
       --accept-dns=false \
       --advertise-exit-node=false \
       --authkey=$1 \
       --reset
# tailscale funnel --bg http://127.0.0.1
