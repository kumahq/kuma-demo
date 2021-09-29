#!/bin/sh
kumactl config control-planes switch --name=cluster-1
kumactl generate dataplane-token --name=backend-01 > /tmp/cluster1-backend-token
kuma-dp run --dataplane-file=dp-backend.yaml --dns-enabled=false --cp-address=https://localhost:15678 --dataplane-token-file=/tmp/cluster1-backend-token --log-level=debug
