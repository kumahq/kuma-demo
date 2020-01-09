#!/bin/sh

set -e

cat << "EOF"
oooooooooo.        .o.         .oooooo.   oooo    oooo oooooooooooo ooooo      ooo oooooooooo.   
`888'   `Y8b      .888.       d8P'  `Y8b  `888   .8P'  `888'     `8 `888b.     `8' `888'   `Y8b  
 888     888     .8"888.     888           888  d8'     888          8 `88b.    8   888      888 
 888oooo888'    .8' `888.    888           88888[       888oooo8     8   `88b.  8   888      888 
 888    `88b   .88ooo8888.   888           888`88b.     888    "     8     `88b.8   888      888 
 888    .88P  .8'     `888.  `88b    ooo   888  `88b.   888       o  8       `888   888     d88' 
o888bood8P'  o88o     o8888o  `Y8bood8P'  o888o  o888o o888ooooood8 o8o        `8  o888bood8P'   
EOF

# Install the latest version of Node
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
apt-get install -y nodejs

# Navigate to the backend directory
cd /home/vagrant/kuma-demo/backend-v1

# Install Forever to run App in background
npm install forever -g

# Install dependencies for the Node backend applicaiton
npm install
