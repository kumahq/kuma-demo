#!/bin/sh
kumactl config control-planes switch --name=cluster-2
kumactl apply -f ingress.yaml
kumactl generate dataplane-token --dataplane=ingress-02 > /tmp/cluster2-ingress-token
kuma-dp run --name=ingress-02 --cp-address=http://localhost:25681 --dataplane-token-file=/tmp/cluster2-ingress-token --log-level=debug
