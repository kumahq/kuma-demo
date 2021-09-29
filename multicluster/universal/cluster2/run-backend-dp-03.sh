#!/bin/sh
kumactl config control-planes switch --name=cluster-2
kumactl generate dataplane-token --name=backend-03 > /tmp/cluster2-backend-03-token
kuma-dp run --dns-enabled=false --dataplane-file=dp-backend-03.yaml --cp-address=https://127.0.0.1:25678 --dataplane-token-file=/tmp/cluster2-backend-03-token --log-level=debug
