#!/bin/sh

set -e

# Set environment variables for the Node backend application:
export SPECIAL_OFFER=false
export REDIS_HOST=127.0.0.1
export REDIS_PORT=26379
export POSTGRES_USER=kumademo
export POSTGRES_PASSWORD=kumademo
export POSTGRES_DB=kumademo
export POSTGRES_HOST=127.0.0.1
export POSTGRES_PORT_NUM=25432

# Navigate to the backend directory
cd /home/vagrant/kuma-demo/backend

# Serve the application on localhost 
forever start index.js
