#!/bin/sh

set -e

cat << "EOF"
GRAFANA
EOF

# Add Grafana repo
echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list
curl https://packages.grafana.com/gpg.key | apt-key add -

# Install Grafana
apt-get update
apt-get install grafana -y

# Copy provisioning including default Kuma dashboard
rm -rf /etc/grafana/provisioning
cp -R /vagrant/metrics/app/grafana/provisioning /etc/grafana/provisioning
chown -R grafana:grafana /etc/grafana/provisioning

# Ensure the `grafana-server` service starts whenever the system boots
systemctl enable grafana-server.service

# Start `grafana-server` service
systemctl start grafana-server