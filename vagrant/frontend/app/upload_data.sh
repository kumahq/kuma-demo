#!/bin/sh

set -e

# Upload mock data to PostgreSQL and Redis
for i in `seq 1 60`; do
    echo "try #$i: "
    if curl -X POST --silent --show-error --fail localhost:23001/upload ; then
        exit 0
    fi
    sleep 1
done
exit 1

