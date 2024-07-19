#!/bin/bash
# curl -fL https://raw.githubusercontent.com/alrokayan/scripts/main/kasm-install.sh | bash -s -- PASSWORD
# $1 Password
export KASM_UID=$(id kasm -u)
export KASM_GID=$(id kasm -g)
echo "-- Deleting Kasm containers"
/opt/kasm/current/bin/stop
echo "-- Downloading Kasm in /tmp"
cd /tmp
rm -f kasm.tar.gz
curl -L https://kasm-static-content.s3.amazonaws.com/kasm_release_1.15.0.06fdc8.tar.gz -o kasm.tar.gz
rm -rf kasm_release
tar -xf kasm.tar.gz 
export IP=$(hostname -I | awk '{print $1}')
export PORT=10443
export KASM_PASSWORD=$1
echo "-- Installing Kasm on $IP:$PORT (SSL)"
mkdir -p /opt/Kasm
./kasm_release/install.sh  noninteractive \
                          --slim-images \
                          --admin-password $KASM_PASSWORD \
                          --user-password $KASM_PASSWORD \
                          --accept-eula \
                          --default-images \
                          --proxy-port $PORT

echo "-- SETUP KASM: https://$IP:3000 (TEMPORARY)"
echo "-------------------------------------------"
echo "-- Login: https://$IP:$PORT"
echo "-- Username: admin@kasm.local"
echo "-- Password: $KASM_PASSWORD"
echo ""
echo "-- Login: https://$IP:$PORT"
echo "-- Username: user@kasm.local"
echo "-- Password: $KASM_PASSWORD"


