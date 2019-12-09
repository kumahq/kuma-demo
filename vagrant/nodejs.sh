#!/usr/bin/env bash

# Update apt-get
apt-get update -y

# Update Ubuntu
# apt-get -y upgrade
# apt-get -y dist-upgrade

# Get latest version of node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

# Install node & build-essential (for make)
apt-get install -y nodejs build-essential

# Update npm
npm install npm -g

# Install yarn
npm install -g yarn

# Install Forever to run App in background
npm install forever -g

# Navigate to backend directory
cd /home/vagrant/kuma-demo-app/api

# Install dependencies
npm install

# Start application
npm start

