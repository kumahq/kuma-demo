#!/usr/bin/env bash

#!/usr/bin/env bash

# Update apt-get
apt-get update -y

# Update Ubuntu
apt-get -y upgrade
apt-get -y dist-upgrade

# Add repo
add-apt-repository -y ppa:chris-lea/redis-server
apt-get update
apt-get install -y redis-server

# Start Redis server in background
redis-server --daemonize yes --protected-mode no