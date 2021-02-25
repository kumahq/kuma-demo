# Kubernetes Deployment Guide

## Introductions

In this directory, you will find the necessary files and instructions to get Kuma up and running in Kubernetes mode via Minikube. 

When running on Kubernetes, Kuma will store all of its state and configuration on the underlying Kubernetes API Server, therefore requiring no dependency to store the data.

## Table of Contents
- [Kubernetes Deployment Guide](#kubernetes-deployment-guide)
  - [Introductions](#introductions)
  - [Table of Contents](#table-of-contents)
  - [Setup Environment](#setup-environment)
    - [Kind](#kind)
    - [Minikube](#minikube)
    - [Marketplace application](#marketplace-application)
    - [Kuma](#kuma)
      - [Download](#download)
      - [Installation](#installation)
  - [Tools](#tools)
    - [kumactl](#kumactl)
      - [Setup](#setup)
      - [Inspect](#inspect)
    - [GUI](#gui)
  - [Integrations](#integrations)
    - [Kong Gateway](#kong-gateway)
      - [Installation](#installation-1)
      - [Configuration](#configuration)
    - [Prometheus and Grafana](#prometheus-and-grafana)
      - [Installation](#installation-2)
  - [Policies](#policies)
    - [mTLS](#mtls)
      - [Check for mTLS](#check-for-mtls)
      - [Adding mTLS Policy](#adding-mtls-policy)
    - [Traffic Permissions](#traffic-permissions)
      - [Adding Granular Traffic Permissions](#adding-granular-traffic-permissions)
    - [Traffic Routing](#traffic-routing)
      - [Scale Replicas](#scale-replicas)
      - [Adding Routing Policy](#adding-routing-policy)
    - [Health Check](#health-check)
      - [Adding Health Check Policy](#adding-health-check-policy)
    - [Traffic Metrics](#traffic-metrics)
      - [Adding Traffic Metric Policy](#adding-traffic-metric-policy)
      - [Query Metrics](#query-metrics)
    - [Traffic Log](#traffic-log)
      - [Setup](#setup-1)
      - [Adding Logging Policy](#adding-logging-policy)
    - [Traffic Trace](#traffic-trace)
      - [Jaeger Installation](#jaeger-installation)
      - [Adding Traffic Tracing Policy](#adding-traffic-tracing-policy)
      - [Visualizing Traces](#visualizing-traces)
    - [Fault Injection](#fault-injection)
      - [Adding Fault Injection Policy](#adding-fault-injection-policy)

## Setup Environment

### Kind
The top-level folder `kind` contains a convenient script [kind.sh](../kind/kind.sh), which will automatically deploy a simple Kubernetes cluster on top of docker using [KIND](https://kind.sigs.k8s.io/docs/user/quick-start/).
It will also deploy [Kuma](kuma.io) and install the [Kuma Demo](https://github.com/kumahq/kuma-demo) application. Refer to the [README.md](../kind/README.md) in that folder
in order to get more info what are the pre-requisites (just Docker and `kubectl`) to use the script. Choosing this option, you can skip directly to [Integrations](#integrations) and [Policies](#policies),
to further explore Kuma.

### Minikube

We'll be using Minikube to deploy our application and Kuma to illustrate the mesh's capabilities in Kubernetes mode. Please follow Minikube's [installation guide](https://kubernetes.io/docs/tasks/tools/install-minikube/) to have it set up correctly before proceeding.

Once you have Minikube installed, we will need to start a Kubernetes cluster on it with at least 6GB of memory to run the full demo smoothly. You can allocate less memory if you plan on leaving out the [Kong Ingress Gateway](#kong-gateway) and some of the [observability steps](#prometheus-and-grafana). Another thing to note is that Kuma is tested on Kubernetes version v1.13.0 - v1.18.x, so use anything older or newer with caution. 

Run the following command to start up a cluster:
```bash
$ minikube start --cpus 2 --memory 6144 --kubernetes-version v1.18.12 -p kuma-demo
😄  [kuma-demo] minikube v1.15.1 on Darwin 10.15.3
✨  Automatically selected the docker driver. Other choices: hyperkit, virtualbox
👍  Starting control plane node kuma-demo in cluster kuma-demo
🔥  Creating docker container (CPUs=2, Memory=6144MB) ...
🐳  Preparing Kubernetes v1.18.12 on Docker 19.03.13 ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "kuma-demo" cluster and "default" namespace by default
```


### Marketplace application

Run the following command to deploy the marketplace application via [`bit.ly/demokuma`](https://www.bit.ly/demokuma), which points to the [all-in-one YAML file](/kubernetes/kuma-demo-aio.yaml) provided in this directory:
```bash
$ kubectl apply -f https://bit.ly/demokuma
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
```

And then check the pods are up and running by getting all pods in the `kuma-demo` namespace:

```bash
$ kubectl get pods -n kuma-demo
NAME                                   READY   STATUS    RESTARTS   AGE
kuma-demo-app-69c9fd4bd-hfzg2          2/2     Running   0          31s
kuma-demo-backend-v0-d7cb6b576-tbtcl   2/2     Running   0          31s
postgres-master-65df766577-9bc2s       2/2     Running   0          31s
redis-master-78ff699f7-hk4q7           2/2     Running   0          31s
```

The [all-in-one YAML file](/kubernetes/kuma-demo-aio.yaml) deploys our application across four pods:
1. The first pod is the frontend application that will give you a GUI to query the items/reviews.
   * Throughout this guide, we will be port-forwarding this `kuma-demo-app-656c95dcb5-6pshm` pod to access the marketplace's frontend GUI. Please replace any reference of this pod with your pod's name.
2. The second pod is a Node application that represents a backend.
   * We have three deployments for `kuma-demo-backend-v*` in the [all-in-one YAML file](/kubernetes/kuma-demo-aio.yaml). The v1 and v2 deployments currently have 0 replicas, but will be scaled up later when we cover Kuma's Traffic Routing policy.  
3. The third pod is an PostgreSQL service that stores all the items in our marketplace.
4. The fourth pod is a Redis service that stores reviews for each item.

![app-diagram](https://github.com/kumahq/kuma-website/blob/master/docs/.vuepress/public/images/diagrams/diagram-kuma-demo-basic.jpg?raw=true)

To access the front-end UI on [http://localhost:8080](http://localhost:8080), port-forward your `frontend` service like so:
```bash
$ kubectl port-forward service/frontend -n kuma-demo 8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

![frontend-gui](https://raw.githubusercontent.com/kumahq/kuma-website/master/docs/.vuepress/public/images/demo/kuma-demo-app-gui.png)

This marketplace application is currently running **WITHOUT** Kuma. So all traffic is going directly between the services, and not routed through any data plane proxies. In the next step, we will download Kuma and quickly deploy the mesh alongside an existing application. 

### Kuma

Kuma is an open-source control plane for modern connectivity, delivering high performance and reliability with Envoy. We will have to download it first and then install it onto the Kubernetes cluster.

#### Download

Please check out [Kuma's official installation page](https://kuma.io/install) to see all the installation methods. For simplicity, run the following script to automatically detect the operating system and download Kuma:

```bash
$ curl -L https://kuma.io/installer.sh | sh -
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3057  100  3057    0     0  11238      0 --:--:-- --:--:-- --:--:-- 11238

INFO	Welcome to the Kuma automated download!
INFO	Fetching latest Kuma version..
INFO	Kuma version: 1.0.1
INFO	Kuma architecture: amd64
INFO	Operating system: darwin
INFO	Downloading Kuma from: https://kong.bintray.com/kuma/kuma-1.0.1-darwin-amd64.tar.gz

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 60.5M  100 60.5M    0     0  6749k      0  0:00:09  0:00:09 --:--:-- 7389k

INFO	Kuma 1.0.1 has been downloaded!

Welcome to Kuma!

===============================================================================

This folder contains your download of Kuma:

├── NOTICE
├── README
├── bin
│   ├── envoy
│   ├── kuma-cp
│   ├── kuma-dp
│   ├── kuma-prometheus-sd
│   └── kumactl
└── conf
    └── kuma-cp.conf.yml

===============================================================================

To get started with Kuma you can take a look at the official documentation:

* Documentation: https://kuma.io/docs
* Slack Chat: https://kuma.io/community

KUBERNETES:

If you are installing Kuma on Kubernetes, run the following command:

$ kumactl install control-plane | kubectl apply -f -

UNIVERSAL:

If you are installing Kuma on other platforms, just run:

$ kuma-cp run

In Universal Kuma runs with the in-memory backend by default. To use Postgres
instead please read the docs:

* https://kuma.io/docs/latest/documentation/backends/

NEXT STEPS:

You can now explore the Kuma GUI on `http://localhost:5681/gui`!

Finally, you can start using Kuma by apply traffic policies to any service
running in your system:

* https://kuma.io/policies/
```

Next, navigate into the `kuma-1.0.1/bin` directory where the kuma components will be:

```bash
$ cd kuma-1.0.1/bin && ls
envoy              kuma-dp            kumactl
kuma-cp            kuma-prometheus-sd
```
On Kubernetes, of all the Kuma binaries in the bin folder, we only need kumactl. The kumactl executable is a very important component in your journey with Kuma. It allows to retrieve the state of Kuma and the configured policies in every environment. On Kubernetes it is read-only, because you are supposed to change the state of Kuma by leveraging Kuma's CRDs. But it does provides helpers to install Kuma on Kubernetes via `kumactl install [..]` command. 

#### Installation

Using `kumactl install [..]`, install the control-plane onto the Kubernetes cluster we have deployed:

```bash
$ ./kumactl install control-plane | kubectl apply -f -
namespace/kuma-system created
serviceaccount/kuma-control-plane created
secret/kuma-tls-cert created
configmap/kuma-control-plane-config created
customresourcedefinition.apiextensions.k8s.io/circuitbreakers.kuma.io created
customresourcedefinition.apiextensions.k8s.io/dataplanes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficpermissions.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficroutes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/traffictraces.kuma.io created
customresourcedefinition.apiextensions.k8s.io/zoneinsights.kuma.io created
customresourcedefinition.apiextensions.k8s.io/zones.kuma.io created
customresourcedefinition.apiextensions.k8s.io/dataplaneinsights.kuma.io created
customresourcedefinition.apiextensions.k8s.io/externalservices.kuma.io created
customresourcedefinition.apiextensions.k8s.io/faultinjections.kuma.io created
customresourcedefinition.apiextensions.k8s.io/healthchecks.kuma.io created
customresourcedefinition.apiextensions.k8s.io/meshinsights.kuma.io created
customresourcedefinition.apiextensions.k8s.io/meshes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/proxytemplates.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficlogs.kuma.io created
clusterrole.rbac.authorization.k8s.io/kuma-control-plane created
clusterrolebinding.rbac.authorization.k8s.io/kuma-control-plane created
role.rbac.authorization.k8s.io/kuma-control-plane created
rolebinding.rbac.authorization.k8s.io/kuma-control-plane created
service/kuma-control-plane created
deployment.apps/kuma-control-plane created
mutatingwebhookconfiguration.admissionregistration.k8s.io/kuma-admission-mutating-webhook-configuration created
validatingwebhookconfiguration.admissionregistration.k8s.io/kuma-validating-webhook-configuration created
```

And then check the pods are up and running by getting all pods in the `kuma-system` namespace

```bash
$ kubectl get pods -n kuma-system
NAME                                  READY   STATUS    RESTARTS   AGE
kuma-control-plane-7fd6877cd5-4rjmv   1/1     Running   0          57s
```

The installation commands will deploy these one pod:
1. Kuma control-plane: Kuma (kuma-cp) is one single executable written in GoLang that can be installed anywhere, hence why it's both universal and simple to deploy. When running on Kubernetes, no external dependencies required, since it leverages the underlying K8s API server to store its configuration. In Kubernetes, it will also automatically inject sidecar data plane proxies without human intervention. For this service to work, you need to label the namespaces with `kuma.io/sidecar-injection: enabled`. The [all-in-one YAML file](/kubernetes/kuma-demo-aio.yaml) that deployed the marketplace application already has the label so you do not need to edit it.

Now that we have the control-plane in our cluster, we need to delete the existing pods (or perform a rolling update) so the injector can do its job.

```bash
$ kubectl delete pods --all -n kuma-demo
pod "kuma-demo-app-69c9fd4bd-hfzg2" deleted
pod "kuma-demo-backend-v0-d7cb6b576-tbtcl" deleted
pod "postgres-master-65df766577-9bc2s" deleted
pod "redis-master-78ff699f7-hk4q7" deleted
```
And then check the pods are up and running by getting all pods in the `kuma-demo` namespace:

```bash
$ kubectl get pods -n kuma-demo -w
NAME                                   READY   STATUS    RESTARTS   AGE
kuma-demo-app-69c9fd4bd-lkhqm          2/2     Running   0          21s
kuma-demo-backend-v0-d7cb6b576-cp4fm   2/2     Running   0          21s
postgres-master-65df766577-9767x       2/2     Running   0          21s
redis-master-78ff699f7-wdc5p           2/2     Running   0          20s
```
It looks near identical **except** each pod now has an additional container. The additional container is the Envoy sidecar proxy that the control-plane is automatically adding to each pod. 

To access the front-end UI on [http://localhost:8080](http://localhost:8080), port-forward your `frontend` service again:
```bash
$ kubectl port-forward service/frontend -n kuma-demo 8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

The marketplace application is now running with Kuma, but will be identical to the version with Kuma. The underlying difference is that all the services are now sending traffic to the Envoy data plane proxies within the same pod, and the Envoy proxies will communicate to each other. But the user will not see any visual change!

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

## Tools

### kumactl

The kumactl application is a CLI client for the underlying HTTP API of Kuma. Therefore, you can access the state of Kuma by leveraging with the API directly. In universal mode you will be able to also make changes via the HTTP API, while in Kubernetes mode the HTTP API is read-only.

#### Setup 

You can configure kumactl to point to any remote Kuma control-plane instance. Before you can configure your local kumactl to point to control-plane running in the `kuma-system` namespace, we need to port-forward the pod. Please note that your pod name will be different than mine, so copy the one that you see on your cluster.

First, port-forward the `kuma-control-plane` service in the `kuma-system` namespace:

```bash
$ kubectl port-forward service/kuma-control-plane -n kuma-system 5681
Forwarding from 127.0.0.1:5681 -> 5681
Forwarding from [::1]:5681 -> 5681
```

The port we forwarded is:
- 5681: the HTTP API server that is being used by kumactl to retrieve the state of your configuration and policies on every environment

Next, configure kumactl to point to the address where the HTTP API server sits:
```bash
$ ./kumactl config control-planes add --name=minikube --address=http://localhost:5681
added Control Plane "minikube"
switched active Control Plane to "minikube"
```

#### Inspect

Once kumactl is pointing to the correct control-plane, you can use it to inspect the data plane proxies in the mesh.

```
$ ./kumactl inspect dataplanes
MESH      NAME                                             TAGS                                                                                                                                       STATUS   LAST CONNECTED AGO   LAST UPDATED AGO   TOTAL UPDATES   TOTAL ERRORS   CERT REGENERATED AGO   CERT EXPIRATION   CERT REGENERATIONS
default   kuma-demo-app-69c9fd4bd-lkhqm.kuma-demo          app=kuma-demo-frontend env=prod kuma.io/protocol=http kuma.io/service=frontend_kuma-demo_svc_8080 pod-template-hash=69c9fd4bd version=v8   Online   1m                   1m                 4               0              never                  -                 0
default   kuma-demo-backend-v0-d7cb6b576-cp4fm.kuma-demo   app=kuma-demo-backend env=prod kuma.io/protocol=http kuma.io/service=backend_kuma-demo_svc_3001 pod-template-hash=d7cb6b576 version=v0     Online   1m                   1m                 4               0              never                  -                 0
default   postgres-master-65df766577-9767x.kuma-demo       app=postgres kuma.io/protocol=tcp kuma.io/service=postgres_kuma-demo_svc_5432 pod-template-hash=65df766577                                 Online   1m                   1m                 4               0              never                  -                 0
default   redis-master-78ff699f7-wdc5p.kuma-demo           app=redis kuma.io/protocol=tcp kuma.io/service=redis_kuma-demo_svc_6379 pod-template-hash=78ff699f7 role=master tier=backend               Online   1m                   1m                 4               0              never                  -                 0
```

There are 4 data plane proxies which correlates with each component of our application

### GUI

Kuma ships with an internal GUI that will help you visualize the mesh and its policies in an intuitive format. The GUI is also open-source so you can find the source code in the [kuma-gui repository](https://github.com/kumahq/kuma-gui). It can be found on port :5681 on the control-plane machine, which we just port-forwarded above. Navigate to [http://localhost:5681/gui](http://localhost:5681/gui) to use Kuma's GUI.

![kuma-gui](https://raw.githubusercontent.com/kumahq/kuma-website/master/docs/.vuepress/public/images/demo/kuma-gui-welcome-0.4.0.png)

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

## Integrations

### Kong Gateway

Using [Kong for Kubernetes](https://github.com/Kong/kubernetes-ingress-controller), you can easily deploy Kong alongside Kuma and configure it all using Custom Resource Definitions(CRDs) and Kubernetes-native tooling.

#### Installation

The data plane proxy can now operate in [Gateway mode](https://kuma.io/docs/latest/documentation/dps-and-data-model/#gateway). This way you can integrate Kuma with existing API Gateways like [Kong](https://github.com/Kong/kong). Run the following command to deploy [Kong for Kubernetes](https://github.com/Kong/kubernetes-ingress-controller) via [`bit.ly/demokumakong`](https://www.bit.ly/demokumakong), which points to the [kuma-demo-kong YAML file](/kubernetes/kuma-demo-kong.yaml) provided in this directory:

```bash
$ kubectl apply -f https://bit.ly/demokumakong
customresourcedefinition.apiextensions.k8s.io/kongclusterplugins.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongconsumers.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongcredentials.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongingresses.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/kongplugins.configuration.konghq.com created
customresourcedefinition.apiextensions.k8s.io/tcpingresses.configuration.konghq.com created
serviceaccount/kong-serviceaccount created
clusterrole.rbac.authorization.k8s.io/kong-ingress-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/kong-ingress-clusterrole-nisa-binding created
configmap/kong-server-blocks created
service/kong-proxy created
service/kong-validation-webhook created
deployment.apps/ingress-kong created
```

This deployment is slightly modified from the [original one](https://github.com/Kong/kubernetes-ingress-controller/blob/master/deploy/single/all-in-one-dbless.yaml) in the Kong for Kubernetes repository. We added the annotation `80.service.kuma.io/protocol: "http"` to the `kong-proxy` service and `kuma.io/gateway: enabled` annotation to the API gateway pod so the control-plane knows to inject a gateway data plane proxy. If you check the pods in the `kuma-demo` namespace, Kong wil be running alongside the application we deployed earlier:

```bash
$ kubectl get pods -n kuma-demo
NAME                                   READY   STATUS    RESTARTS   AGE
ingress-kong-5965cbfc79-2lwpq          3/3     Running   0          90s
kuma-demo-app-69c9fd4bd-lkhqm          2/2     Running   0          4m19s
kuma-demo-backend-v0-d7cb6b576-cp4fm   2/2     Running   0          4m19s
postgres-master-65df766577-9767x       2/2     Running   0          4m19s
redis-master-78ff699f7-wdc5p           2/2     Running   0          4m18s
```

After Kong is deployed, use `minikube service` to get the proxy URL:
```bash
$ minikube service -p kuma-demo -n kuma-demo kong-proxy --url
🏃  Starting tunnel for service kong-proxy.
|-----------|------------|-------------|------------------------|
| NAMESPACE |    NAME    | TARGET PORT |          URL           |
|-----------|------------|-------------|------------------------|
| kuma-demo | kong-proxy |             | http://127.0.0.1:55275 |
|           |            |             | http://127.0.0.1:55276 |
|-----------|------------|-------------|------------------------|
http://127.0.0.1:55275
http://127.0.0.1:55276
❗  Because you are using a Docker driver on darwin, the terminal needs to be open to run it.
```

![kong-gateway](https://raw.githubusercontent.com/Kong/kuma-website/master/docs/.vuepress/public/images/demo/kuma-kong-plugins.png)

#### Configuration

After deploying the gateway in our existing mesh, the next step is to add an Ingress rule. Create an Ingress rule to proxy to the marketplace frontend service:

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
          servicePort: 8080
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

After adding the Ingress rule, you can access the same marketplace application via the `$PROXY_IP`. You no longer have to port-forward the `frontend` service on port 8080 since all traffic into the mesh will be handled by this gateway.

### Prometheus and Grafana

Out-of-the-box, Kuma provides full integration with Prometheus and Grafana. If enabled, every data plane proxy will expose its metrics in Prometheus format. Furthermore, Kuma will make sure that Prometheus can automatically find every data plane proxy in the mesh.

#### Installation

In Kubernetes mode, we can use `kumactl install [..]` again to install the pre-configured Prometheus and Grafana components onto the Kubernetes cluster we have deployed:

```
$ ./kumactl install metrics | kubectl apply -f -
namespace/kuma-metrics created
podsecuritypolicy.policy/grafana created
serviceaccount/prometheus-alertmanager created
serviceaccount/prometheus-kube-state-metrics created
serviceaccount/prometheus-node-exporter created
serviceaccount/prometheus-pushgateway created
serviceaccount/prometheus-server created
serviceaccount/grafana created
configmap/grafana created
configmap/prometheus-alertmanager created
configmap/provisioning-datasource created
configmap/provisioning-dashboards created
configmap/prometheus-server created
persistentvolumeclaim/prometheus-alertmanager created
persistentvolumeclaim/prometheus-server created
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

To check if everything has been deployed, check the `kuma-metrics` namespace:

```
$ kubectl get pods -n kuma-metrics
NAME                                             READY   STATUS    RESTARTS   AGE
grafana-7b7b687898-qgztc                         2/2     Running   0          3m17s
prometheus-alertmanager-785975cffb-frbdw         3/3     Running   0          3m17s
prometheus-kube-state-metrics-6d68cd67f6-x99km   2/2     Running   2          3m17s
prometheus-node-exporter-dlj42                   1/1     Running   0          3m17s
prometheus-pushgateway-7b7bc5dff7-krxtc          2/2     Running   0          3m16s
prometheus-server-5d8f6bf796-7mhnt               4/4     Running   0          3m16s
```

Once the pods are all up and running, we need to edit the Kuma Mesh object to include the `metrics: prometheus` section you see below. It is not included by default so you can edit the Mesh object using kubectl like so:

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  metrics:
    enabledBackend: prometheus-1
    backends:
    - name: prometheus-1
      type: prometheus
EOF
```

Allow the traffic from Grafana to Prometheus Server and from Prometheus Server to Dataplane metrics and for other Prometheus components:
```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  name: metrics-permissions
spec:
  sources:
    - match:
       kuma.io/service: prometheus-server_kuma-metrics_svc_80
  destinations:
    - match:
       kuma.io/service: dataplane-metrics
    - match:
       kuma.io/service: "prometheus-alertmanager_kuma-metrics_svc_80"
    - match:
       kuma.io/service: "prometheus-kube-state-metrics_kuma-metrics_svc_80"
    - match:
       kuma.io/service: "prometheus-kube-state-metrics_kuma-metrics_svc_81"
    - match:
       kuma.io/service: "prometheus-pushgateway_kuma-metrics_svc_9091"
---
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  name: grafana-to-prometheus
spec:
   sources:
   - match:
      kuma.io/service: "grafana_kuma-metrics_svc_80"
   destinations:
   - match:
      kuma.io/service: "prometheus-server_kuma-metrics_svc_80"
EOF
```

Afterwards, port-forward the Grafana server pod on the `kuma-metrics` namespace to acess the GUI:

```bash
$ kubectl port-forward grafana-7b7b687898-qgztc -n kuma-metrics 3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```

Visit the [Grafana dashboard](http://localhost:3000/) to query the metrics that Prometheus is scraping from Kuma mesh. If you are prompted to login, just use `admin:admin` as the username and password.

![grafana-dashboard](https://github.com/kumahq/kuma-website/blob/master/docs/.vuepress/public/images/demo/mesh-grafana-dashboard.png?raw=true)

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

## Policies

### mTLS

This policy enables automatic encrypted mTLS traffic for all the services in a mesh. Kuma ships with a builtin CA (Certificate Authority) which is initialized with an auto-generated root certificate. The root certificate is unique for every mesh and it used to sign identity certificates for every data-plane. Kuma also supports third-party CA.

By default, mTLS is not enabled. You can enable Mutual TLS by updating the mesh policy with the mtls setting.

#### Check for mTLS

Using [`kumactl`](#kumactl) that you configured earlier, you can check the Mesh object and see that mTLS is turned off. You can also visualize these resource by inspecting them in the [GUI](#gui).

```bash
$ ./kumactl get meshes
NAME      mTLS   METRICS                   LOGGING   TRACING   LOCALITY   AGE
default   off    prometheus/prometheus-1   off       off       off        30m
```

#### Adding mTLS Policy

Use `kubectl apply [..]` to enable mTLS on our mesh.

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    enabledBackend: ca-1
    backends:
    - name: ca-1
      type: builtin
  metrics:
    enabledBackend: prometheus-1
    backends:
    - name: prometheus-1
      type: prometheus
EOF
```

Once you have updated the Mesh object with mTLS enabled, check it was configured properly:

```
$ ./kumactl get meshes
NAME      mTLS           METRICS                   LOGGING   TRACING   LOCALITY   AGE
default   builtin/ca-1   prometheus/prometheus-1   off       off       off        31m
```

If you try to access the marketplace via the [`$PROXY_IP`](#configuration), it will still work because there is a default traffic permission. All traffic going through data plane proxies are now encrypted via mTLS.

To fine-tune traffic once mTLS has been enabled, please utilize [traffic permission policies](#traffic-permissions).

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Traffic Permissions

Traffic Permissions allow you to determine how services communicate. It is a very useful policy to increase security in the mesh and compliance in the organization. You can determine what source services are allowed to consume specific destination services. The service field is mandatory in both sources and destinations. 

Kuma ships with a default traffic permission called `allow-all-default`. 

#### Adding Granular Traffic Permissions 

Imagine if someone was spamming fake reviews to compromise the integrity of our marketplace. We can easily take down our Redis service by using more granular traffic-permissions.

First, we have to delete the default `allow-all-default` permission that allows traffic between all services:
```bash
$ kubectl delete trafficpermission -n kuma-demo --all
```

Next, apply the three policies below. In the first one, we allow the Kong service to communicate to the frontend. In the second one, we allow the frontend to communicate with the backend. And in the last one, we allow the backend to communicate with PostgreSQL. By not providing any permissions to Redis, traffic won't be allowed to that service.

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
      kuma.io/service: kong-validation-webhook_kuma-demo_svc_443
  destinations:
  - match:
      kuma.io/service: frontend_kuma-demo_svc_8080
---
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  namespace: kuma-demo
  name: frontend-to-backend
spec:
  sources:
  - match:
      kuma.io/service: frontend_kuma-demo_svc_8080
  destinations:
  - match:
      kuma.io/service: backend_kuma-demo_svc_3001
---
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  namespace: kuma-demo
  name: backend-to-postgres
spec:
  sources:
  - match:
      kuma.io/service: backend_kuma-demo_svc_3001
  destinations:
  - match:
      kuma.io/service: postgres_kuma-demo_svc_5432
EOF
```

After we apply those three policies, use `kumactl` to check that the policies are in place:
```bash
$ ./kumactl get traffic-permissions
MESH      NAME                            AGE
default   backend-to-postgres.kuma-demo   9s
default   frontend-to-backend.kuma-demo   9s
default   kong-to-frontend.kuma-demo      9s
```

And now if we go back to the marketplace, everything will work except the reviews. If we wanted to enable the Redis service again in the future, just add an additional traffic-permission back like this:
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
      kuma.io/service: backend_kuma-demo_svc_3001
  destinations:
  - match:
      kuma.io/service: redis_kuma-demo_svc_6379
EOF
```

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Traffic Routing

Traffic Routing policy enable you to configure routing rules for L4 traffic, i.e. blue/green deployments and canary releases. To route traffic, Kuma matches via tags that we can designate to Dataplane resources.

When we deployed the application earlier, the manifest deployed three versions of the backend application: `backend`, `backend-v1`, and `backend-v2`. The original `backend` service is a normal marketplace you've been browsing. The `backend-v1` is a marketplace with 1 sale on the front page, and `backend-v1` is a marketplace with 2 sales. In the diagram below, you can see the two destination services have been assigned the version tag to help with canary deployment.

```           
                        ----> backend-v0  :  service=backend, version=v0, env=prod
                      /
(browser) -> frontend   ----> backend-v1  :  service=backend, version=v1, env=intg
                      \
                        ----> backend-v2  :  service=backend, version=v2, env=dev
``` 

#### Scale Replicas

`backend-v1` and `backend-v2` were deployed with 0 replicas so let's scale them up to one replica to see how traffic routing works:

```bash
$ kubectl scale deployment kuma-demo-backend-v1 -n kuma-demo --replicas=1
```

and 

```bash
$ kubectl scale deployment kuma-demo-backend-v2 -n kuma-demo --replicas=1
```

Check all the pods are running like this:
```bash
$ kubectl get pods -n kuma-demo
NAME                                    READY   STATUS    RESTARTS   AGE
ingress-kong-5965cbfc79-2lwpq           3/3     Running   0          38m
kuma-demo-app-69c9fd4bd-lkhqm           2/2     Running   0          41m
kuma-demo-backend-v0-d7cb6b576-cp4fm    2/2     Running   0          41m
kuma-demo-backend-v1-648cbd6458-6drh5   2/2     Running   0          52s
kuma-demo-backend-v2-79969f7676-dt7hr   2/2     Running   0          47s
postgres-master-65df766577-9767x        2/2     Running   0          41m
redis-master-78ff699f7-wdc5p            2/2     Running   0          41m
```

#### Adding Routing Policy

To avoid going broke, let's limit the amount of special offers that appear on our marketplace. To do so, apply this TrafficRoute policy to routes majority of our traffic to the v0 version:

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
      kuma.io/service: frontend_kuma-demo_svc_8080
  destinations:
  - match:
      kuma.io/service: backend_kuma-demo_svc_3001
  conf:
    split:
    - weight: 80
      destination:
        kuma.io/service: backend_kuma-demo_svc_3001
        version: v0
    - weight: 20
      destination:
        kuma.io/service: backend_kuma-demo_svc_3001
        version: v1
    - weight: 0
      destination:
        kuma.io/service: backend_kuma-demo_svc_3001
        version: v2
EOF
```

And now if we go back to our marketplace, roughly 20% of the requests will land you on the `backend-v1` service and place the first item on sale. And you will never see two sales occur at the same time because we placed a weight of 0 on the `backend-v2` service. 

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Health Check

The goal of Health Checks is to minimize the number of failed requests due to temporary unavailability of a target endpoint. By applying a Health Check policy you effectively instruct a data plane proxy to keep track of health statuses for target endpoints. Dataplane will never send a request to an endpoint that is considered "unhealthy".

#### Adding Health Check Policy

To apply a health check policy to backend service, run the following:
```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: kuma.io/v1alpha1
kind: HealthCheck
metadata:
  name: frontend-to-backend
  namespace: kuma-demo
mesh: default
spec:
  sources:
  - match:
      kuma.io/service: frontend_kuma-demo_svc_8080
  destinations:
  - match:
      kuma.io/service: backend_kuma-demo_svc_3001
  conf:
    interval: 10s
    timeout: 2s
    unhealthyThreshold: 3
    healthyThreshold: 1
EOF
```

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Traffic Metrics

Kuma facilitates consistent traffic metrics across all data plane proxies in your mesh.

A user can enable traffic metrics by editing a Mesh object and providing the desired mesh-wide configuration. If necessary, metrics configuration can be customized for each Dataplane individually, e.g. to override the default metrics port that might be already in use on that particular machine. 

#### Adding Traffic Metric Policy

Let's enable traffic metrics by editing our Mesh object like so:

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    enabledBackend: ca-1
    backends:
    - name: ca-1
      type: builtin
  metrics:
    enabledBackend: prometheus-1
    backends:
    - name: prometheus-1
      type: prometheus
EOF
```

You can check that Prometheus metrics is enabled by checking the mesh with `kumactl get [..]`:
```bash
$ ./kumactl get meshes
NAME      mTLS           METRICS                   LOGGING   TRACING   AGE
default   builtin/ca-1   prometheus/prometheus-1   off       off       31m
```

Allow the traffic from Grafana to Prometheus Server and from Prometheus Server to Dataplane metrics and for other Prometheus components:
```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  name: metrics-permissions
spec:
  sources:
    - match:
       kuma.io/service: prometheus-server_kuma-metrics_svc_80
  destinations:
    - match:
       kuma.io/service: dataplane-metrics
    - match:
       kuma.io/service: "prometheus-alertmanager_kuma-metrics_svc_80"
    - match:
       kuma.io/service: "prometheus-kube-state-metrics_kuma-metrics_svc_80"
    - match:
       kuma.io/service: "prometheus-kube-state-metrics_kuma-metrics_svc_81"
    - match:
       kuma.io/service: "prometheus-pushgateway_kuma-metrics_svc_9091"
---
apiVersion: kuma.io/v1alpha1
kind: TrafficPermission
mesh: default
metadata:
  name: grafana-to-prometheus
spec:
   sources:
   - match:
      kuma.io/service: "grafana_kuma-metrics_svc_80"
   destinations:
   - match:
      kuma.io/service: "prometheus-server_kuma-metrics_svc_80"
EOF
```

#### Query Metrics

You can visit the [Prometheus/Grafana section](#prometheus-and-grafana) to learn how to visualize your metrics. You can also visit the the official documentation found [here](https://kuma.io/docs/latest/policies/#traffic-metrics).

![grafana-dashboard](https://raw.githubusercontent.com/Kong/kuma-website/master/docs/.vuepress/public/images/demo/mesh-grafana-dashboard.png)

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Traffic Log

With TrafficLog policy you can easily set up access logs on every data-plane in a Mesh. The logs can be then forwarded to a collector that can further transmit them into systems like Splunk, ELK and Datadog.

#### Setup

First, you need to configure logging backends that will be available for use in a given Mesh. A logging backend is essentially a sink for access logs. In the current release of Kuma, a logging backend can be either a file or a TCP log collector, such as Logstash.

Run the following command to deploy a sample logtash service via [`bit.ly/demokumalog`](https://bit.ly/demokumalog), which points to the [kuma-demo-log YAML file](/kubernetes/kuma-demo-log.yaml) provided in this directory:
```bash
$ kubectl apply -f https://bit.ly/demokumalog
namespace/logging created
service/logstash created
configmap/logstash-config created
deployment.apps/logstash created
```

This logstash service is configured to send logs to our [Loggly](https://www.loggly.com/) instance at https://kumademo.loggly.com/. To use it yourself, you will need to create a free Loggly account and update the API key listed in the [kuma-demo-log YAML file](/kubernetes/kuma-demo-log.yaml#33).

#### Adding Logging Policy

After that service is up and running, we need to first configure Mesh object to include what we want logged: 

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    enabledBackend: ca-1
    backends:
    - name: ca-1
      type: builtin
  metrics:
    enabledBackend: prometheus-1
    backends:
    - name: prometheus-1
      type: prometheus
  logging:
    defaultBackend: logstash
    backends:
    - name: logstash
      format: '{"start_time": "%START_TIME%", "source": "%KUMA_SOURCE_SERVICE%", "destination": "%KUMA_DESTINATION_SERVICE%", "source_address": "%KUMA_SOURCE_ADDRESS_WITHOUT_PORT%", "destination_address": "%UPSTREAM_HOST%", "duration_millis": "%DURATION%", "bytes_received": "%BYTES_RECEIVED%", "bytes_sent": "%BYTES_SENT%"}'
      type: tcp
      conf:
        address: logstash.logging:5000
EOF
```
     
Next, create a TrafficLog policy to select a subset of traffic and forward its access logs into one of the logging backends configured for that Mesh:

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: TrafficLog
mesh: default
metadata:
  namespace: kuma-demo
  name: everything
spec:
  sources:
  - match:
      kuma.io/service: '*'
  destinations:
  - match:
      kuma.io/service: '*'
  conf:
    backend: logstash
EOF
```

If you visit your personal Loggly instance, you will see the logs appear there.

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Traffic Trace

With the TrafficTrace policy you can configure tracing on every Kuma DP that belongs to the Mesh. Note that tracing operates on L7 HTTP traffic, so make sure that selected data plane proxies are configured with HTTP Protocol.

#### Jaeger Installation

We will be using [Jaeger](https://www.jaegertracing.io/), which is an open-source tracing tool. You can use popular alternatives like Zipkin alongside Kuma.

In Kubernetes mode, we can use `kumactl install [..]` again to install the pre-configured Jaeger components onto the Kubernetes cluster we have deployed:

```bash
$ kumactl install tracing | kubectl apply -f -
``` 

#### Adding Traffic Tracing Policy

Let's enable traffic tracing by replacing the logging spec with a new tracing spec within our Mesh object:

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: Mesh
metadata:
  name: default
spec:
  mtls:
    enabledBackend: ca-1
    backends:
    - name: ca-1
      type: builtin
  metrics:
    enabledBackend: prometheus-1
    backends:
    - name: prometheus-1
      type: prometheus
  tracing:
    defaultBackend: jaeger-collector
    backends:
    - name: jaeger-collector
      type: zipkin
      sampling: 100.0
      conf:
        url: http://jaeger-collector.kuma-tracing:9411/api/v2/spans
EOF
```

Once you have tracing enabled on the mesh, add a tracing policy on the services you want to trace. We will be tracing all services with the policy below:

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: TrafficTrace
mesh: default
metadata:
  namespace: kuma-demo
  name: trace-all-traffic
spec:
  selectors:
  - match:
      kuma.io/service: '*'
  conf:
    backend: jaeger-collector
EOF
```

#### Visualizing Traces

After generating some traffic in the mesh, you can access the Jaeger dashboard using the following command to visualize the traces:

```bash
$ minikube service jaeger-query --url -p kuma-demo -n kuma-tracing
http://192.168.64.62:30911
```


<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Fault Injection

`FaultInjection` policy helps you to test your microservices against resiliency. Kuma provides 3 different types of failures that could be imitated in your environment: delays, aborts, and response bandwidth limits. 

#### Adding Fault Injection Policy

In the following demo, we will be adding one policy that encompasses all three types of failures. However, you may break this policy apart as you see fit and only use the ones that are necessary for testing your microservices. Run the following command:

```bash
$ cat <<EOF | kubectl apply -f - 
apiVersion: kuma.io/v1alpha1
kind: FaultInjection
mesh: default
metadata:
  namespace: default
  name: everything
spec:
    sources:
        - match:
            kuma.io/service: frontend_kuma-demo_svc_8080
            kuma.io/protocol: http
    destinations:
        - match:
            kuma.io/service: backend_kuma-demo_svc_3001
            kuma.io/protocol: http
    conf:        
        abort:
            httpStatus: 500
            percentage: 50
        delay:
            percentage: 50.5
            value: 5s
        responseBandwidth:
            limit: 50 mbps
            percentage: 50 
EOF
```

One thing to note about this policy is that three source and destination services must have an additional [`protocol: http` tag](https://kuma.io/docs/latest/policies/http-support-in-kuma/). Now if you return to the application, roughly half the requests will return a HTTP status code 500 thanks to the abort configuration we set above. In addition, there should be a significant delay in the response because we set a 5 second delay on 99% of the requests.


<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>
