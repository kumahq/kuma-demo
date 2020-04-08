#!/bin/sh

set -e

cat << "EOF"
 _  _____  _   _  ____ 
| |/ / _ \| \ | |/ ___|
| ' / | | |  \| | |  _ 
| . \ |_| | |\  | |_| |
|_|\_\___/|_| \_|\____|
                       
EOF

apt-get update -y -q
apt-get install -y -q apt-transport-https curl lsb-core
echo "deb https://kong.bintray.com/kong-deb `lsb_release -sc` main" | sudo tee -a /etc/apt/sources.list
curl -o bintray.key https://bintray.com/user/downloadSubjectPublicKey?username=bintray
apt-key add bintray.key
apt-get update -y -q
apt-get install -y -q kong
