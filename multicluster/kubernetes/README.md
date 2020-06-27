NOT FINISHED

# Kuma Multicluster Kubernetes Demo

## Requirements

* Built and pushed Dockers with Kuma multicluster (required until we release RC1).
  Newest snapshot by Jakub:
  jakubdyszkiewicz/kuma-cp:0.5.1-34-gbdcc0636
  jakubdyszkiewicz/kuma-dp:0.5.1-34-gbdcc0636
  jakubdyszkiewicz/kuma-init:0.5.1-34-gbdcc0636
* 3 clusters of Kubernetes. (I tested on GCP since my Macbook with 16GB RAM is not powerful enough)

## Instruction

### Setup

#### Cluster 1

1. Deploy Kuma
```
kumactl install control-plane --control-plane-image=jakubdyszkiewicz/kuma-cp --dataplane-image=jakubdyszkiewicz/kuma-dp --dataplane-init-image=jakubdyszkiewicz/kuma-init --control-plane-version=0.5.1-34-gbdcc0636 --mode=remote --cluster-name=cluster-1 --use-node-port=true | kubectl apply -f -
```

2. Deploy Ingress
```
kumactl install ingress --image=jakubdyszkiewicz/kuma-dp --version=0.5.1-34-gbdcc0636 --use-node-port=true | kubectl apply -f -
```


```
kumactl install ingress --image=jakubdyszkiewicz/kuma-dp --version=0.5.1-34-gbdcc0636 --use-node-port=true | kubectl apply -f -
```

3. Extract IPs of Sync and Ingress

We need to pass `--use-node-port=true` because I have limit on GCP to 4 external IPs. Also KIND does not support LoadBalancer.
Normally Ingress and Sync service is a LoadBalancer so we can see External IP.

```
❯❯❯ kubectl get services -n kuma-system
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                                                                  AGE
global-remote-sync   NodePort    10.8.9.106   <none>        5685:30685/TCP                                                           5m40s
kuma-control-plane   ClusterIP   10.8.14.36   <none>        5681/TCP,443/TCP,5676/TCP,5677/TCP,5678/TCP,5679/TCP,5682/TCP,5653/UDP   5m40s
kuma-ingress         NodePort    10.8.1.207   <none>        10001:32671/TCP                                                          10s
```

```
❯❯❯ kubectl get nodes -o wide
NAME                                       STATUS   ROLES    AGE    VERSION         INTERNAL-IP   EXTERNAL-IP     OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-cluster-1-default-pool-fc3cdd43-179z   Ready    <none>   111m   v1.17.6-gke.7   10.128.0.8    104.197.91.90   Container-Optimized OS from Google   4.19.112+        docker://19.3.6
gke-cluster-1-default-pool-fc3cdd43-bqh8   Ready    <none>   111m   v1.17.6-gke.7   10.128.0.10   35.226.144.96   Container-Optimized OS from Google   4.19.112+        docker://19.3.6
gke-cluster-1-default-pool-fc3cdd43-h5xb   Ready    <none>   111m   v1.17.6-gke.7   10.128.0.9    35.222.76.24    Container-Optimized OS from Google   4.19.112+        docker://19.3.6
```

External address for remote is `104.197.91.90:30685` and for Ingress `104.197.91.90:32671`

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
NAME                      TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)                      AGE
backend                   ClusterIP      10.8.4.123   <none>           5678/TCP                     70s
kong-proxy                LoadBalancer   10.8.9.240   35.226.196.103   80:30274/TCP,443:30909/TCP   63s
kong-validation-webhook   ClusterIP      10.8.1.66    <none>           443/TCP                      62s

❯❯❯ curl 35.226.196.103/
cluster: cluster-1, service: backend, version: 1
```

#### Cluster 2



