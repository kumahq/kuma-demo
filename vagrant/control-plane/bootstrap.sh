#!/bin/bash

cat << "EOF"
oooo    oooo ooooo     ooo ooo        ooooo       .o.                 .oooooo.   ooooooooo.   
`888   .8P'  `888'     `8' `88.       .888'      .888.               d8P'  `Y8b  `888   `Y88. 
 888  d8'     888       8   888b     d'888      .8"888.             888           888   .d88' 
 88888[       888       8   8 Y88. .P  888     .8' `888.            888           888ooo88P'  
 888`88b.     888       8   8  `888'   888    .88ooo8888.   8888888 888           888         
 888  `88b.   `88.    .8'   8    Y     888   .8'     `888.          `88b    ooo   888         
o888o  o888o    `YbodP'    o8o        o888o o88o     o8888o          `Y8bood8P'  o888o        
EOF

# Add Kuma to PATH to make it easier to use `kumactl`
export PATH=$PATH:/home/vagrant/kuma/bin
echo "export PATH=$PATH:/home/vagrant/kuma/bin" >> /home/vagrant/.bashrc

# Create a new directory for the Kuma files and the dataplane tokens (done last)
mkdir -p /home/vagrant/kuma/certs/server/ 

# Navigate to the Kuma direcotry
cd /home/vagrant/kuma

# Download latest version of Kuma for Ubuntu, please check out https://kuma.io/install for more options
wget -nv https://kong.bintray.com/kuma/kuma-0.3.1-ubuntu-amd64.tar.gz

# Extract the Kuma archive
tar xvzf kuma-0.3.1-ubuntu-amd64.tar.gz

# Use `kumactl` to generate a TLS certificate for server
kumactl generate tls-certificate \
--cert-file=/home/vagrant/kuma/certs/server/cert.pem \
--key-file=/home/vagrant/kuma/certs/server/key.pem \
--type=server \
--cp-hostname=kuma-cp

# Create a service unit file for Kuma's control-plane
touch /etc/systemd/system/kuma-cp.service

# Add the following configurations to the service file
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

# Start the `kuma-cp` service on the local machine
systemctl start kuma-cp

# Wait for service to start
for i in `seq 1 60`; do 
    echo -n "try #$i: " 
    curl --silent --show-error --fail http://localhost:5681 
    if [[ $? -eq 0 ]]; then 
        break
    fi
    sleep 1
done

# Create a dataplane token for each service (each service has its own dataplane)
mkdir -p /vagrant/.vagrant.data/frontend/var/secrets/kuma.io/kuma-dp/
/home/vagrant/kuma/bin/kumactl generate dataplane-token --dataplane=frontend > /vagrant/.vagrant.data/frontend/var/secrets/kuma.io/kuma-dp/token
mkdir -p /home/vagrant/kuma/certs/kuma-dp/backend/
/home/vagrant/kuma/bin/kumactl generate dataplane-token --dataplane=backend > /home/vagrant/kuma/certs/kuma-dp/backend/token
mkdir -p /vagrant/.vagrant.data/elastic/var/secrets/kuma.io/kuma-dp/
/home/vagrant/kuma/bin/kumactl generate dataplane-token --dataplane=elastic > /vagrant/.vagrant.data/elastic/var/secrets/kuma.io/kuma-dp/token
mkdir -p /vagrant/.vagrant.data/redis/var/secrets/kuma.io/kuma-dp/
/home/vagrant/kuma/bin/kumactl generate dataplane-token --dataplane=redis > /vagrant/.vagrant.data/redis/var/secrets/kuma.io/kuma-dp/token
