#!/usr/bin/env bash

# Script Arguments
# $1 = kuma_cp_ip
# $2 = "#{box[:name]}"
# $3 = "#{box[:ip]}"
# $4 = "#{box[:local_port]}"

# Add to PATH
echo "export PATH=$PATH:/home/vagrant/kuma/bin" >> /home/vagrant/.bashrc

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
      url: http://$1:5681
  name: kuma-cp
currentContext: kuma-cp
" >> /home/vagrant/.kumactl/config

# Navigate to new direcotry
cd /home/vagrant/kuma

# Download Kuma
wget -nv https://kong.bintray.com/kuma/kuma-0.3.0-ubuntu-amd64.tar.gz

# Extract the archive
tar xvzf kuma-0.3.0-ubuntu-amd64.tar.gz

# generate on the client side
/home/vagrant/kuma/bin/kumactl generate tls-certificate \
--cert-file=/home/vagrant/kuma/certs/server/cert.pem \
--key-file=/home/vagrant/kuma/certs/server/key.pem \
--type=client

                                

/home/vagrant/kuma/bin/kumactl config control-planes add \
--name kuma-cp --address http://$1:5681 \
--dataplane-token-client-cert /home/vagrant/kuma/certs/server/cert.pem \
--dataplane-token-client-key /home/vagrant/kuma/certs/server/key.pem



# echo "type: Dataplane
# mesh: default
# name: dp-$2
# networking:
#   inbound:
#   - interface: $3:1000:$4
#     tags:
#       service: $2" | /home/vagrant/kuma/bin/kumactl apply -f -