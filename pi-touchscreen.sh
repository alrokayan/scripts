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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/pi-touchscreen.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/pi-touchscreen.sh | bash -s
#ssh-copy-id pi@pi.local
#password: pi
#ssh pi@pi.local
#sudo su -
rm -rf LCD-show
git clone https://github.com/goodtft/LCD-show.git
chmod -R 755 LCD-show
cd LCD-show/
./MPI4008-show
## it will restart automatically
## To return back to HDMI
# cd LCD-show/
# ./LCD-hdmi
ssh pi@pi.local
sudo su -
cd LCD-show/
dpkg -i -B xserver-xorg-input-evdev_1%3a2.10.6-2_arm64.deb
dpkg -i -B xinput-calibrator_0.7.5+git20140201-1+b2_arm64.deb
cp -rf /usr/share/X11/xorg.conf.d/10-evdev.conf /usr/share/X11/xorg.conf.d/45-evdev.conf
nano /etc/X11/xorg.conf.d/99-calibration.conf
## Change the “SwapAxes” “1” into “SwapAxes” “0"
reboot