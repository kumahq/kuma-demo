#!/bin/sh

set -e

if [ -z "${KUMA_CONTROL_PLANE_IP}" ]; then
  echo "Error: environment variable KUMA_CONTROL_PLANE_IP is not set"
  exit 1
fi

echo "
${KUMA_CONTROL_PLANE_IP} kuma-cp
" >> /etc/hosts
