#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

   ____ ____      _    _____ _    _   _    _    
  / ___|  _ \    / \  |  ___/ \  | \ | |  / \   
 | |  _| |_) |  / _ \ | |_ / _ \ |  \| | / _ \  
 | |_| |  _ <  / ___ \|  _/ ___ \| |\  |/ ___ \ 
  \____|_| \_\/_/   \_\_|/_/   \_\_| \_/_/   \_\
                                                                                           
EOF

# Add Grafana repo
echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list
curl -sL https://packages.grafana.com/gpg.key | apt-key add -

# Install Grafana
apt-get update -y -q
apt-get install grafana -y -q

# Copy provisioning including default Kuma dashboard
rm -rf /etc/grafana/provisioning
cp -R /vagrant/metrics/app/grafana/provisioning /etc/grafana/provisioning
chown -R grafana:grafana /etc/grafana/provisioning

# Ensure the `grafana-server` service starts whenever the system boots
systemctl enable grafana-server.service

# Start `grafana-server` service
systemctl start grafana-server