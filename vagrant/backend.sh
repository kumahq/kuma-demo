#!/usr/bin/env bash

# Set env variables
export REDIS_HOST=192.168.33.50
export REDIS_PORT=1000
export ES_HOST=http://192.168.33.40:1000
# echo "
# export REDIS_HOST=http://192.168.33.50
# export REDIS_PORT=1000
# export ES_HOST=http://192.168.33.40:1000
# " >> /home/vagrant/.bashrc

# Get latest version of node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

# Install node & build-essential (for make)
apt-get install -y nodejs build-essential

# Update npm
npm install npm -g

# Install Forever to run App in background
npm install forever -g

# Navigate to backend directory
cd /home/vagrant/api

# Install dependencies
npm install

# Start application
forever start index.js
