#!/usr/bin/env bash

# Script Arguments
# $1 = kuma_cp_ip
# $2 = "#{box[:name]}"
# $3 = "#{box[:ip]}"
# $4 = "#{box[:local_port]}"

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
echo "type: Dataplane
mesh: default
name: $2
networking:
  inbound:
  - interface: $3:1000:$4
    tags:
      service: $2" | /home/vagrant/kuma/bin/kumactl apply -f -

# start Dataplane
touch /etc/systemd/system/kuma-dp.service
cat > /etc/systemd/system/kuma-dp.service <<EOL
[Service]
ConditionPathExists=/home/vagrant/kuma/certs/kuma-dp/$2/token
Environment=KUMA_DATAPLANE_MESH=default
Environment=KUMA_DATAPLANE_NAME=$2
Environment=KUMA_CONTROL_PLANE_API_SERVER_URL=http://kuma-cp:5681
Environment=KUMA_DATAPLANE_RUNTIME_TOKEN_PATH=/home/vagrant/kuma/certs/kuma-dp/$2/token
ExecStart=/home/vagrant/kuma/bin/kuma-dp run
EOL

systemctl start kuma-dp
systemctl status kuma-dp