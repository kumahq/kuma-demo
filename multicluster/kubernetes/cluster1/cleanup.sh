#!/usr/bin/env bash
kubectl delete -f https://bit.ly/demokumakong
kubectl delete -f ingress.yaml
kubectl delete -f backend.yaml
kumactl install control-plane --mode=remote --zone=cluster1 | kubectl delete -f-
# kumactl install ingress | kubectl delete -f-