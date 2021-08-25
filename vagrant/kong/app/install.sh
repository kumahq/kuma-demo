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
echo "deb [trusted=yes] https://download.konghq.com/gateway-2.x-ubuntu-$(lsb_release -sc)/ default all" | sudo tee /etc/apt/sources.list.d/kong.list 
apt-get update -y -q
apt-get install -y -q kong
