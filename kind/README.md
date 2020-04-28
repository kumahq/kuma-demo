# Kind Deployment Guide

This is a simplified deployment of Kuma and the Demo application on top of [kind](https://kind.sigs.k8s.io/). It follows the steps described in [kubernetes](../kubernetes/README.md) folder, replacing the Minikube deployment.

## Prerequisites

There are only two prerequisites required before you run the demo: [docker](https://docs.docker.com/get-docker/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Running the demo

Running the demo is easy, just type `./kind.sh` and the script will download, deploy and configure everything as described in [kubernetes](../kubernetes/README.md). In the end it will 

```shell script
$ ./kind.sh 
64-bit platform found
Creating cluster "kuma" ...
 ✓ Ensuring node image (kindest/node:v1.18.2) 🖼 
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
 ✓ Waiting ≤ 2m0s for control-plane = Ready ⏳ 
 • Ready after 23s 💚
Set kubectl context to "kind-kuma"
You can now use your cluster with:

kubectl cluster-info --context kind-kuma

Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂
node/kuma-control-plane untainted
namespace/kuma-system created
secret/kuma-sds-tls-cert created
secret/kuma-admission-server-tls-cert created
secret/kuma-injector-tls-cert created
configmap/kuma-control-plane-config created
configmap/kuma-injector-config created
serviceaccount/kuma-control-plane created
serviceaccount/kuma-injector created
customresourcedefinition.apiextensions.k8s.io/dataplaneinsights.kuma.io created
customresourcedefinition.apiextensions.k8s.io/dataplanes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/healthchecks.kuma.io created
customresourcedefinition.apiextensions.k8s.io/meshes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/proxytemplates.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficlogs.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficpermissions.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficroutes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/traffictraces.kuma.io created
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
pod/kuma-control-plane-965bf6fd4-tg8sx condition met
pod/kuma-injector-696484d998-9jprt condition met
namespace/kuma-demo created
deployment.apps/postgres-master created
service/postgres created
deployment.apps/redis-master created
service/redis created
service/backend created
deployment.apps/kuma-demo-backend-v0 created
deployment.apps/kuma-demo-backend-v1 created
deployment.apps/kuma-demo-backend-v2 created
service/frontend created
deployment.apps/kuma-demo-app created
pod/kuma-demo-app-68758d8d5d-6hmz5 condition met
pod/kuma-demo-backend-v0-6fdb79ddfd-pg82b condition met
pod/postgres-master-78d9c9c8c9-p7swm condition met
pod/redis-master-657c58c859-9r57p condition met
NAME                                 READY   STATUS    RESTARTS   AGE
kuma-control-plane-965bf6fd4-tg8sx   1/1     Running   0          80s
kuma-injector-696484d998-9jprt       1/1     Running   0          80s
NAME                                    READY   STATUS    RESTARTS   AGE
kuma-demo-app-68758d8d5d-6hmz5          2/2     Running   0          56s
kuma-demo-backend-v0-6fdb79ddfd-pg82b   2/2     Running   0          56s
postgres-master-78d9c9c8c9-p7swm        2/2     Running   0          56s
redis-master-657c58c859-9r57p           2/2     Running   0          56s
Error: Control Plane with name "kind" already exists. Use --overwrite to replace an existing one.
MESH      NAME                                              TAGS                                                                                                                        STATUS   LAST CONNECTED AGO   LAST UPDATED AGO   TOTAL UPDATES   TOTAL ERRORS
default   kuma-demo-app-68758d8d5d-6hmz5.kuma-demo          app=kuma-demo-frontend env=prod pod-template-hash=68758d8d5d protocol=http service=frontend.kuma-demo.svc:8080 version=v8   Online   3s                   2s                 4               0
default   kuma-demo-backend-v0-6fdb79ddfd-pg82b.kuma-demo   app=kuma-demo-backend env=prod pod-template-hash=6fdb79ddfd protocol=http service=backend.kuma-demo.svc:3001 version=v0     Online   4s                   3s                 4               0
default   postgres-master-78d9c9c8c9-p7swm.kuma-demo        app=postgres pod-template-hash=78d9c9c8c9 protocol=tcp service=postgres.kuma-demo.svc:5432                                  Online   4s                   2s                 4               0
default   redis-master-657c58c859-9r57p.kuma-demo           app=redis pod-template-hash=657c58c859 protocol=tcp role=master service=redis.kuma-demo.svc:6379 tier=backend               Online   6s                   4s                 4               0
Kuma GUI is available at http://localhost:5683/
Kuma DEMO is available at http://localhost:8080/
Type 'quit' to exit.
```

As the message states, the Demo site can be found at [http://localhost:8080](http://locahost:8080) and the Kuma GUI at [http://localhost:5683](http://locahost:5683). You can also use `kubectl` and `${HOME}/bin/kumactl` to explore the deployment and configuration.

After you're done poking around you should type `quit` to exit the demo and cleanup the created cluster:

```shell script
Kuma GUI is available at http://localhost:5683/
Kuma DEMO is available at http://localhost:8080/
Type 'quit' to exit.

quit
Cleanup
Deleting cluster "kuma" ...
```
