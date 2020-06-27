#!/bin/sh
kumactl config control-planes switch --name=cluster-2
kumactl apply -f dp-backend-03.yaml
kumactl generate dataplane-token --dataplane=backend-03 > /tmp/cluster2-backend-03-token
kuma-dp run --name=backend-03 --cp-address=http://localhost:25681 --dataplane-token-file=/tmp/cluster2-backend-03-token --log-level=debug
