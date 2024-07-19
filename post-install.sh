#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/post-install.sh | bash -s
apt update -y
apt upgrade -y
apt autoclean -y
apt autoremove -y
apt install curl util-linux coreutils gnupg git nfs-common nano cifs-utils -y
sed -i '/#PermitRootLogin prohibit-password/c\PermitRootLogin yes' /etc/ssh/sshd_config
sed -i '/PasswordAuthentication no/c\PasswordAuthentication yes' /etc/ssh/sshd_config
sed -i '/#   StrictHostKeyChecking ask/c\    StrictHostKeyChecking no' /etc/ssh/ssh_config
systemctl reload ssh
sed -i '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sed -i '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf
sed -i '/#DefaultTimeoutStopSec=90s/c\DefaultTimeoutStopSec=10s' /etc/systemd/system.conf
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\"/&usbcore.autosuspend=-1 /' /etc/default/grub
update-grub
sed -i '/.*#DNSStubListener=.*/ c\DNSStubListener=no' /etc/systemd/resolved.conf
systemctl restart systemd-resolved
