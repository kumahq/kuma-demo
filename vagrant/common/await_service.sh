#!/bin/sh

set -e

if [ -z "${SERVICE_URL}" ]; then
  echo "Error: environment variable SERVICE_URL is not set"
  exit 1
fi

# Wait for service to start
for i in `seq 1 60`; do
    echo "try #$i: "
    if curl --silent --show-error --fail ${SERVICE_URL} ; then
        exit 0
    fi
    sleep 1
done
exit 1
