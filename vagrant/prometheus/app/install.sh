#!/bin/sh

set -e

cat << "EOF"
PROMETHEUS
EOF

# Add user
useradd -M -r -s /bin/false prometheus

# Create directory in which Prometheus will be installed
mkdir /etc/prometheus /var/lib/prometheus

# Get Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.15.2/prometheus-2.15.2.linux-amd64.tar.gz

# Unpack and copy binaries
tar xzf prometheus-2.15.2.linux-amd64.tar.gz
cp prometheus-2.15.2.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.15.2.linux-amd64/promtool /usr/local/bin/

# Set permissions for binaries for added user
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Copy config
cp /tmp/prometheus.yaml /etc/prometheus/prometheus.yaml

# Set permissions for Prometheus data directories
chown -R prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Add Prometheus service
cp /tmp/prometheus.service /etc/systemd/system/prometheus.service

# Always run the `systemctl daemon-reload` command after creating new unit files or modifying existing unit files.
# Otherwise, the `systemctl start` or `systemctl enable` commands could fail due to a mismatch between states of systemd
# and actual service unit files on disk.
systemctl daemon-reload

# Ensure the `prometheus` service starts whenever the system boots
systemctl enable prometheus

# Start `prometheus` service right away
systemctl start prometheus