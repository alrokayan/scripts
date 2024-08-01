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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./mac-install-fuse-ext2.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/mac-install-fuse-ext2.sh | bash -s
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "This script will install fuse-ext2 for mac"
    exit 0
fi
export PATH=/opt/gnu/bin:$PATH
export PKG_CONFIG_PATH=/opt/gnu/lib/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
mkdir fuse-ext2.build
cd fuse-ext2.build
if [ ! -d fuse-ext2 ]; then
    git clone https://github.com/alperakcan/fuse-ext2.git	
fi
# m4
if [ ! -f m4-1.4.17.tar.gz ]; then
    curl -O -L http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz
fi
tar -zxvf m4-1.4.17.tar.gz 
cd m4-1.4.17
./configure --prefix=/opt/gnu
make -j 16
sudo make install
cd ../
# autoconf
if [ ! -f autoconf-2.69.tar.gz ]; then
    curl -O -L http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
fi
tar -zxvf autoconf-2.69.tar.gz 
cd autoconf-2.69
./configure --prefix=/opt/gnu
make
sudo make install
cd ../
# automake
if [ ! -f automake-1.15.tar.gz ]; then
    curl -O -L http://ftp.gnu.org/gnu/automake/automake-1.15.tar.gz
fi
tar -zxvf automake-1.15.tar.gz 
cd automake-1.15
./configure --prefix=/opt/gnu
make
sudo make install
cd ../
# libtool
if [ ! -f libtool-2.4.6.tar.gz ]; then
    curl -O -L http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
fi
tar -zxvf libtool-2.4.6.tar.gz 
cd libtool-2.4.6
./configure --prefix=/opt/gnu
make
sudo make install
cd ../
# e2fsprogs
if [ ! -f e2fsprogs-1.43.4.tar.gz ]; then
    curl -O -L https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.43.4/e2fsprogs-1.43.4.tar.gz
fi
tar -zxvf e2fsprogs-1.43.4.tar.gz
cd e2fsprogs-1.43.4
./configure --prefix=/opt/gnu --disable-nls
make
sudo make install
sudo make install-libs
sudo cp /opt/gnu/lib/pkgconfig/* /usr/local/lib/pkgconfig
cd ../
# fuse-ext2
export PATH=/opt/gnu/bin:$PATH
export PKG_CONFIG_PATH=/opt/gnu/lib/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
cd fuse-ext2
./autogen.sh
CFLAGS="-idirafter/opt/gnu/include -idirafter/usr/local/include/osxfuse/" LDFLAGS="-L/opt/gnu/lib -L/usr/local/lib" ./configure
make
sudo make install

## TESTING
cd
dd if=/dev/zero of=/tmp/test-fs.ext4 bs=1024 count=102400  
/opt/gnu/sbin/mkfs.ext4 /tmp/test-fs.ext4
mkdir -p ~/mnt/fuse-ext2.test-fs.ext4
fuse-ext2 /tmp/test-fs.ext4 ~/mnt/fuse-ext2.test-fs.ext4 -o rw+,allow_other,uid=501,gid=20
