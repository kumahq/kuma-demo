#!/usr/bin/env bash

# Add variables
export PATH=$PATH:/home/vagrant/kuma/bin
echo "export PATH=$PATH:/home/vagrant/kuma/bin" >> /home/vagrant/.bashrc

# directory for certs and kuma
mkdir -p /home/vagrant/kuma/certs/server/ 

# create systemd file
touch /etc/systemd/system/kuma-cp.service
cat > /etc/systemd/system/kuma-cp.service <<EOL
[Service]
Environment=KUMA_GENERAL_ADVERTISED_HOSTNAME=kuma-cp
Environment=KUMA_BOOTSTRAP_SERVER_PARAMS_XDS_HOST=kuma-cp
Environment=KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_ENABLED=true
Environment=KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_INTERFACE=0.0.0.0
Environment=KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_PORT=5684
Environment=KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_TLS_CERT_FILE=/home/vagrant/kuma/certs/server/cert.pem
Environment=KUMA_DATAPLANE_TOKEN_SERVER_PUBLIC_TLS_KEY_FILE=/home/vagrant/kuma/certs/server/key.pem
ExecStart=/home/vagrant/kuma/bin/kuma-cp run
EOL

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
systemctl start kuma-cp
systemctl status kuma-cp

# Wait for service to start
for i in `seq 1 60`; do 
    echo -n "try #$i: " 
    curl --silent --show-error --fail http://localhost:5681 
    if [[ $? -eq 0 ]]; then 
        break
    fi
    sleep 1
done

#Create DP tokencdcd 
mkdir -p /home/vagrant/kuma/certs/kuma-dp/frontend/
/home/vagrant/kuma/bin/kumactl generate dataplane-token --dataplane=frontend > /home/vagrant/kuma/certs/kuma-dp/frontend/token
mkdir -p /home/vagrant/kuma/certs/kuma-dp/backend/
/home/vagrant/kuma/bin/kumactl generate dataplane-token --dataplane=backend > /home/vagrant/kuma/certs/kuma-dp/backend/token
mkdir -p /home/vagrant/kuma/certs/kuma-dp/elastic/
/home/vagrant/kuma/bin/kumactl generate dataplane-token --dataplane=elastic > /home/vagrant/kuma/certs/kuma-dp/elastic/token
mkdir -p /home/vagrant/kuma/certs/kuma-dp/redis/
/home/vagrant/kuma/bin/kumactl generate dataplane-token --dataplane=redis > /home/vagrant/kuma/certs/kuma-dp/redis/token