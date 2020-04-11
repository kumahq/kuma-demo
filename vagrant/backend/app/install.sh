#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

  ____    _    ____ _  _______ _   _ ____  
 | __ )  / \  / ___| |/ / ____| \ | |  _ \ 
 |  _ \ / _ \| |   | ' /|  _| |  \| | | | |
 | |_) / ___ \ |___| . \| |___| |\  | |_| |
 |____/_/   \_\____|_|\_\_____|_| \_|____/ 
                                                      
EOF

# Install the latest version of Node
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
apt-get install -y -q nodejs

# Navigate to the backend directory
cd /home/vagrant/kuma-demo/backend

# Install Forever to run App in background
npm install forever -g

# Install dependencies for the Node backend applicaiton
npm install
