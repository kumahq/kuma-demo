#!/usr/bin/env bash

# Set env variables
export REDIS_HOST=127.0.0.1
export REDIS_PORT=26379
export ES_HOST=http://127.0.0.1:29200
export ES_TOTAL_OFFER=0

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

# Add to PATH
export PATH=$PATH:/home/vagrant/kuma/bin
echo "export PATH=$PATH:/home/vagrant/kuma/bin" >> /home/vagrant/.bashrc

# Adding Kuma-cp to /etc/hosts
echo "
192.168.33.10 kuma-cp
" >> /etc/hosts

# Navigate to new direcotry
cd /home/vagrant/kuma

# Download Kuma
wget -nv https://kong.bintray.com/kuma/kuma-0.3.0-ubuntu-amd64.tar.gz

# Extract the archive
tar xvzf kuma-0.3.0-ubuntu-amd64.tar.gz

kumactl config control-planes add --name=universal --address=http://kuma-cp:5681 --overwrite

# create Dataplane (update in future)
echo "mesh: default
name: backend
networking:
  inbound:
  - interface: 192.168.33.30:13001:3001
    tags:
      service: backend
      version: v0
  outbound:
  - interface: :26379
    service: redis
  - interface: :29200
    service: elastic
type: Dataplane" | /home/vagrant/kuma/bin/kumactl apply -f -

# start Dataplane
touch /etc/systemd/system/kuma-dp.service
cat > /etc/systemd/system/kuma-dp.service <<EOL
[Service]
ConditionPathExists=/home/vagrant/kuma/certs/kuma-dp/backend/token
Environment=KUMA_DATAPLANE_MESH=default
Environment=KUMA_DATAPLANE_NAME=backend
Environment=KUMA_CONTROL_PLANE_API_SERVER_URL=http://kuma-cp:5681
Environment=KUMA_DATAPLANE_RUNTIME_TOKEN_PATH=/home/vagrant/kuma/certs/kuma-dp/backend/token
ExecStart=/home/vagrant/kuma/bin/kuma-dp run --admin-port=9901
EOL

systemctl start kuma-dp
systemctl status kuma-dp