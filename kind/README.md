# Kind Deployment Guide

This is a simplified deployment of Kuma and the Demo application on top of [kind](https://kind.sigs.k8s.io/). It follows the steps described in [kubernetes](../kubernetes/README.md) folder, replacing the Minikube deployment.

## Prerequisites

There are only two prerequisites required before you run the demo: [docker](https://docs.docker.com/get-docker/) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Running the demo

Running the demo is easy, just type `./kind.sh` and the script will download, deploy and configure everything as described in [kubernetes](../kubernetes/README.md). The script output looks like this:

```shell script
$ ./kind.sh 
64-bit platform found
Creating cluster "kuma" ...
 ✓ Ensuring node image (kindest/node:v1.18.2) 🖼
 ✓ Preparing nodes 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
 ✓ Waiting ≤ 2m0s for control-plane = Ready ⏳
 • Ready after 0s 💚
Set kubectl context to "kind-kuma"
You can now use your cluster with:

kubectl cluster-info --context kind-kuma --kubeconfig /Users/nickolaev/.kube/kind-kuma-config

Thanks for using kind! 😊
node/kuma-control-plane untainted
namespace/kuma-system created
secret/kuma-sds-tls-cert created
secret/kuma-admission-server-tls-cert created
configmap/kuma-control-plane-config created
serviceaccount/kuma-control-plane created
customresourcedefinition.apiextensions.k8s.io/dataplaneinsights.kuma.io created
customresourcedefinition.apiextensions.k8s.io/dataplanes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/faultinjections.kuma.io created
customresourcedefinition.apiextensions.k8s.io/healthchecks.kuma.io created
customresourcedefinition.apiextensions.k8s.io/meshes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/proxytemplates.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficlogs.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficpermissions.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficroutes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/traffictraces.kuma.io created
clusterrole.rbac.authorization.k8s.io/kuma:control-plane created
clusterrolebinding.rbac.authorization.k8s.io/kuma:control-plane created
role.rbac.authorization.k8s.io/kuma:control-plane created
rolebinding.rbac.authorization.k8s.io/kuma:control-plane created
service/kuma-control-plane created
deployment.apps/kuma-control-plane created
mutatingwebhookconfiguration.admissionregistration.k8s.io/kuma-admission-mutating-webhook-configuration created
validatingwebhookconfiguration.admissionregistration.k8s.io/kuma-validating-webhook-configuration created
pod/kuma-control-plane-6f55dbcc74-nnhnl condition met
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
pod/kuma-demo-app-69c9fd4bd-rj8pp condition met
pod/kuma-demo-backend-v0-d7cb6b576-g5lft condition met
pod/redis-master-78ff699f7-4v579 condition met
NAME                                  READY   STATUS    RESTARTS   AGE
kuma-control-plane-6f55dbcc74-nnhnl   1/1     Running   0          2m25s
NAME                                   READY   STATUS    RESTARTS   AGE
kuma-demo-app-69c9fd4bd-rj8pp          2/2     Running   0          2m9s
kuma-demo-backend-v0-d7cb6b576-g5lft   2/2     Running   0          2m9s
postgres-master-65df766577-6dn68       2/2     Running   0          2m8s
redis-master-78ff699f7-4v579           2/2     Running   0          2m9s
Waiting for the port forwarding to finish
added Control Plane "kind"
switched active Control Plane to "kind"
MESH      NAME                                             TAGS                                                                                                                       STATUS   LAST CONNECTED AGO   LAST UPDATED AGO   TOTAL UPDATES   TOTAL ERRORS   CERT REGENERATED AGO   CERT EXPIRATION   CERT REGENERATIONS
default   kuma-demo-app-69c9fd4bd-rj8pp.kuma-demo          app=kuma-demo-frontend env=prod pod-template-hash=69c9fd4bd protocol=http service=frontend.kuma-demo.svc:8080 version=v8   Online   6s                   5s                 4               0              never                  -                 0
default   kuma-demo-backend-v0-d7cb6b576-g5lft.kuma-demo   app=kuma-demo-backend env=prod pod-template-hash=d7cb6b576 protocol=http service=backend.kuma-demo.svc:3001 version=v0     Online   7s                   6s                 4               0              never                  -                 0
default   postgres-master-65df766577-6dn68.kuma-demo       app=postgres pod-template-hash=65df766577 protocol=tcp service=postgres.kuma-demo.svc:5432                                 Online   5s                   4s                 4               0              never                  -                 0
default   redis-master-78ff699f7-4v579.kuma-demo           app=redis pod-template-hash=78ff699f7 protocol=tcp role=master service=redis.kuma-demo.svc:6379 tier=backend               Online   8s                   6s                 4               0              never                  -                 0

Kuma GUI is available at printf http://localhost:5683/  ⬅️
Kuma DEMO is available at http://localhost:8080/  ⬅️

For more about Integrations and Metrics see https://github.com/kumahq/kuma-demo/tree/master/kubernetes#integrations

To see Kuma in action, follow the Policies guidelines https://github.com/kumahq/kuma-demo/tree/master/kubernetes#policies

🛑 Before using kubectl, please run the following in your shell:

export KUBECONFIG=/Users/nickolaev/.kube/kind-kuma-config

Type 'quit' to exit.
```

As the message states, the Demo site can be found at [http://localhost:8080](http://locahost:8080) and the Kuma GUI at [http://localhost:5683](http://locahost:5683). You can also use `kubectl` and `${HOME}/bin/kumactl` to explore the deployment and configuration following the [integration](https://github.com/kumahq/kuma-demo/tree/master/kubernetes#integrations) and [policies](https://github.com/kumahq/kuma-demo/tree/master/kubernetes#policies) guides.

After you're done poking around you should type `quit` to exit the demo and cleanup the created cluster:

```shell script
Kuma GUI is available at printf http://localhost:5683/  ⬅️
Kuma DEMO is available at http://localhost:8080/  ⬅️

For more about Integrations and Metrics see https://github.com/kumahq/kuma-demo/tree/master/kubernetes#integrations

To see Kuma in action, follow the Policies guidelines https://github.com/kumahq/kuma-demo/tree/master/kubernetes#policies

🛑 Before using kubectl, please run the following in your shell:

export KUBECONFIG=/Users/nickolaev/.kube/kind-kuma-config

Type 'quit' to exit.
quit
Cleaning up
Deleting cluster "kuma" ...
```
