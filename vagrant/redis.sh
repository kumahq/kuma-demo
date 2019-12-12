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

# KUMA-DP

# Add to PATH
export PATH=$PATH:/home/vagrant/kuma/bin
echo "export PATH=$PATH:/home/vagrant/kuma/bin" >> /home/vagrant/.bashrc

# Adding Kuma-cp to /etc/hosts
echo "
192.168.33.10 kuma-cp
" >> /etc/hosts

mkdir /home/vagrant/.kumactl && touch /home/vagrant/.kumactl/config

echo "
contexts:
- controlPlane: local
  name: local
- controlPlane: kuma-cp
  credentials:
    dataplaneTokenApi: {}
  name: kuma-cp
controlPlanes:
- coordinates:
    apiServer:
      url: http://localhost:5681
  name: local
- coordinates:
    apiServer:
      url: http://kuma-cp:5681
  name: kuma-cp
currentContext: kuma-cp
" >> /home/vagrant/.kumactl/config

# Navigate to new direcotry
cd /home/vagrant/kuma

# Download Kuma
wget -nv https://kong.bintray.com/kuma/kuma-0.3.0-ubuntu-amd64.tar.gz

# Extract the archive
tar xvzf kuma-0.3.0-ubuntu-amd64.tar.gz

kumactl config control-planes add --name=universal --address=http://kuma-cp:5681 --overwrite

# create Dataplane (update in future)
echo "mesh: default
name: redis
networking:
  inbound:
  - interface: 192.168.33.50:16379:6379
    tags:
      service: redis
type: Dataplane" | /home/vagrant/kuma/bin/kumactl apply -f -

### Start Dataplane (moved into the README so people can see how to do it)
# touch /etc/systemd/system/kuma-dp.service
# cat > /etc/systemd/system/kuma-dp.service <<EOL
# [Service]
# ConditionPathExists=/home/vagrant/kuma/certs/kuma-dp/redis/token
# Environment=KUMA_DATAPLANE_MESH=default
# Environment=KUMA_DATAPLANE_NAME=redis
# Environment=KUMA_CONTROL_PLANE_API_SERVER_URL=http://kuma-cp:5681
# Environment=KUMA_DATAPLANE_RUNTIME_TOKEN_PATH=/home/vagrant/kuma/certs/kuma-dp/redis/token
# ExecStart=/home/vagrant/kuma/bin/kuma-dp run --admin-port=9901
# EOL

# systemctl start kuma-dp
# systemctl status kuma-dp