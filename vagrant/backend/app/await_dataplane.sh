#!/bin/sh
set -e

# Wait for service to start
for i in `seq 1 60`; do
    echo "try #$i: "
    if curl --silent --show-error --fail http://localhost:9901 ; then
        exit 0
    fi
    sleep 1
done
exit 1
