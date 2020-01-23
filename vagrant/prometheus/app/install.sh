#!/bin/sh

set -e

if [ -z "${PROMETHEUS_VERSION}" ]; then
  echo "Error: environment variable PROMETHEUS_VERSION is not set"
  exit 1
fi

cat << "EOF"
PROMETHEUS
EOF

# Add user
useradd -M -r -s /bin/false prometheus

# Create directory in which Prometheus will be installed
mkdir /etc/prometheus /var/lib/prometheus

# Get Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Unpack and copy binaries
tar xzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/
cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/

# Set permissions for binaries for added user
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Copy config
cp /vagrant/prometheus/app/prometheus.yaml /etc/prometheus/prometheus.yaml

# Set permissions for Prometheus data directories
chown -R prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Set permission for Prometheus integration with Kuma
chown prometheus:prometheus /var/run/kuma.io/kuma-prometheus-sd/

# Add Prometheus service
cp /vagrant/prometheus/app/prometheus.service /etc/systemd/system/prometheus.service

# Always run the `systemctl daemon-reload` command after creating new unit files or modifying existing unit files.
# Otherwise, the `systemctl start` or `systemctl enable` commands could fail due to a mismatch between states of systemd
# and actual service unit files on disk.
systemctl daemon-reload

# Ensure the `prometheus` service starts whenever the system boots
systemctl enable prometheus

# Start `prometheus` service right away
systemctl start prometheus

# Add Grafana repo
echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list
curl https://packages.grafana.com/gpg.key | apt-key add -

# Install Grafana
apt-get update
apt-get install grafana -y

# Copy provisioning including default Kuma dashboard
rm -rf /etc/grafana/provisioning
cp -R /vagrant/prometheus/app/provisioning /etc/grafana/provisioning
chown -R grafana:grafana /etc/grafana/provisioning

# Ensure the `grafana-server` service starts whenever the system boots
systemctl enable grafana-server.service

# Start `grafana-server` service
systemctl start grafana-server