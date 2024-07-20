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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./ha-passlist-gen.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/ha-passlist-gen.sh | bash -s

NODERED_PATH="/volume1/data/docker-volumes/node-red/data"
ZIGBEE2MQTT_PATH="/volume1/data/kube-volumes/zigbee2mqtt"
cd $NODERED_PATH
chmod -R 777 devices
chown -R $USER:$USER devices
rm -rf devices.BACKUP
cp -r devices devices.BACKUP
echo "$NODERED_PATH/devices.BACKUP created"

cd devices

rm -rf */*/all.*
rm -rf */*/.DS_Store
rm -rf */.DS_Store
rm -rf .DS_Store

for building in *; do
  echo "-- BUILDING -- $building --"
  for cooridnator in $building/*; do
    echo "-- COORDINATOR -- $cooridnator --"
    for file in $cooridnator/*.txt; do
      echo "-- FILE -- $file --"
      sort $file | uniq -u > $file.uniq.txt
      rm $file
      mv $file.uniq.txt $file
      echo "-- FILE -- $file -- is unique now --"
      cat $file >> $cooridnator/all.csv
      echo "-- FILE -- $file -- added to $cooridnator/all.csv --"
    done
    cat $cooridnator/individual.csv | cut -d, -f1 >> $cooridnator/all.csv
    echo "-- FILE -- $cooridnator/individual.csv -- added to $cooridnator/all.csv --"
    sort $cooridnator/all.csv | uniq -u > $cooridnator/all.uniq.csv
    echo "-- FILE -- $cooridnator/all.uniq.csv -- created --"
    sed -e "s/^/  - '/" $cooridnator/all.uniq.csv > $cooridnator/tmp
    sed -e "s/$/'/" $cooridnator/tmp > $cooridnator/tmp2
    # echo "passlist:" > $cooridnator/all.passlist
    cat $cooridnator/tmp2 >> $cooridnator/all.passlist
    rm -f $cooridnator/tmp
    rm -f $cooridnator/tmp2
    echo "-- FILE -- $cooridnator/all.passlist -- created --"
    rm -f $cooridnator/all.csv
    echo "-- FILE -- $cooridnator/all.csv -- removed --"
    rm -f $cooridnator/all.uniq.csv
    echo "-- FILE -- $cooridnator/all.uniq.csv -- removed --"
  done
done

cd $ZIGBEE2MQTT_PATH/chalet/c1/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/chalet/c1/all.passlist >> configuration.yaml
echo "chalet's zigbee2mqtt configuration.yaml updated"

cd $ZIGBEE2MQTT_PATH/dewaneah/c1/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/dewaneah/c1/all.passlist >> configuration.yaml
echo "dewaneah's zigbee2mqtt configuration.yaml updated"

cd $ZIGBEE2MQTT_PATH/father/c1/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/father/c1/all.passlist >> configuration.yaml

cd $ZIGBEE2MQTT_PATH/father/c2/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/father/c2/all.passlist >> configuration.yaml

cd $ZIGBEE2MQTT_PATH/father/c3/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/father/c3/all.passlist >> configuration.yaml

cd $ZIGBEE2MQTT_PATH/father/c4/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/father/c4/all.passlist >> configuration.yaml
echo "father's zigbee2mqtt configuration.yaml updated"

cd $ZIGBEE2MQTT_PATH/majed/c1/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/majed/c1/all.passlist >> configuration.yaml

cd $ZIGBEE2MQTT_PATH/majed/c2/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/majed/c2/all.passlist >> configuration.yaml

cd $ZIGBEE2MQTT_PATH/majed/c3/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/majed/c3/all.passlist >> configuration.yaml

cd $ZIGBEE2MQTT_PATH/majed/c4/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/majed/c4/all.passlist >> configuration.yaml

cd $ZIGBEE2MQTT_PATH/majed/c5/data
cp configuration.yaml configuration.yaml.BACKUP
sed '/passlist:/q' -i configuration.yaml
cat $NODERED_PATH/devices/majed/c5/all.passlist >> configuration.yaml
echo "majed's zigbee2mqtt configuration.yaml updated"
