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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/ha-passlist-gen.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/ha-passlist-gen.sh | bash -s
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "This script will generate passlist for zigbee2mqtt"
    exit 1
fi
NODE_RED_PATH="/host/volume1/data/docker-volumes/node-red/data"
ZIGBEE2MQTT_FOLDER="/host/volume1/data/kube-volumes"
ZIGBEE2MQTT_PATH="/host/volume1/data/kube-volumes/zigbee2mqtt"
GFS_PATH="root@10.10.1.10:/gfs/kube-volumes/zigbee2mqtt"
GFS_FOLDER="root@10.10.1.10:/gfs/kube-volumes"

rsync --exclude 'log.log' -avz -e $GFS_PATH $ZIGBEE2MQTT_FOLDER

cd $NODE_RED_PATH || exit
chmod -R 777 devices
chown -R "$USER:$USER" devices
rm -rf devices.BACKUP
cp -r devices devices.BACKUP
echo "$NODE_RED_PATH/devices.BACKUP created"

cd devices || exit

rm -rf -- */*/all.*
rm -rf -- */*/.DS_Store
rm -rf -- */.DS_Store
rm -rf .DS_Store

for building in *; do
  echo "-- BUILDING -- $building --"
  for coordinator in "$building"/*; do
    echo "-- COORDINATOR -- $coordinator --"
    for file in "$coordinator"/*.txt; do
      echo "-- FILE -- $file --"
      sort "$file" | uniq -u > "$file.uniq.txt"
      rm "$file"
      mv "$file.uniq.txt" "$file"
      echo "-- FILE -- $file -- is unique now --"
      cat "$file" >> "$coordinator/all.csv"
      echo "-- FILE -- $file -- added to $coordinator/all.csv --"
    done
    cut -d, -f1 "$coordinator/individual.csv" >> "$coordinator/all.csv"
    echo "-- FILE -- $coordinator/individual.csv -- added to $coordinator/all.csv --"
    sort "$coordinator/all.csv" | uniq -u > "$coordinator/all.uniq.csv"
    echo "-- FILE -- $coordinator/all.uniq.csv -- created --"
    sed -e "s/^/  - '/" "$coordinator/all.uniq.csv" > "$coordinator/tmp"
    sed -e "s/$/'/" "$coordinator/tmp" > "$coordinator/tmp2"
    # echo "passlist:" > $coordinator/all.passlist
    cat "$coordinator/tmp2" >> "$coordinator/all.passlist"
    rm -f "$coordinator/tmp"
    rm -f "$coordinator/tmp2"
    echo "-- FILE -- $coordinator/all.passlist -- created --"
    rm -f "$coordinator/all.csv"
    echo "-- FILE -- $coordinator/all.csv -- removed --"
    rm -f "$coordinator/all.uniq.csv"
    echo "-- FILE -- $coordinator/all.uniq.csv -- removed --"
  done
done

cd $ZIGBEE2MQTT_PATH/chalet/c1/data || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/chalet/c1/all.passlist >> configuration.yaml
echo "chalet's zigbee2mqtt configuration.yaml updated"

cd "$ZIGBEE2MQTT_PATH/dewaneah/c1/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/dewaneah/c1/all.passlist >> configuration.yaml
echo "dewaneah's zigbee2mqtt configuration.yaml updated"

cd "$ZIGBEE2MQTT_PATH/father/c1/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/father/c1/all.passlist >> configuration.yaml

cd "$ZIGBEE2MQTT_PATH/father/c2/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/father/c2/all.passlist >> configuration.yaml

cd "$ZIGBEE2MQTT_PATH/father/c3/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/father/c3/all.passlist >> configuration.yaml

cd "$ZIGBEE2MQTT_PATH/father/c4/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/father/c4/all.passlist >> configuration.yaml
echo "father's zigbee2mqtt configuration.yaml updated"

cd "$ZIGBEE2MQTT_PATH/majed/c1/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/majed/c1/all.passlist >> configuration.yaml

cd "$ZIGBEE2MQTT_PATH/majed/c2/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/majed/c2/all.passlist >> configuration.yaml

cd "$ZIGBEE2MQTT_PATH/majed/c3/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/majed/c3/all.passlist >> configuration.yaml

cd "$ZIGBEE2MQTT_PATH/majed/c4/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/majed/c4/all.passlist >> configuration.yaml

cd "$ZIGBEE2MQTT_PATH/majed/c5/data" || exit
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODE_RED_PATH/devices/majed/c5/all.passlist >> configuration.yaml
echo "majed's zigbee2mqtt configuration.yaml updated"

rsync --exclude 'log.log' -avz $ZIGBEE2MQTT_PATH -e $GFS_FOLDER
