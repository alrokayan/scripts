#! /bin/bash
# $1 First and second octet
# $2 Third octet
mkdir -p /run/flannel
cat << EOF > /run/flannel/subnet.env
FLANNEL_NETWORK=$1.0.0/16
FLANNEL_SUBNET=$1.$2.0/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF