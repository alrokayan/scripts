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
# rm -r scripts && git clone https://github.com/alrokayan/scripts.git && cd scripts && chmod +x * && ./disk-test.sh /mnt
# OR
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/disk-test.sh | bash -s -- /mnt
# $1 Path to test
if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 <Path to test>"
    echo "EXAMPLE: $0 /mnt"
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "This script will test the disk speed"
        exit 0
    fi
    exit 1
fi
TEST_RESULTS_FOLDER="/tmp/Disk-Test-Results/$(date +%Y_%m_%d_%H_%M)/"
mkdir -p "$TEST_RESULTS_FOLDER"
echo "Testing $1 ..."
TEST_RESULT_FILE="$(echo "$1" | tr / _)_TEST_RESULT.txt"
cd "$1" || exit
fio --ramp_time=5 \
    --gtod_reduce=1 \
    --numjobs=1 \
    --bs=1M \
    --size=1G \
    --runtime=60s \
    --readwrite=readwrite \
    --name=testfile  > "$TEST_RESULTS_FOLDER$TEST_RESULT_FILE"
    echo "
###################################
####### $(pwd) #######
###################################" >> "$TEST_RESULTS_FOLDER/SUMMARY.txt"
grep -e READ -e WRITE "$TEST_RESULTS_FOLDER$TEST_RESULT_FILE" >> "$TEST_RESULTS_FOLDER/SUMMARY.txt"
echo "
##############################
########## SUMMARY ###########
##############################"
cat "${TEST_RESULTS_FOLDER}SUMMARY.txt"
echo "Do you want to delete the test files? [y/N]"
read -r DELETE_TEST_FILES
if [ "$DELETE_TEST_FILES" == "y" ]; then
    rm -rf "$1/testfile*"
fi
