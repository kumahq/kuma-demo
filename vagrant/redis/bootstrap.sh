#!/bin/bash

cat << "EOF"
ooooooooo.   oooooooooooo oooooooooo.   ooooo  .oooooo..o 
`888   `Y88. `888'     `8 `888'   `Y8b  `888' d8P'    `Y8 
 888   .d88'  888          888      888  888  Y88bo.      
 888ooo88P'   888oooo8     888      888  888   `"Y8888o.  
 888`88b.     888    "     888      888  888       `"Y88b 
 888  `88b.   888       o  888     d88'  888  oo     .d8P 
o888o  o888o o888ooooood8 o888bood8P'   o888o 8""88888P'  
EOF

# Update your system with unsupported packages
add-apt-repository -y ppa:chris-lea/redis-server
apt-get update

# Install the Redis package
apt-get install -y redis-server

# Create a new version of the redis.conf file
sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.old
sudo cat /etc/redis/redis.conf.old | grep -v bind > /etc/redis/redis.conf

# Add to config of Redis
echo "bind 127.0.0.1" >> /etc/redis/redis.conf

# Update the redis-server
sudo update-rc.d redis-server defaults

# Star the redis-server
sudo /etc/init.d/redis-server start
