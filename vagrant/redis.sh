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
# redis-server --daemonize yes --protected-mode no

sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.old
sudo cat /etc/redis/redis.conf.old | grep -v bind > /etc/redis/redis.conf
sudo cat /etc/redis/redis.conf
echo "bind 127.0.0.1" >> /etc/redis/redis.conf
sudo cat /etc/redis/redis.conf
sudo update-rc.d redis-server defaults
sudo /etc/init.d/redis-server start
