#!/bin/sh

set -e

# Create directory and set proper permissions for generated files by kuma-prometheus-sd
mkdir -p /var/run/kuma.io/kuma-prometheus-sd/
chown prometheus:prometheus /var/run/kuma.io/kuma-prometheus-sd/

cp /vagrant/metrics/kuma/kuma-prometheus-sd.service /etc/systemd/system/kuma-prometheus-sd.service

# Always run the `systemctl daemon-reload` command after creating new unit files or modifying existing unit files.
# Otherwise, the `systemctl start` or `systemctl enable` commands could fail due to a mismatch between states of systemd
# and actual service unit files on disk.
systemctl daemon-reload

# Ensure the `kuma-prometheus-sd` service starts whenever the system boots
systemctl enable kuma-prometheus-sd

# Start `kuma-prometheus-sd` service right away
systemctl start kuma-prometheus-sd