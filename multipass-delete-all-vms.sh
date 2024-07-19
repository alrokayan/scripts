#!/bin/bash
# curl -fL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/alrokayan/scripts/main/multipass-delete-all-vms.sh | bash -s
multipass delete --purge --all
