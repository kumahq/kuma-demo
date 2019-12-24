#!/bin/sh

set -e

# Set environment variables for the Node backend application:
export REDIS_HOST=127.0.0.1
export REDIS_PORT=26379
export ES_HOST=http://127.0.0.1:29200
export ES_TOTAL_OFFER=0

# Navigate to the backend directory
cd /home/vagrant/kuma-demo/backend

# Serve the application on localhost 
forever start index.js
