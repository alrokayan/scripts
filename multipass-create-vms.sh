#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/multipass-create-vms.sh | bash -s -- ubuntu 00:14:51:3C:84:F1 eno0 /Users/USER/Nextcloud /nextcloud 2 2 64
# $1 Hostname
# $2 Mac
# $3 NIC
# $4 Local mount path
# $5 VM mount path
# $6 CPUs
# $7 RAM in GB
# $8 Disk in GB
echo "Creating VM: $1 with MAC: $2"
cat <<EOF | multipass launch 22.04 \
                --name $1 \
                --cpus $6 \
                --disk ${8}G \
                --memory ${7}G \
                --mount $4:$5 \
                --network name=$3,mode=auto,mac=$2 \
                --cloud-init -
#cloud-config
hostname: $1
package_update: true
package_upgrade: true
package_reboot_if_required: true
packages:
  - nano
  - git
  - curl
  - util-linux
  - coreutils
  - gnupg
  - nfs-common
  - openvswitch-switch
mounts:
 - [ swap, null ]
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFKVH03XmRMoKjPVwpaNfi4cxR6FI9n6ZLojZ8aRFl6OTbH5hkjPU5Q9sZYGAucOVLdD4p85KsNFedFHljxP5oGXvRp2SM8H423Y6CaTG39f3gfru2jaHMRCMuSw4hcf70Jxvm7spYodoUL/dJVJCX6RK0EnQCyutD3L4evuviYv2bzl13z4meDiVREHg5M5HhW7ImGm4IGQwvUNaKYblblHDMHHgMp2Cc2aHGVq8TFj0xj7j64fvlCnjOvIB04/j3ZPeDGOGEw5YG0CrrqkHyTWgP7IczD20WUYG1jZ6jr/HYQwUksGYfGM9MKuZdm2ORSWJNYVNsc9lzxMGMqubJrBqx5lzmEckbESnYa1hDZKcC6J7zkSPTPsqVkRA/+X3JHAT81Vaz9l2lcQgSSheO/J1W+lMU3kZuEbI6VKnRlRkwWT/iPHxyO7yB/4LYNbnOtoexpiv53H5mwzpmAGNvTIjteVp6TRYLD6CF7vnT1dTsc7bmHUTHHc1NT61ZkFs= mohammed@alrokayan.com
runcmd:
  - sed -i.BACKUP '/#PermitRootLogin prohibit-password/c\PermitRootLogin yes' /etc/ssh/sshd_config
  - sed -i.BACKUP '/#PasswordAuthentication yes/c\PasswordAuthentication yes' /etc/ssh/sshd_config
  - sed -i.BACKUP '/KbdInteractiveAuthentication no/c\KbdInteractiveAuthentication yes' /etc/ssh/sshd_config
  - sed -i.BACKUP '/#   StrictHostKeyChecking ask/c\    StrictHostKeyChecking no' /etc/ssh/ssh_config
  - sed -i.BACKUP '/#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
  - sed -i.BACKUP '/#net.ipv6.conf.all.forwarding=1/c\net.ipv6.conf.all.forwarding=1' /etc/sysctl.conf
  - sed -i.BACKUP '/#DefaultTimeoutStopSec=90s/c\DefaultTimeoutStopSec=10s' /etc/systemd/system.conf
  - sed -i.BACKUP 's/GRUB_CMDLINE_LINUX_DEFAULT=\"/&usbcore.autosuspend=-1 /' /etc/default/grub
  - sed -i.BACKUP '/.*#DNSStubListener=.*/ c\DNSStubListener=no' /etc/systemd/resolved.conf
  - echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
  - echo 'alrokayan ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
  - update-grub
cloud_config_modules:
 - mounts
 - ssh
 - grub_dpkg
 - apt_update_upgrade
 - runcmd
disable_root: false
users:
  - default
  - name: alrokayan
    groups: users,admin,wheel,root,sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFKVH03XmRMoKjPVwpaNfi4cxR6FI9n6ZLojZ8aRFl6OTbH5hkjPU5Q9sZYGAucOVLdD4p85KsNFedFHljxP5oGXvRp2SM8H423Y6CaTG39f3gfru2jaHMRCMuSw4hcf70Jxvm7spYodoUL/dJVJCX6RK0EnQCyutD3L4evuviYv2bzl13z4meDiVREHg5M5HhW7ImGm4IGQwvUNaKYblblHDMHHgMp2Cc2aHGVq8TFj0xj7j64fvlCnjOvIB04/j3ZPeDGOGEw5YG0CrrqkHyTWgP7IczD20WUYG1jZ6jr/HYQwUksGYfGM9MKuZdm2ORSWJNYVNsc9lzxMGMqubJrBqx5lzmEckbESnYa1hDZKcC6J7zkSPTPsqVkRA/+X3JHAT81Vaz9l2lcQgSSheO/J1W+lMU3kZuEbI6VKnRlRkwWT/iPHxyO7yB/4LYNbnOtoexpiv53H5mwzpmAGNvTIjteVp6TRYLD6CF7vnT1dTsc7bmHUTHHc1NT61ZkFs= mohammed@alrokayan.com
    lock_passwd: false
    plain_text_passwd: MBS!985u
    shell: /bin/bash
locale: en_US.UTF-8
resize_rootfs: True
preserve_hostname: false
timezone: Asia/Riyadh
password: MBS!985u
chpasswd:
  expire: false
  users:
    - name: root
      password: MBS!985u
      type: text
    - name: ubuntu
      password: MBS!985u
      type: text
ssh_pwauth: True
ssh_genkeytypes: ['rsa']
EOF
multipass info $VM_HOSTNAME