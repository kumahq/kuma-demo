#!/bin/sh
kumactl config control-planes switch --name=cluster-1
kumactl generate zone-ingress-token --zone=cluster-1 > /tmp/cluster1-ingress-token
kuma-dp run --proxy-type=ingress --dns-enabled=false --dataplane-file=ingress.yaml --cp-address=https://localhost:15678 --dataplane-token-file=/tmp/cluster1-ingress-token --log-level=debug
