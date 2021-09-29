#!/bin/sh
kumactl config control-planes switch --name=cluster-2
kumactl generate dataplane-token --name=backend-02 > /tmp/cluster2-backend-02-token
kuma-dp run --dns-enabled=false --dataplane-file=dp-backend-02.yaml --cp-address=https://127.0.0.1:25678 --dataplane-token-file=/tmp/cluster2-backend-02-token --log-level=debug
