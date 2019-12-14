#!/bin/bash

cat << "EOF"
oooooooooo.        .o.         .oooooo.   oooo    oooo oooooooooooo ooooo      ooo oooooooooo.   
`888'   `Y8b      .888.       d8P'  `Y8b  `888   .8P'  `888'     `8 `888b.     `8' `888'   `Y8b  
 888     888     .8"888.     888           888  d8'     888          8 `88b.    8   888      888 
 888oooo888'    .8' `888.    888           88888[       888oooo8     8   `88b.  8   888      888 
 888    `88b   .88ooo8888.   888           888`88b.     888    "     8     `88b.8   888      888 
 888    .88P  .8'     `888.  `88b    ooo   888  `88b.   888       o  8       `888   888     d88' 
o888bood8P'  o88o     o8888o  `Y8bood8P'  o888o  o888o o888ooooood8 o8o        `8  o888bood8P'   
EOF

# Set environment variables for the Node.js backend application:
export REDIS_HOST=127.0.0.1
export REDIS_PORT=26379
export ES_HOST=http://127.0.0.1:29200
export ES_TOTAL_OFFER=0

# Download the latest version of Node
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -

# Install Node & build-essential (for make)
apt-get install -y nodejs build-essential

# Update npm
npm install npm -g

# Install Forever to run App in background
npm install forever -g

# Navigate to backend directory
cd /home/vagrant/api

# Install dependencies for the application
npm install

# Start backend application
forever start index.js