#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/random-mac-address.sh | bash -s
printf '00:2F:60:%02X:%02X:%02X\n' $(shuf -i 0-99 -n 1) $(shuf -i 101-199 -n 1) $(shuf -i 201-256 -n 1)