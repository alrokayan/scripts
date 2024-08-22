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
# rm -rf scripts ; git clone https://github.com/alrokayan/scripts.git && chmod +x scripts/* && ./scripts/ha-dashboard-gen.sh
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/ha-dashboard-gen.sh | bash -s
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "This script will generate a dashboard for Home Assistant"
    exit 1
fi
DASHBAORD="MAJED"
ROOMS=("GF Living" "Dining" "Daily Seating" "Main Kitchen" "Open Kitchen" "F1" "Master" "Room" "F2" "Playroom" "Maid" "Outdoor")
echo "title: $DASHBAORD
views:
  - type: sections
    sections:" > $DASHBAORD.yaml

for r in "${ROOMS[@]}"; do
    echo "      - type: grid
        cards:
          - type: custom:auto-entities
            filter:
              include:
                - name: $r*
                  or:
                    - entity_id: light.homekit*
                    - entity_id: cover.homekit*
                    - entity_id: scene.homekit*
                    - entity_id: climate.homekit*
                    - entity_id: switch.homekit*_outlet1
                    - entity_id: switch.homekit*_poe
                    - entity_id: binary_sensor.homekit*_smoke
                    - entity_id: binary_sensor.homekit*_occupancy
                    - entity_id: binary_sensor.homekit*_water_leak
                    - entity_id: input_button.homekit*
                    - entity_id: button.homekit*
                    - entity_id: fan.homekit*
            card:
              type: entities
              state_color: true
            show_empty: true
        title: $r" >> $DASHBAORD.yaml                
done
echo '      - type: grid
        cards:
          - type: custom:auto-entities
            filter:
              include:
                - entity_id: "*outlet*"
                  not:
                    name: ""
                  and:' >> $DASHBAORD.yaml
for r in "${ROOMS[@]}"; do
    echo "                    - not:
                        name: $r*" >> $DASHBAORD.yaml
done
echo "            card:
              type: entities
              state_color: true
              title: Meross
            show_empty: true
        title: Uncategorized
    title: $DASHBAORD
    icon: mdi:home
    cards: []
  - type: sections
    sections:
      - type: grid
        cards:
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.majed_5_majed_5
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.majed_3_majed_3
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.majed_4_majed_4
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.chalet_2_chalet_2
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.chalet_1_chalet_1
        title: North
      - type: grid
        cards:
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.majed_2_majed_2
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.majed_1_majed_1
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.dewaneah_4_dewaneah_4
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.dewaneah_3_dewaneah_3
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.dewaneah_2_dewaneah_2
        title: East
      - type: grid
        cards:
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.father_1_father_1
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.father_3_father_3
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.father_2_father_2
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.father_5_father_5
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.father_4_father_4
        title: South
      - type: grid
        cards:
          - show_state: false
            show_name: true
            camera_view: auto
            type: picture-entity
            entity: camera.dewaneah_1_dewaneah_1
        title: Inner
    title: CCTV
    icon: mdi:cctv
    path: cctv
    cards: []
  - icon: mdi:battery
    title: Batteries
    path: batteries
    cards:" >> $DASHBAORD.yaml
for r in "${ROOMS[@]}"; do
    echo "      - type: custom:auto-entities
        filter:
          include:
            - entity_id: '*battery*'
              name: $r*
        card:
          type: entities
          state_color: true
          title: $r
        show_empty: true" >> $DASHBAORD.yaml
done
echo '      - type: custom:auto-entities
        filter:
          include:
            - entity_id: "*battery*"
              and:' >> $DASHBAORD.yaml
for r in "${ROOMS[@]}"; do
    echo "                - not:
                    name: $r*" >> $DASHBAORD.yaml
done
echo '        show_empty: true
        card:
          type: custom:fold-entity-row
          padding: 0
          head:
            icon: mdi:battery
            type: section
            label: Others' >> $DASHBAORD.yaml