#!/bin/bash
# curl https://raw.githubusercontent.com/alrokayan/scripts/main/netplan-set-static-ip.sh | bash -s
ip a | grep ": "
echo "Enter your network card name (Default: eth0): "
read NIC
if [ -z $NIC ]; then
  NIC="eth0"
fi
if [ -f /etc/netplan/01-${NIC}-static-ip-config.yaml ]; then
  echo "Static IP configuration file already exists"
  echo "Do you want to overwrite it? (y/N)"
  read overwrite
  if [ -z $overwrite ]; then
    overwrite="N"
  fi
  if [ "$overwrite" != "y" ]; then
    echo "Exiting..."
    exit 1
  fi
fi
# read from user static ip
echo "Enter new static IP with subnet: (Default 192.168.4.201/25) "
read staticip
if [ -z $staticip ]; then
  staticip="192.168.4.201/25"
fi
# read from user static gateway
echo "Enter new static gateway: (Default: 192.168.4.1)"
read staticgateway
if [ -z $staticgateway ]; then
  staticgateway="192.168.4.1"
fi
# read from user static dns
echo "Enter new static dns: (Default: 1.1.1.1)"
read staticdns
if [ -z $staticdns ]; then
  staticdns="1.1.1.1"
fi
# read from user static dns
echo "Enter new static dns2: (Default: 8.8.8.8)"
read staticdns2
if [ -z $staticdns2 ]; then
  staticdns2="8.8.8.8"
fi
# write to file
cat > /etc/netplan/01-${NIC}-static-ip-config.yaml <<__EOF__
network:
  version: 2
  renderer: networkd
  ethernets:
    $NIC:
      addresses:
        - $staticip
      routes:
        - to: default
          via: $staticgateway
      nameservers:
          addresses: [$staticdns, $staticdns2]
__EOF__
# confirm settings
echo "Static IP configuration file created"
echo "------------ /etc/netplan/01-${NIC}-static-ip-config.yaml ------------"
cat /etc/netplan/01-${NIC}-static-ip-config.yaml
echo "---------------------------------------------------------------------"
echo "Do you want to apply the settings now? (y/N)"
read applySettings
if [ -z $apply ]; then
  applySettings="n"
fi
if [ $applySettings == "y" ]; then
  chmod 600 /etc/netplan/*
  netplan apply
fi
