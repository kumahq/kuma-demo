#!/bin/sh

set -e

cat << "EOF"
oooooooooooo ooooooooo.     .oooooo.   ooooo      ooo ooooooooooooo oooooooooooo ooooo      ooo oooooooooo.   
`888'     `8 `888   `Y88.  d8P'  `Y8b  `888b.     `8' 8'   888   `8 `888'     `8 `888b.     `8' `888'   `Y8b  
 888          888   .d88' 888      888  8 `88b.    8       888       888          8 `88b.    8   888      888 
 888oooo8     888ooo88P'  888      888  8   `88b.  8       888       888oooo8     8   `88b.  8   888      888 
 888    "     888`88b.    888      888  8     `88b.8       888       888    "     8     `88b.8   888      888 
 888          888  `88b.  `88b    d88'  8       `888       888       888       o  8       `888   888     d88' 
o888o        o888o  o888o  `Y8bood8P'  o8o        `8      o888o     o888ooooood8 o8o        `8  o888bood8P'   
EOF

# Install the latest version of Node
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
apt-get install -y nodejs

# Navigate to the frontend directory
cd /home/vagrant/kuma-demo/frontend

# Install dependencies to run the Vue app in background
npm install forever http-server @vue/cli -g

# Install dependencies for the Vue frontend applicaiton
npm install

# Build frontend application application
npm run build
