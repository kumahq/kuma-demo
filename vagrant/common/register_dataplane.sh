#!/bin/sh

set -e

if [ -z "${KUMA_DATAPLANE_FILE}" ]; then
  echo "Error: environment variable KUMA_DATAPLANE_FILE is not set"
  exit 1
fi

if [ -z "${KUMA_DATAPLANE_IP}" ]; then
  echo "Error: environment variable KUMA_DATAPLANE_IP is not set"
  exit 1
fi

# Register Dataplane on the Control Plane
kumactl apply -f ${KUMA_DATAPLANE_FILE} --var DATAPLANE_IP=${KUMA_DATAPLANE_IP}
