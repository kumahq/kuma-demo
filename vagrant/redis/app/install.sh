#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

  ____  _____ ____ ___ ____  
 |  _ \| ____|  _ \_ _/ ___| 
 | |_) |  _| | | | | |\___ \ 
 |  _ <| |___| |_| | | ___) |
 |_| \_\_____|____/___|____/ 
                                                                            
EOF

# Update your system with unsupported packages
add-apt-repository -y ppa:chris-lea/redis-server
apt-get update -y -q

# Install the Redis package
apt-get install -y -q redis-server

# Create a new version of the redis.conf file
cp /etc/redis/redis.conf /etc/redis/redis.conf.old
cat /etc/redis/redis.conf.old | grep -v bind > /etc/redis/redis.conf

# Configure Redis to listen on localhost only
echo "bind 127.0.0.1" >> /etc/redis/redis.conf

# Ensure the `redis-server` service starts whenever the system boots
systemctl enable redis-server.service

# Start `redis-server` service right away
systemctl start redis-server.service
