#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

  ____    _    ____ _  _______ _   _ ____            _ 
 | __ )  / \  / ___| |/ / ____| \ | |  _ \  __   __ / |
 |  _ \ / _ \| |   | ' /|  _| |  \| | | | | \ \ / / | |
 | |_) / ___ \ |___| . \| |___| |\  | |_| |  \ V /  | |
 |____/_/   \_\____|_|\_\_____|_| \_|____/    \_/   |_|
                                                                                                                                                              
EOF

# Install the latest version of Node
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
apt-get install -y -q nodejs

# Navigate to the backend directory
cd /home/vagrant/kuma-demo/backend-v1

# Install Forever to run App in background
npm install forever -g

# Install dependencies for the Node backend applicaiton
npm install
