#!/bin/sh
kumactl config control-planes switch --name=cluster-1
kumactl apply -f ingress.yaml
kumactl generate dataplane-token --dataplane=ingress-01 > /tmp/cluster1-ingress-token
kuma-dp run --name=ingress-01 --cp-address=http://localhost:15681 --dataplane-token-file=/tmp/cluster1-ingress-token --log-level=debug
