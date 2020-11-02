#!/bin/sh
kumactl config control-planes switch --name=cluster-1
kumactl apply -f dp-gateway.yaml
kumactl generate dataplane-token --dataplane=gateway-01 > /tmp/cluster1-gateway-token
kuma-dp run --name=gateway-01 --cp-address=https://localhost:15678 --dataplane-token-file=/tmp/cluster1-gateway-token --log-level=debug
