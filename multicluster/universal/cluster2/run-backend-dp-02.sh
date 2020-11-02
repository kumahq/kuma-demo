#!/bin/sh
kumactl config control-planes switch --name=cluster-2
kumactl apply -f dp-backend-02.yaml
kumactl generate dataplane-token --dataplane=backend-02 > /tmp/cluster2-backend-02-token
kuma-dp run --name=backend-02 --cp-address=https://localhost:25678 --dataplane-token-file=/tmp/cluster2-backend-02-token --log-level=debug
