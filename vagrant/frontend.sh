#!/usr/bin/env bash

# set env variable
export VUE_APP_NODE_HOST="http://192.168.33.30:1000"

# Get latest version of node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

# Install node & build-essential (for make)
apt-get install -y nodejs build-essential

# Update npm
npm install npm -g

# Install yarn
# npm install -g yarn

# Vue CLI
# yarn add global @vue/cli
npm install -g @vue/cli

# Install Forever to run App in background
npm install forever http-server -g

# Navigate to backend directory
cd /home/vagrant/app

# Install dependencies
npm install

# Build application
npm run build

# Serve application
forever start -c http-server dist