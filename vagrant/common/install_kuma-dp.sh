#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

  ____    _  _____  _    ____  _        _    _   _ _____ 
 |  _ \  / \|_   _|/ \  |  _ \| |      / \  | \ | | ____|
 | | | |/ _ \ | | / _ \ | |_) | |     / _ \ |  \| |  _|  
 | |_| / ___ \| |/ ___ \|  __/| |___ / ___ \| |\  | |___ 
 |____/_/   \_\_/_/   \_\_|   |_____/_/   \_\_| \_|_____|
                                                                                                              
EOF

if [ -z "${KUMA_DP_UNIT_FILE}" ]; then
  echo "Error: environment variable KUMA_DP_UNIT_FILE is not set"
  exit 1
fi

if [ -z "${KUMA_DATAPLANE_FILE}" ]; then
  echo "Error: environment variable KUMA_DATAPLANE_FILE is not set"
  exit 1
fi

if [ -z "${KUMA_DATAPLANE_IP}" ]; then
  echo "Error: environment variable KUMA_DATAPLANE_IP is not set"
  exit 1
fi

cp ${KUMA_DATAPLANE_FILE} /etc/systemd/system/dataplane.yaml
cp ${KUMA_DP_UNIT_FILE} /etc/systemd/system/kuma-dp.service

sed -i "s/{{ DATAPLANE_IP }}/${KUMA_DATAPLANE_IP}/g" /etc/systemd/system/dataplane.yaml

# Always run the `systemctl daemon-reload` command after creating new unit files or modifying existing unit files.
# Otherwise, the `systemctl start` or `systemctl enable` commands could fail due to a mismatch between states of systemd
# and actual service unit files on disk.
systemctl daemon-reload

# Ensure the `kuma-dp` service starts whenever the system boots
systemctl enable kuma-dp

# Start `kuma-dp` service right away
systemctl start kuma-dp
