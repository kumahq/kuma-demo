#!/bin/sh
kumactl config control-planes switch --name=cluster-1
kumactl apply -f dp-backend.yaml
kumactl generate dataplane-token --dataplane=backend-01 > /tmp/cluster1-backend-token
kuma-dp run --name=backend-01 --cp-address=https://localhost:15678 --dataplane-token-file=/tmp/cluster1-backend-token --log-level=debug
