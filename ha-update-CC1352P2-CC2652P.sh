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
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/ha-update-CC1352P2-CC2652P.sh | bash -s -- 192.168.0.2
# $1 Adaptor IP
ADAPTOR_IP=$1
ADAPTOR_PORT=6638
FW_URL="https://github.com/Koenkk/Z-Stack-firmware/raw/master/coordinator/Z-Stack_3.x.0/bin/CC1352P2_CC2652P_launchpad_coordinator_20230507.zip"
CC2538CC_BSL_URL="https://raw.githubusercontent.com/JelmerT/cc2538-bsl/master/cc2538-bsl.py"
HEX_FILE_NAME="CC1352P2_CC2652P_launchpad_coordinator_20230507.hex"
rm -f fw.zip; rm -f $HEX_FILE_NAME
apt install unzip pip -y
curl -L $FW_URL -o "fw.zip"; unzip fw.zip
curl -L $CC2538CC_BSL_URL -o "cc2538-bsl.py"; chmod +x cc2538-bsl.py
pip3 install pyserial; pip3 install intelhex; pip3 install python-magic
echo "Please go to http://$ADAPTOR_IP and Trigger Zigbee Module Bootloader"
echo "Press any key to continue ..."
read -n 1 -s -r -p ""
echo "Flashing ..."
sleep 15s
./cc2538-bsl.py --bootloader-sonoff-usb -p socket://$ADAPTOR_IP:$ADAPTOR_PORT -evw ./$HEX_FILE_NAME
echo "Please power off the adaptor switch for 10 seconds then power it back on. Power cycle."
echo "Press any key to continue ..."
read -n 1 -s -r -p ""
