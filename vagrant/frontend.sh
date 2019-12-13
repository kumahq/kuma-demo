#!/usr/bin/env bash

# set env variable
export VUE_APP_ES_ENDPOINT=
export VUE_APP_REDIS_ENDPOINT=

# Get latest version of node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

# Install node & build-essential (for make)
apt-get install -y nodejs build-essential

# Update npm
npm install npm -g

# Vue CLI
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
forever start -c http-server dist -P http://127.0.0.1:23001

# KUMA-DP

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
name: frontend
networking:
  inbound:
  - interface: 192.168.33.20:18080:8080
    tags:
      service: frontend
  outbound:
  - interface: :23001
    service: backend
type: Dataplane" | /home/vagrant/kuma/bin/kumactl apply -f -

# start Dataplane
touch /etc/systemd/system/kuma-dp.service
cat > /etc/systemd/system/kuma-dp.service <<EOL
[Service]
ConditionPathExists=/home/vagrant/kuma/certs/kuma-dp/frontend/token
Environment=KUMA_DATAPLANE_MESH=default
Environment=KUMA_DATAPLANE_NAME=frontend
Environment=KUMA_CONTROL_PLANE_API_SERVER_URL=http://kuma-cp:5681
Environment=KUMA_DATAPLANE_RUNTIME_TOKEN_PATH=/home/vagrant/kuma/certs/kuma-dp/frontend/token
ExecStart=/home/vagrant/kuma/bin/kuma-dp run --admin-port=9901
EOL

systemctl start kuma-dp
systemctl status kuma-dp