NOT FINISHED

# Kuma Multicluster Kubernetes Demo

## Requirements

* Built and pushed Dockers with Kuma multicluster (required until we release RC1).
  Newest snapshot by Jakub:
  jakubdyszkiewicz/kuma-cp:0.5.1-38-g9d94fe96
  jakubdyszkiewicz/kuma-dp:0.5.1-38-g9d94fe96
  jakubdyszkiewicz/kuma-init:0.5.1-38-g9d94fe96
* 3 clusters of Kubernetes. (I tested on GCP since my Macbook with 16GB RAM is not powerful enough)

## Instruction

### Setup

#### Cluster 1

1. Deploy Kuma
```
kumactl install control-plane --control-plane-image=jakubdyszkiewicz/kuma-cp --dataplane-image=jakubdyszkiewicz/kuma-dp --dataplane-init-image=jakubdyszkiewicz/kuma-init --control-plane-version=0.5.1-38-g9d94fe96 --mode=remote --cluster-name=cluster-1 --use-node-port=true | kubectl apply -f -
```

2. Deploy Ingress
```
kumactl install ingress --image=jakubdyszkiewicz/kuma-dp --version=0.5.1-38-g9d94fe96 --use-node-port=true | kubectl apply -f -
```

4. Deploy Backend service

```
kubectl apply -f backend.yaml
```

5. Deploy Kong as Ingress
```
kubectl apply -f https://bit.ly/demokumakong
kubectl apply -f ingress.yaml
```

Communication should work now

```
❯❯❯ kubectl get services -n kuma-demo
NAME                      TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)                      AGE
backend                   ClusterIP      10.8.11.204   <none>         5678/TCP                     97s
kong-proxy                LoadBalancer   10.8.0.126    35.222.76.24   80:31897/TCP,443:30995/TCP   57s
kong-validation-webhook   ClusterIP      10.8.8.221    <none>         443/TCP                      56s

❯❯❯ curl 35.222.76.24/
cluster: cluster-1, service: backend, version: 1
```

#### Cluster 2

1. Deploy Kuma
```
kumactl install control-plane --control-plane-image=jakubdyszkiewicz/kuma-cp --dataplane-image=jakubdyszkiewicz/kuma-dp --dataplane-init-image=jakubdyszkiewicz/kuma-init --control-plane-version=0.5.1-38-g9d94fe96 --mode=remote --cluster-name=cluster-2 --use-node-port=true | kubectl apply -f -
```

2. Deploy Ingress
```
kumactl install ingress --image=jakubdyszkiewicz/kuma-dp --version=0.5.1-38-g9d94fe96 --use-node-port=true | kubectl apply -f -
```

3. Deploy Backend service

```
kubectl apply -f backend.yaml
```

#### Global

1. Deploy Kuma
```
kumactl install control-plane --control-plane-image=jakubdyszkiewicz/kuma-cp --dataplane-image=jakubdyszkiewicz/kuma-dp --dataplane-init-image=jakubdyszkiewicz/kuma-init --control-plane-version=0.5.1-38-g9d94fe96 --mode=global --use-node-port=true | kubectl apply -f -
```

2. Add Clusters

Extract IP + Port of Sync service from Remotes and Global as well as Ingress from Remotes

```
❯❯❯ kubectl get services -n kuma-system
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                                                                  AGE
global-remote-sync   NodePort    10.8.5.23    <none>        5685:30685/TCP                                                           96s
kuma-control-plane   ClusterIP   10.8.7.146   <none>        5681/TCP,443/TCP,5676/TCP,5677/TCP,5678/TCP,5679/TCP,5682/TCP,5653/UDP   97s
kuma-ingress         NodePort    10.8.1.57    <none>        10001:30051/TCP                                                          25s
```

```
❯❯❯ kubectl get nodes -o wide
NAME                                       STATUS   ROLES    AGE   VERSION         INTERNAL-IP   EXTERNAL-IP      OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-cluster-1-default-pool-794e7128-b5b5   Ready    <none>   10m   v1.17.6-gke.7   10.128.0.13   35.226.144.96    Container-Optimized OS from Google   4.19.112+        docker://19.3.6
gke-cluster-1-default-pool-794e7128-fnq6   Ready    <none>   10m   v1.17.6-gke.7   10.128.0.11   104.197.91.90    Container-Optimized OS from Google   4.19.112+        docker://19.3.6
gke-cluster-1-default-pool-794e7128-jp1r   Ready    <none>   10m   v1.17.6-gke.7   10.128.0.12   35.226.196.103   Container-Optimized OS from Google   4.19.112+        docker://19.3.6
```

External address for remote is `35.226.144.96:30685` and for Ingress `35.226.144.96:30051`

We use when installing `--use-node-port=true` because I have limit on GCP to 4 external IPs. Also KIND does not support LoadBalancer.
Normally Ingress and Sync service is a LoadBalancer so we can see External IP so you don't have to extract Node ID.

Remote CP sync: `35.226.144.96:30685`
Ingress: `35.226.144.96:30051`

Update `config.yaml`, execute `kubectl apply -f config.yaml` and remove Kuma CP Pod

3. Add mTLS + TrafficPermission

On Global cluster

`kubectl apply -f mesh.yaml`
`kubectl apply -f tp.yaml`

### Use cases

#### Load balancing across all the clusters
1. Let's now make some requests via Gateway in Cluster 1 (you extracted IP of it before)
   Requests should be loadbalanced between all backends in every cluster!
