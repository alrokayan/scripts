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

# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/disk-test.sh | bash -s -- /mnt /root
# $1 Path to test
# $2 Path to save
TESTRESULTS_FOLDER="$2/Disk-Test-Results/$(date +%Y_%m_%d_%H_%M)/"
TEST_LOCATIONS=$1
mkdir -p $TESTRESULTS_FOLDER
for i in "${TEST_LOCATIONS[@]}"; do
    echo "Testing /mnt/$i ..."
    (
    TESTRESULT_FILE=$(echo "/mnt/$i" | tr / _)_TESTRESULT.txt
    cd /mnt/$i
    fio --ramp_time=5 \
        --gtod_reduce=1 \
        --numjobs=1 \
        --bs=1M \
        --size=1G \
        --runtime=60s \
        --readwrite=readwrite \
        --name=testfile  > $TESTRESULTS_FOLDER$TESTRESULT_FILE
        echo "
###################################
####### $(pwd) #######
###################################" >> $TESTRESULTS_FOLDER/SUMMARY.txt
    cat $TESTRESULTS_FOLDER$TESTRESULT_FILE | grep -e READ -e WRITE >> $TESTRESULTS_FOLDER/SUMMARY.txt
    ) &
done
echo "
##############################
########## SUMNMARY ##########
##############################"
cat ${TESTRESULTS_FOLDER}SUMMARY.txt

echo "Do you want to delete the test files? [y/N]"
read DELETE_TEST_FILES
if [ "$DELETE_TEST_FILES" == "y" ]; then
    for i in "${TEST_LOCATIONS[@]}"; do
        rm -rf $i/testfile*
    done
fi
