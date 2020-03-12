# Kubernetes Deployment Guide

## Introductions
This Kuma Kubernetes deployment guide will walk you through how to deploy the marketplace application on Kubernetes and configure Kuma to work alongside it.

When running on Kubernetes, Kuma will store all of its state and configuration on the underlying Kubernetes API Server, therefore requiring no dependency to store the data.

## Table of contents
- [Setup Environment](#setup-environment)
  - [Setup Minkube](#1-start-a-kubernetes-cluster-with-at-least-4gb-of-memory-weve-tested-kuma-on-kubernetes-v1130---v116x-so-use-anything-older-than-v1130-with-caution-in-this-demo-well-be-using-v1154)
  - [Deploy Marketplace Application](#2-deploy-kumas-sample-marketplace-application-in-minikube)
  - [Download Kuma](#4-download-the-latest-version-of-kuma)
  - [Install control-plane via `kumactl`](#7-install-the-control-plane-using-kumactl)
- Kuma Policies
  - [mTLS Policy](#14-lets-enable-mtls)
  - [Traffic Permission Policy](#15-now-lets-enable-traffic-permission-for-all-services-so-our-application-will-work-like-it-use-to)
  - [Logging Policy](#17-lets-add-logging-for-traffic-between-all-services-and-send-them-to-logstash)
  - [Traffic Routing Policy](#22-lets-explore-adding-traffic-routing-to-our-service-mesh-but-before-we-do-we-need-to-scale-up-the-v1-and-v2-deployment-of-our-sample-application)
  - [Traffic Metrics Policy](#26-enable-prometheus-metrics-on-the-mesh-object)
- Kuma GUI
  - [Visualizing Kuma Mesh](#30-visualize-mesh-with-kuma-gui)
- Kong API Gateway Integration
  - [Deploying Kong Alongside Kuma](#31-kong-gateway-integration)

## Setup Environment

### 1. Start a Kubernetes cluster with at least 4GB of memory. We've tested Kuma on Kubernetes v1.13.0 - v1.16.x, so use anything older than v1.13.0 with caution. In this demo, we'll be using v1.15.4. 

```bash
$ minikube start --cpus 2 --memory 6144 --kubernetes-version v1.15.4 -p kuma-demo
😄  [kuma-demo] minikube v1.5.2 on Darwin 10.15.1
✨  Automatically selected the 'hyperkit' driver (alternates: [virtualbox])
🔥  Creating hyperkit VM (CPUs=2, Memory=4096MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.15.4 on Docker '18.09.9' ...
🚜  Pulling images ...
🚀  Launching Kubernetes ... 
⌛  Waiting for: apiserver
🏄  Done! kubectl is now configured to use "kuma-demo"
```

### 2. Deploy Kuma's sample marketplace application in minikube
You can deploy the sample marketplace application using the [`kuma-demo-aio.yaml`](/kubernetes/kuma-demo-aio.yaml) file in this directory.
```bash
$ kubectl apply -f kuma-demo-aio.yaml
namespace/kuma-demo created
serviceaccount/elasticsearch created
service/elasticsearch created
replicationcontroller/es created
deployment.apps/redis-master created
service/redis created
service/backend created
deployment.apps/kuma-demo-backend-v0 created
deployment.apps/kuma-demo-backend-v1 created
deployment.apps/kuma-demo-backend-v2 created
configmap/demo-app-config created
service/frontend created
deployment.apps/kuma-demo-app created
```

This will deploy our demo marketplace application split across multiple pods:
1. The first pod is an Elasticsearch service that stores all the items in our marketplace
2. The second pod is a Redis service that stores reviews for each item
3. The third pod is a Node application that represents a backend
4. The remaining pods represent multiple versions of our Node/Vue application that allows you to visually query the Elastic and Redis endpoints

Check the pods are up and running by checking the `kuma-demo` namespace

```bash
$ kubectl get pods -n kuma-demo
NAME                                    READY   STATUS    RESTARTS   AGE
es-v6g88                                1/1     Running   0          32s
kuma-demo-app-7bb5d85c8c-8kl2z          1/1     Running   0          30s
kuma-demo-backend-v0-7dcb8dc8fd-rq798   1/1     Running   0          31s
redis-master-5b5978b77f-pmhnz           1/1     Running   0          32s
```

In the following steps, we will be using the pod name of the `kuma-demo-app-*************` pod. Please replace any `${KUMA_DEMO_APP_POD_NAME}` variables with your pod name.

### 3. Port-forward the sample application to access the front-end UI at http://localhost:8080

<pre><code>$ kubectl port-forward <b>${KUMA_DEMO_APP_POD_NAME}</b> -n kuma-demo 8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
</code></pre>

Now you can access the marketplace application through your web browser at http://localhost:8080.

The items on the front page are pulled from the Elasticsearch service. While the reviews for each item sit within the Redis service. You can query for individual items and look at their reviews.


### 4. Download the latest version of Kuma
The following command will download the Mac compatible version of Kuma. To find the correct version for your operating system, please check out [Kuma's official installation page](https://kuma.io/install).

```bash
$ wget https://kong.bintray.com/kuma/kuma-0.4.0-darwin-amd64.tar.gz
--2020-01-13 11:56:39--  https://kong.bintray.com/kuma/kuma-0.4.0-darwin-amd64.tar.gz
Resolving kong.bintray.com (kong.bintray.com)... 52.41.227.164, 34.214.70.158
Connecting to kong.bintray.com (kong.bintray.com)|52.41.227.164|:443... connected.
HTTP request sent, awaiting response... 302
Location: https://akamai.bintray.com/8a/8a1f56b7d7f62dfb737cf2138e82412176677745683a06a67fc83d1c4388911f?__gda__=exp=1578888519~hmac=dafbee4fdd1670010d54e0e1d4e234a62b1ff0c74d503196bd82fde5ffbce7d8&response-content-disposition=attachment%3Bfilename%3D%22kuma-0.4.0-darwin-amd64.tar.gz%22&response-content-type=application%2Fgzip&requestInfo=U2FsdGVkX1_nPLxaZ2QotUT46adiCblIFpbPK7YYm7ib-GJ62wBQA77ydUDRL8FW8kMtC860-claI5VX3M_6Ms8YUPbPWYwpciVi2cBFLFc96wd9RAVomgiq_IDfvwxT&response-X-Checksum-Sha1=fc31e8100d35b9232376a90c00142c59fd284742&response-X-Checksum-Sha2=8a1f56b7d7f62dfb737cf2138e82412176677745683a06a67fc83d1c4388911f [following]
--2020-01-13 11:56:40--  https://akamai.bintray.com/8a/8a1f56b7d7f62dfb737cf2138e82412176677745683a06a67fc83d1c4388911f?__gda__=exp=1578888519~hmac=dafbee4fdd1670010d54e0e1d4e234a62b1ff0c74d503196bd82fde5ffbce7d8&response-content-disposition=attachment%3Bfilename%3D%22kuma-0.4.0-darwin-amd64.tar.gz%22&response-content-type=application%2Fgzip&requestInfo=U2FsdGVkX1_nPLxaZ2QotUT46adiCblIFpbPK7YYm7ib-GJ62wBQA77ydUDRL8FW8kMtC860-claI5VX3M_6Ms8YUPbPWYwpciVi2cBFLFc96wd9RAVomgiq_IDfvwxT&response-X-Checksum-Sha1=fc31e8100d35b9232376a90c00142c59fd284742&response-X-Checksum-Sha2=8a1f56b7d7f62dfb737cf2138e82412176677745683a06a67fc83d1c4388911f
Resolving akamai.bintray.com (akamai.bintray.com)... 173.222.181.233
Connecting to akamai.bintray.com (akamai.bintray.com)|173.222.181.233|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 48354601 (46M) [application/gzip]
Saving to: ‘kuma-0.4.0-darwin-amd64.tar.gz’

kuma-0.4.0-darwin-amd64.tar.gz      100%[===================================================================>]  46.11M  5.36MB/s    in 9.3s

2020-01-13 11:56:50 (4.96 MB/s) - ‘kuma-0.4.0-darwin-amd64.tar.gz’ saved [48354601/48354601]
```

### 5. Unbundle the files to get the following components:

```bash
$ tar xvzf kuma-0.4.0-darwin-amd64.tar.gz
x ./
x ./README
x ./bin/
x ./bin/kuma-cp
x ./bin/envoyl
x ./bin/kumactl
x ./bin/kuma-prometheus-sds
x ./bin/kuma-tcp-echo
x ./bin/kuma-dp
x ./NOTICE
x ./LICENSE
x ./NOTICE-kuma-init
x ./conf/
x ./conf/kuma-cp.conf
```

### 6. Go into the ./bin directory where the kuma components will be:

```bash
$ cd bin && ls
envoy			kuma-cp			kuma-dp			kuma-prometheus-sd	kuma-tcp-echo		kumactl
```

### 7. Install the control plane using `kumactl`

```bash
$ ./kumactl install control-plane | kubectl apply -f -
namespace/kuma-system created
secret/kuma-sds-tls-cert created
secret/kuma-admission-server-tls-cert created
secret/kuma-injector-tls-cert created
configmap/kuma-control-plane-config created
configmap/kuma-injector-config created
serviceaccount/kuma-injector created
serviceaccount/kuma-control-plane created
customresourcedefinition.apiextensions.k8s.io/dataplaneinsights.kuma.io created
customresourcedefinition.apiextensions.k8s.io/dataplanes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/healthchecks.kuma.io created
customresourcedefinition.apiextensions.k8s.io/meshes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/proxytemplates.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficlogs.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficpermissions.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficroutes.kuma.io created
clusterrole.rbac.authorization.k8s.io/kuma:control-plane created
clusterrole.rbac.authorization.k8s.io/kuma:injector created
clusterrolebinding.rbac.authorization.k8s.io/kuma:control-plane created
clusterrolebinding.rbac.authorization.k8s.io/kuma:injector created
role.rbac.authorization.k8s.io/kuma:control-plane created
rolebinding.rbac.authorization.k8s.io/kuma:control-plane created
service/kuma-injector created
service/kuma-control-plane created
deployment.apps/kuma-control-plane created
deployment.apps/kuma-injector created
mutatingwebhookconfiguration.admissionregistration.k8s.io/kuma-admission-mutating-webhook-configuration created
mutatingwebhookconfiguration.admissionregistration.k8s.io/kuma-injector-webhook-configuration created
validatingwebhookconfiguration.admissionregistration.k8s.io/kuma-validating-webhook-configuration created
```

You can check the pods are up and running by checking the `kuma-system` namespace

```bash
$ kubectl get pods -n kuma-system
NAME                                  READY   STATUS    RESTARTS   AGE
kuma-control-plane-7bcc56c869-lzw9t   1/1     Running   0          70s
kuma-injector-9c96cddc8-745r7         1/1     Running   0          70s
```

In the following steps, we will be using the pod name of the `kuma-control-plane-*************` pod. Please replace any `${KUMA_CP_POD_NAME}` with your pod name.

### 8. Delete the existing kuma-demo pods so they restart:

```bash
$ kubectl delete pods --all -n kuma-demo
pod "es-v6g88" deleted
pod "kuma-demo-app-7bb5d85c8c-8kl2z" deleted
pod "kuma-demo-backend-v0-7dcb8dc8fd-rq798" deleted
pod "redis-master-5b5978b77f-pmhnz" deleted
```

And check the pods are up and running again with an additional container. The additional container is the Envoy sidecar proxy that Kuma is injecting into each pod.

```bash
$ kubectl get pods -n kuma-demo
NAME                                    READY   STATUS    RESTARTS   AGE
es-5snv2                                2/2     Running   0          37s
kuma-demo-app-7bb5d85c8c-5sqxl          2/2     Running   0          37s
kuma-demo-backend-v0-7dcb8dc8fd-7ttjm   2/2     Running   0          37s
redis-master-5b5978b77f-hwjvd           2/2     Running   0          37s
```

### 9. Port-forward the sample application again to access the front-end UI at http://localhost:8080

<pre><code>$ kubectl port-forward <b>${KUMA_DEMO_APP_POD_NAME}</b> -n kuma-demo 8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
</code></pre>

Now you can access the marketplace application through your web browser at http://localhost:8080 with Envoy handling all the traffic between the services. Happy shopping!

### 10.  Now we will port forward the kuma-control-plane so we can access it with `kumactl`

<pre><code>$ kubectl -n kuma-system port-forward <b>${KUMA_CP_POD_NAME}</b> 5681 5683
Forwarding from 127.0.0.1:5681 -> 5681
Forwarding from [::1]:5681 -> 5681
Forwarding from 127.0.0.1:5683 -> 5683
Forwarding from [::1]:5683 -> 5683
</code></pre>

Please refer to step 7 to copy the correct `${KUMA_CP_POD_NAME}`.

### 11.  Now configure `kumactl` to point towards the control plane address

```bash
$ ./kumactl config control-planes add --name=minikube --address=http://localhost:5681
added Control Plane "minikube"
switched active Control Plane to "minikube"
```

### 12. You can use `kumactl` to look at the dataplanes in the mesh. You should see three dataplanes that correlates with our pods in Kubernetes:

```bash
$ ./kumactl inspect dataplanes
MESH      NAME                                    TAGS                                                                                               STATUS   LAST CONNECTED AGO   LAST UPDATED AGO   TOTAL UPDATES   TOTAL ERRORS
default   redis-master-5b5978b77f-hwjvd           app=redis pod-template-hash=5b5978b77f role=master service=redis.kuma-demo.svc:6379 tier=backend   Online   2m7s                 2m3s               8               0
default   es-5snv2                                component=elasticsearch service=elasticsearch.kuma-demo.svc:80                                     Online   1m49s                1m48s              3               0
default   kuma-demo-app-7bb5d85c8c-5sqxl          app=kuma-demo-frontend pod-template-hash=7bb5d85c8c service=frontend.kuma-demo.svc:80              Online   1m49s                1m48s              3               0
default   kuma-demo-backend-v0-7dcb8dc8fd-7ttjm   app=kuma-demo-backend pod-template-hash=7dcb8dc8fd service=backend.kuma-demo.svc:3001 version=v0   Online   1m47s                1m46s              3               0
```

### 13. You can also use `kumactl` to look at the mesh. As shown below, our default mesh does not have mTLS enabled.

```bash
$ ./kumactl get meshes
NAME      mTLS   CA        METRICS
default   off    builtin   off
```

### 14.  Let's enable mTLS.

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    ca:
      builtin: {}
    enabled: true
EOF
```

Using `kumactl`, inspect the mesh again to see if mTLS is enabled:

```bash
$ ./kumactl get meshes
NAME      mTLS   CA        METRICS
default   on     builtin   off
```

### 15.  Now let's enable traffic-permission for all services so our application will work like it use to:

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  namespace: kuma-demo
  name: everything
spec:
  sources:
  - match:
      service: '*'
  destinations:
  - match:
      service: '*'
EOF
```

Using `kumactl`, you can check the traffic permissions like this:
```bash
$ ./kumactl get traffic-permissions
MESH      NAME
default   everything
```

Now that we have traffic permission that allows any source to talk to any destination, our application should work like it use to. 

### 16. Deploy the logstash service.
You can deploy the logtash service using the [`kuma-demo-log.yaml`](/kubernetes/kuma-demo-log.yaml) file in this directory.
```bash
$ kubectl apply -f kuma-demo-log.yaml
namespace/logging created
service/logstash created
configmap/logstash-config created
deployment.apps/logstash created
```

### 17. Let's add logging for traffic between all services and send them to logstash: 
```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    ca:
      builtin: {}
    enabled: true
  logging:
    backends:
    - name: logstash
      format: |
        {
            "destination": "%KUMA_DESTINATION_SERVICE%",
            "destinationAddress": "%UPSTREAM_HOST%",
            "source": "%KUMA_SOURCE_SERVICE%",
            "sourceAddress": "%KUMA_SOURCE_ADDRESS%",
            "bytesReceived": "%BYTES_RECEIVED%",
            "bytesSent": "%BYTES_SENT%"
        }
      tcp:
        address: logstash.logging:5000
---
apiVersion: kuma.io/v1alpha1
kind: TrafficLog
mesh: default
metadata:
  namespace: kuma-demo
  name: everything
spec:
  sources:
  - match:
      service: '*'
  destinations:
  - match:
      service: '*'
  conf:
    backend: logstash
EOF
```
Logs will be sent to https://kumademo.loggly.com/

### 18. Now let's take down our Redis service because someone is spamming fake reviews. We can easily accomplish that by changing our traffic-permissions:

```bash
$ kubectl delete trafficpermission -n kuma-demo --all
```

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  namespace: kuma-demo
  name: frontend-to-backend
spec:
  sources:
  - match:
      service: frontend.kuma-demo.svc:80
  destinations:
  - match:
      service: backend.kuma-demo.svc:3001
---
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  namespace: kuma-demo
  name: backend-to-elasticsearch
spec:
  sources:
  - match:
      service: backend.kuma-demo.svc:3001
  destinations:
  - match:
      service: elasticsearch.kuma-demo.svc:80
EOF
```

This traffic-permission will only allow traffic from the kuma-demo-api service to the Elasticsearch service. Now try to access the reviews on each item. They will not load because of the traffic-permissions you described in the the policy above.

### 19. If we wanted to enable the Redis service again in the future, just change the traffic-permission back like this:
```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  namespace: kuma-demo
  name: backend-to-redis
spec:
  sources:
  - match:
      service: backend.kuma-demo.svc:3001
  destinations:
  - match:
      service: redis.kuma-demo.svc:6379
EOF
```

### 20. Let's explore adding traffic routing to our service mesh. But before we do, we need to scale up the v1 and v2 deployment of our sample application:
```bash
$ kubectl scale deployment kuma-demo-backend-v1 -n kuma-demo --replicas=1
deployment.extensions/kuma-demo-backend-v1 scaled
```
```bash
$ kubectl scale deployment kuma-demo-backend-v2 -n kuma-demo --replicas=1
deployment.extensions/kuma-demo-backend-v2 scaled
```
and check all the pods are running like this:
```bash
$ kubectl get pods -n kuma-demo
NAME                                    READY   STATUS    RESTARTS   AGE
es-v6t5t                                2/2     Running   0          5h56m
kuma-demo-app-85bb496b68-ccv2f          2/2     Running   0          5h56m
kuma-demo-backend-v0-bd9984f8f-d9tl7    2/2     Running   0          5h56m
kuma-demo-backend-v1-554c4d85c4-trt67   2/2     Running   0          16m
kuma-demo-backend-v2-6b6bc8f585-4qtjw   2/2     Running   0          16m
redis-master-b688d4f4-jjvvt             2/2     Running   0          5h56m
```
`v0` is set to have 0 sales, while `v1` has 1 special offer item, and lastly `v2` has 2 special offer. Here is a visual representation of how it looks:
```           
                        ----> backend-v0  :  service=backend, version=v0, env=prod
                      /
(browser) -> frontend   ----> backend-v1  :  service=backend, version=v1, env=intg
                      \
                        ----> backend-v2  :  service=backend, version=v2, env=dev
```

### 21. Define a handy alias that will can help show the power of Kuma's traffic routing:
```bash
$ alias benchmark='echo "NUM_REQ NUM_SPECIAL_OFFERS"; kubectl -n kuma-demo exec $( kubectl -n kuma-demo get pods -l app=kuma-demo-frontend -o=jsonpath="{.items[0].metadata.name}" ) -c kuma-fe -- sh -c '"'"'for i in `seq 1 100`; do curl -s http://backend:3001/items?q | jq -c ".[] | select(._source.specialOffer == true)" | wc -l ; done | sort | uniq -c | sort -k2n'"'"''
```
This alias will help send 100 request from `front-end` to `backend` and count the number of special offers in the response. Then it will group the request by the number of special offers. Here is an example of the output before we start configuring our traffic-routing.
```bash
$ benchmark
NUM_REQ    NUM_SPECIAL_OFFERS
34         0
33         1
33         2
```
The traffic is equally distributed because have not set any traffic-routing. Let's change that!

### 22. Traffic routing to limit amount of special offers on Kuma marketplace:
To avoid going broke, let's limit the amount of special offers that appear on our marketplace. To do so, apply this TrafficRoute policy:

```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: kuma.io/v1alpha1
kind: TrafficRoute
metadata:
  name: frontend-to-backend
  namespace: kuma-demo
mesh: default
spec:
  sources:
  - match:
      service: frontend.kuma-demo.svc:80
  destinations:
  - match:
      service: backend.kuma-demo.svc:3001
  conf:
  # it is NOT a percentage. just a positive weight
  - weight: 80
    destination:
      service: backend.kuma-demo.svc:3001
      version: v0
  # we're NOT checking if total of all weights is 100  
  - weight: 20
    destination:
      service: backend.kuma-demo.svc:3001
      version: v1
  # 0 means no traffic will be sent there
  - weight: 0
    destination:
      service: backend.kuma-demo.svc:3001
      version: v2
EOF
```
Run our benchmark to make sure no one is getting two special offers on the webpage:
```bash
$ benchmark
NUM_REQ    NUM_SPECIAL_OFFERS
84         0
16         1
```
And clean the traffic route before we try more things:
```bash
$ kubectl delete trafficroute -n kuma-demo --all
```

### 23. Resolving Collisions - Identical Selectors

Let's dive deeper into certain Kuma's traffic routing behaviors. If 2 routes have identical selectors but different destinations, how would Kuma handle it? Let's add start by creating this situation with the following traffic route policies:
```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: kuma.io/v1alpha1
kind: TrafficRoute
metadata:
  name: route-2                                         # notice the choice of a name
  namespace: kuma-demo
mesh: default
spec:
  sources:
  - match:
      service: frontend.kuma-demo.svc:80      # <<< same selector
  destinations:
  - match:
      service: backend.kuma-demo.svc:3001
  conf:
  - weight: 100
    destination:
      service: backend.kuma-demo.svc:3001
      version: v1       # <<< subset 1
EOF
```
and 

```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: kuma.io/v1alpha1
kind: TrafficRoute
metadata:
  name: route-1
  namespace: kuma-demo
mesh: default
spec:
  sources:
  - match:
      service: frontend.kuma-demo.svc:80      # <<< same selector
  destinations:
  - match:
      service: backend.kuma-demo.svc:3001
  conf:
  - weight: 100
    destination:
      service: backend.kuma-demo.svc:3001
      version: v2       # <<< subset 2
EOF
```

With two routes set up with identical selectors, let's try our `benchmark` alias again.
```bash
$ benchmark
NUM_REQ    NUM_SPECIAL_OFFERS
100        2
```
Due to ordering by name, the `TrafficRoute` with the name of `route-1` takes priority and all the traffic is routed to our `v2` application with 2 special offers.
Let's clean the traffic route before we try more things:
```bash
$ kubectl delete trafficroute -n kuma-demo --all
```

### 24. Resolving Collisions - Extra Tags

In the scenario where one route has more tag, what would happen? Apply these two routes and find out:

```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: kuma.io/v1alpha1
kind: TrafficRoute
metadata:
  name: route-1
  namespace: kuma-demo
mesh: default
spec:
  sources:
  - match:
      service: frontend.kuma-demo.svc:80      # <<< match by 1 tag
  destinations:
  - match:
      service: backend.kuma-demo.svc:3001
  conf:
  - weight: 100
    destination:
      service: backend.kuma-demo.svc:3001
      version: v0 # <<< subset 1
EOF
```
and
```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: kuma.io/v1alpha1
kind: TrafficRoute
metadata:
  name: route-2
  namespace: kuma-demo
mesh: default
spec:
  sources:
  - match:
      service: frontend.kuma-demo.svc:80      # <<< match by 2 tags
      env: prod                               
  destinations:
  - match:
      service: backend.kuma-demo.svc:3001
  conf:
  - weight: 100
    destination:
      service: backend.kuma-demo.svc:3001
      version: v2       # <<< subset 2
EOF
```
Now run the `benchmark` alias again:
```bash
$ benchmark
NUM_REQ    NUM_SPECIAL_OFFERS
100        2
```
Once again, our `route-2` traffic routing policy triumphs. In the scenario where one route has more tags, Kuma will prioritize that route.

### 25. Deploying Prometheus and Grafana on Kubernetes

Kuma supports Prometheus to scrape metrics and official [Grafana dashboards](https://grafana.com/orgs/konghq) to visualize the data. It is easily achievable by us installing all necessary components with `kumactl`:

```bash
$ ./kumactl install metrics | kubectl apply -f -
namespace/kuma-metrics created
podsecuritypolicy.policy/grafana created
configmap/grafana created
configmap/prometheus-alertmanager created
configmap/provisioning-datasource created
configmap/provisioning-dashboards created
configmap/prometheus-server created
persistentvolumeclaim/prometheus-alertmanager created
persistentvolumeclaim/prometheus-server created
serviceaccount/prometheus-alertmanager created
serviceaccount/prometheus-kube-state-metrics created
serviceaccount/prometheus-node-exporter created
serviceaccount/prometheus-pushgateway created
serviceaccount/prometheus-server created
serviceaccount/grafana created
clusterrole.rbac.authorization.k8s.io/prometheus-alertmanager created
clusterrole.rbac.authorization.k8s.io/prometheus-kube-state-metrics created
clusterrole.rbac.authorization.k8s.io/prometheus-pushgateway created
clusterrole.rbac.authorization.k8s.io/prometheus-server created
clusterrole.rbac.authorization.k8s.io/grafana-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-alertmanager created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-pushgateway created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-server created
clusterrolebinding.rbac.authorization.k8s.io/grafana-clusterrolebinding created
role.rbac.authorization.k8s.io/grafana created
rolebinding.rbac.authorization.k8s.io/grafana created
service/prometheus-alertmanager created
service/prometheus-kube-state-metrics created
service/prometheus-node-exporter created
service/prometheus-pushgateway created
service/prometheus-server created
service/grafana created
daemonset.apps/prometheus-node-exporter created
deployment.apps/grafana created
deployment.apps/prometheus-alertmanager created
deployment.apps/prometheus-kube-state-metrics created
deployment.apps/prometheus-pushgateway created
deployment.apps/prometheus-server created
```

To check everything is up and running correctly, you can check the pods in the new `kuma-metrics` namespace:

```bash
$ kubectl get pods -n kuma-metrics
NAME                                            READY   STATUS    RESTARTS   AGE
grafana-6c44dc568-frkj6                         1/1     Running   0          82s
prometheus-alertmanager-79d5747fd4-svgrp        2/2     Running   0          82s
prometheus-kube-state-metrics-85444db4f-zxqqk   1/1     Running   0          82s
prometheus-node-exporter-56wd6                  1/1     Running   0          82s
prometheus-pushgateway-6f5d78bc7f-fswxh         1/1     Running   0          82s
prometheus-server-77c8754d9c-q954g              3/3     Running   0          82s
```

### 26. Enable Prometheus metrics on the `mesh` object

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    ca:
      builtin: {}
    enabled: true
  metrics:
    prometheus: {}
EOF
```

### 27. Delete all existing pods in `kuma-demo` so pods restarts with necessary labels

```bash
$ kubectl delete pods --all -n kuma-demo
pod "es-wjhz4" deleted
pod "kuma-demo-app-7f799bbfdf-724w9" deleted
pod "kuma-demo-backend-v0-6548b88bf8-5rvzr" deleted
pod "kuma-demo-backend-v1-894bcd4bc-k6w6v" deleted
pod "kuma-demo-backend-v2-dffb4bffd-cxshc" deleted
pod "redis-master-6d4cf995c5-ss2j8" deleted
```

### 28. Port-forward the Grafana server pod to access the GUI

<pre><code>$ kubectl port-forward <b>${GRAFANA_SERVER_POD_NAME}</b> -n kuma-metrics 3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
</code></pre>

### 29. Access Grafana dashboard to visualize metrics

You can visit the [Grafana dashboard](http://localhost:3000/) to query the metrics that Prometheus is scraping from our Kuma mesh. If you are prompted to login, just use `admin:admin` as the username and password.

![grafana-dashboard](https://github.com/Kong/kuma-website/blob/master/docs/.vuepress/public/images/demo/mesh-grafana-dashboard.png?raw=true)

### 30. More visualizations with Kuma GUI

Kuma ships with an internal GUI that will help you visualize the mesh and its policies in an intuitive format. It can be found on port `:5683` on the control-plane pod. We port-forwarded this port [earlier](#10-now-we-will-port-forward-the-kuma-control-plane-so-we-can-access-it-with-kumactl) so now we can access the GUI at [http://localhost:5683/](http://localhost:5683/).

![kuma-gui](https://github.com/Kong/kuma-website/blob/master/docs/.vuepress/public/images/docs/0.3.2/gui-mesh-overview.png?raw=true)

### 31. Kong Gateway Integration 

The `Dataplane` can now operate in Gateway mode. This way you can integrate Kuma with existing API Gateways like [Kong](https://github.com/Kong/kong). Use the [`kuma-demo-kong.yaml`](/kubernetes/kuma-demo-kong.yaml) file to deploy [Kong for Kubernetes](https://github.com/Kong/kubernetes-ingress-controller):

```bash
$ kubectl apply -f kuma-demo-kong.yaml
customresourcedefinition.apiextensions.k8s.io/kongconsumers.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongcredentials.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongingresses.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongplugins.configuration.konghq.com created
serviceaccount/kong-serviceaccount created
clusterrole.rbac.authorization.k8s.io/kong-ingress-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/kong-ingress-clusterrole-nisa-binding created
configmap/kong-server-blocks created
service/kong-proxy created
service/kong-validation-webhook created
deployment.apps/ingress-kong created
```

On Kubernetes, `Dataplane` entities are automatically generated. To inject gateway Dataplane, the API Gateway's Pod needs to have the following `kuma.io/gateway: enabled` annotation:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-kong
  ...
spec:
  template:
    metadata:
      annotations:
        kuma.io/gateway: enabled
```
 Our [`kuma-demo-kong.yaml`](/kubernetes/kuma-demo-kong.yaml) already includes this annotataion so you don't need to do this manually.

After Kong is deployed, export the proxy IP:
```bash
export PROXY_IP=$(minikube service -p kuma-demo -n kuma-demo kong-proxy --url | head -1)
```

And lastly to check that the proxy IP has been exported, run:
```bash
$ echo $PROXY_IP
http://192.168.64.29:30409
```

### 32. Add ingress rules for Kong for Kubernetes

Create an Ingress rule to proxy to the marketplace frontend service:

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: marketplace
  namespace: kuma-demo
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          serviceName: frontend
          servicePort: 80
EOF
```

By default, Kong Ingress Controller distributes traffic amongst all the Pods of a Kubernetes Service by forwarding the requests directly to Pod IP addresses. One can choose the load-balancing strategy to use by specifying a KongIngress resource.

However, in some use-cases, the load-balancing should be left up to kube-proxy, or a sidecar component in the case of Service Mesh deployments. We want the load-balancing to be left to Kuma so the following annotation has been included in our [`kuma-demo-aio.yaml`](/kubernetes/kuma-demo-aio.yaml) frontend service resource:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: kuma-demo
  annotations:
    ingress.kubernetes.io/service-upstream: "true"
spec:
  ...
```

Remember to add this annotation to the appropriate services when you deploy Kong with Kuma.

### 33. Add traffic permission for Kong to the frontend service:
```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  namespace: kuma-demo
  name: kong-to-frontend
spec:
  sources:
  - match:
      service: kong-proxy.kuma-demo.svc:80
  destinations:
  - match:
      service: frontend.kuma-demo.svc:80
EOF
```

### 34. Access the marketplace through Kong

Now if we visit the `$PROXY_IP`, you will land in the same marketplace application we deployed earlier.
