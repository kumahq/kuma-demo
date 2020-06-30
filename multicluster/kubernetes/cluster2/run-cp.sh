#!/usr/bin/env bash
kumactl install control-plane --mode=remote --zone=cluster2 | kubectl apply -f-
kumactl install ingress | kubectl apply -f-