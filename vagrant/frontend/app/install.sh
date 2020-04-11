#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

  _____ ____   ___  _   _ _____ _____ _   _ ____  
 |  ___|  _ \ / _ \| \ | |_   _| ____| \ | |  _ \ 
 | |_  | |_) | | | |  \| | | | |  _| |  \| | | | |
 |  _| |  _ <| |_| | |\  | | | | |___| |\  | |_| |
 |_|   |_| \_\\___/|_| \_| |_| |_____|_| \_|____/ 
                                                                                                 
EOF

# Install the latest version of Node
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
apt-get install -y -q nodejs

# Install dependencies to run the Vue app in background
npm install -g forever http-server
