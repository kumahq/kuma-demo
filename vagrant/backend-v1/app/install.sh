#!/bin/sh

set -e

cat << "EOF"

 ____    _    ____ _  _______ _   _ ____   __     __  _ 
| __ )  / \  / ___| |/ / ____| \ | |  _ \  \ \   / / / |
|  _ \ / _ \| |   | ' /|  _| |  \| | | | |  \ \ / /  | |
| |_) / ___ \ |___| . \| |___| |\  | |_| |   \ V /   | |
|____/_/   \_\____|_|\_\_____|_| \_|____/     \_/    |_|
                                                        
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
