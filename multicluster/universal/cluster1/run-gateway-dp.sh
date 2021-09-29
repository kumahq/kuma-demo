#!/bin/sh
kumactl config control-planes switch --name=cluster-1
kumactl generate dataplane-token --name=gateway-01 > /tmp/cluster1-gateway-token
kuma-dp run --dataplane-file=dp-gateway.yaml --dns-enabled=false --cp-address=https://localhost:15678 --dataplane-token-file=/tmp/cluster1-gateway-token --log-level=debug
