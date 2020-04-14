#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

  _  _____  _   _  ____     ____    _  _____ _______        ___ __   __
 | |/ / _ \| \ | |/ ___|   / ___|  / \|_   _| ____\ \      / / \\ \ / /
 | ' / | | |  \| | |  _   | |  _  / _ \ | | |  _|  \ \ /\ / / _ \\ V / 
 | . \ |_| | |\  | |_| |  | |_| |/ ___ \| | | |___  \ V  V / ___ \| |  
 |_|\_\___/|_| \_|\____|   \____/_/   \_\_| |_____|  \_/\_/_/   \_\_|  
                                                                       
EOF

apt-get update -y -q
apt-get install -y -q apt-transport-https curl lsb-core
echo "deb https://kong.bintray.com/kong-deb `lsb_release -sc` main" | sudo tee -a /etc/apt/sources.list
curl -o bintray.key https://bintray.com/user/downloadSubjectPublicKey?username=bintray
apt-key add bintray.key
apt-get update -y -q
apt-get install -y -q kong
