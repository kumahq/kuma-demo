#!/bin/sh

set -e

if [ -z "${KUMA_DP_UNIT_FILE}" ]; then
  echo "Error: environment variable KUMA_DP_UNIT_FILE is not set"
  exit 1
fi

cp ${KUMA_DP_UNIT_FILE} /etc/systemd/system/kuma-dp.service

# Always run the `systemctl daemon-reload` command after creating new unit files or modifying existing unit files.
# Otherwise, the `systemctl start` or `systemctl enable` commands could fail due to a mismatch between states of systemd
# and actual service unit files on disk.
systemctl daemon-reload

# Ensure the `kuma-dp` service starts whenever the system boots
systemctl enable kuma-dp

# Start `kuma-dp` service right away
systemctl start kuma-dp
