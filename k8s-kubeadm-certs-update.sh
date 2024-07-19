#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#  
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# HOW TO:
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/k8s-kubeadm-certs-update.sh | bash -s -- 10.10.1.10 127.16.0.10 master master.example.com
# $1 Main IP
# $2 Extra IP/SAN
# $3 Extra IP/SAN
# $4 Extra IP/SAN
update-ca-certificates
rm -rf /etc/kubernetes/pki/*
kubeadm init phase certs all --apiserver-advertise-address $1 \
                             --apiserver-cert-extra-sans $2 \
                             --apiserver-cert-extra-sans $3 \
                             --apiserver-cert-extra-sans $4 \
                             --apiserver-cert-extra-sans localhost
rm -f /etc/kubernetes/admin.conf
kubeadm init phase kubeconfig admin --apiserver-advertise-address $1
rm -f ~/.kube/config
cp -i /etc/kubernetes/admin.conf ~/.kube/config
chown $(id -u):$(id -g) ~/.kube/config
chmod g+r ~/.kube/config
chmod go-r ~/.kube/config
