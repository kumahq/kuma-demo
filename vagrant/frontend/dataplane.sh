#!/bin/bash

# Add Kuma to PATH to make it easier to use `kumactl`
export PATH=$PATH:/home/vagrant/kuma/bin
echo "export PATH=$PATH:/home/vagrant/kuma/bin" >> /home/vagrant/.bashrc

# Adding Kuma-cp to /etc/hosts
echo "
192.168.33.10 kuma-cp
" >> /etc/hosts

# Navigate to the Kuma direcotry
cd /home/vagrant/kuma

# Download latest version of Kuma for Ubuntu, please check out https://kuma.io/install for more options
wget -nv https://kong.bintray.com/kuma/kuma-0.3.1-ubuntu-amd64.tar.gz

# Extract the Kuma archive
tar xvzf kuma-0.3.1-ubuntu-amd64.tar.gz

# Using kumactl which was in the archive, set the virtual machine `kuma-cp` as the main control-plane
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
type: Dataplane" | kumactl apply -f -

# Create a service unit file for Kuma's dataplane
touch /etc/systemd/system/kuma-dp.service

# Add the following configurations to the service file
cat > /etc/systemd/system/kuma-dp.service <<EOL
[Service]
ConditionPathExists=/home/vagrant/kuma/certs/kuma-dp/frontend/token
Environment=KUMA_DATAPLANE_MESH=default
Environment=KUMA_DATAPLANE_NAME=frontend
Environment=KUMA_CONTROL_PLANE_API_SERVER_URL=http://kuma-cp:5681
Environment=KUMA_DATAPLANE_RUNTIME_TOKEN_PATH=/home/vagrant/kuma/certs/kuma-dp/frontend/token
ExecStart=/home/vagrant/kuma/bin/kuma-dp run --admin-port=9901
EOL

# Start the `kuma-dp` service on the local machine
systemctl start kuma-dp