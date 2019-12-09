#!/usr/bin/env bash

# Add variables
echo "export PATH=$PATH:/home/vagrant/kuma/bin" >> /home/vagrant/.bashrc
# KUMA_GENERAL_ADVERTISED_HOSTNAME=kuma-cp \
# KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_ENABLED=true \
# KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_INTERFACE=0.0.0.0 \
# KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_PORT=5684 \

# echo "##################################"
# echo $KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_PORT
# echo "##################################"

# directory for certs and kuma
mkdir -p /home/vagrant/kuma/certs/server/ 

# create systemd file
touch /etc/systemd/system/kuma.service
cat > /etc/systemd/system/kuma.service <<EOL
[Service]
ExecStart=/home/vagrant/kuma/bin/kuma-cp run
EOL

# cat > /etc/systemd/system/kuma.service <<EOL
# [Service]
# ExecStart=/home/vagrant/kuma/bin/kuma-cp run --KUMA_GENERAL_ADVERTISED_HOSTNAME=kuma-cp \
#                                              --KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_ENABLED=true \
#                                              --KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_INTERFACE=0.0.0.0 \
#                                              --KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_PORT=5684 \
#                                              --KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_TLS_CERT_FILE=/home/vagrant/kuma/certs/server/cert.pem \
#                                              --KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_TLS_KEY_FILE=/home/vagrant/kuma/certs/server/key.pem
# EOL

# Navigate to new direcotry
cd /home/vagrant/kuma

# Download Kuma
wget -nv https://kong.bintray.com/kuma/kuma-0.3.0-ubuntu-amd64.tar.gz

# Extract the archive
tar xvzf kuma-0.3.0-ubuntu-amd64.tar.gz


# generate the key file
/home/vagrant/kuma/bin/kumactl generate tls-certificate \
--cert-file=/home/vagrant/kuma/certs/server/cert.pem \
--key-file=/home/vagrant/kuma/certs/server/key.pem \
--type=server \
--cp-hostname=kuma-cp


# Start kuma-cp service
systemctl start kuma
systemctl status kuma

# # generate the key file
# /home/vagrant/kuma/bin/kumactl generate tls-certificate \
# --cert-file=/home/vagrant/kuma/certs/server/cert.pem \
# --key-file=/home/vagrant/kuma/certs/server/key.pem \
# --type=server \
# --cp-hostname=kuma-cp

# echo "type: Dataplane
# mesh: default
# name: dp-backend
# networking:
#   inbound:
#   - interface: 192.168.33.30:3001:9000
#     tags:
#       service: backend" | /home/vagrant/kuma/bin/kumactl apply -f -

# /home/vagrant/kuma/bin/kumactl get dataplanes