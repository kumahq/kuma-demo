#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

  ____  ____   ___  __  __ _____ _____ _   _ _____ _   _ ____  
 |  _ \|  _ \ / _ \|  \/  | ____|_   _| | | | ____| | | / ___| 
 | |_) | |_) | | | | |\/| |  _|   | | | |_| |  _| | | | \___ \ 
 |  __/|  _ <| |_| | |  | | |___  | | |  _  | |___| |_| |___) |
 |_|   |_| \_\\___/|_|  |_|_____| |_| |_| |_|_____|\___/|____/ 
                                                                                                                                                                      
EOF

if [ -z "${PROMETHEUS_VERSION}" ]; then
  echo "Error: environment variable PROMETHEUS_VERSION is not set"
  exit 1
fi

cat << "EOF"
PROMETHEUS
EOF

# Create directory in which Prometheus will be installed
mkdir /etc/prometheus /var/lib/prometheus

# Get Prometheus
wget --quiet https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

# Unpack and copy binaries
tar xzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/
cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/

# Set permissions for binaries for added user
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Copy config
cp /vagrant/metrics/app/prometheus/prometheus.yaml /etc/prometheus/prometheus.yaml

# Set permissions for Prometheus data directories
chown -R prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Add Prometheus service
cp /vagrant/metrics/app/prometheus/prometheus.service /etc/systemd/system/prometheus.service

# Always run the `systemctl daemon-reload` command after creating new unit files or modifying existing unit files.
# Otherwise, the `systemctl start` or `systemctl enable` commands could fail due to a mismatch between states of systemd
# and actual service unit files on disk.
systemctl daemon-reload

# Ensure the `prometheus` service starts whenever the system boots
systemctl enable prometheus

# Start `prometheus` service right away
systemctl start prometheus