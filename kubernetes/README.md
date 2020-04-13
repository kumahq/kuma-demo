# Kubernetes Deployment Guide

## Introductions

In this directory, you will find the necessary files and instructions to get Kuma up and running in Kubernetes mode via Minikube. 

When running on Kubernetes, Kuma will store all of its state and configuration on the underlying Kubernetes API Server, therefore requiring no dependency to store the data.

## Table of Contents
- [Kubernetes Deployment Guide](#kubernetes-deployment-guide)
  - [Introductions](#introductions)
  - [Table of Contents](#table-of-contents)
  - [Setup Environment](#setup-environment)
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
      - [Adding Traffic Permission Policy](#adding-traffic-permission-policy)
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

### Minikube

We'll be using Minikube to deploy our application and Kuma to illustrate the mesh's capabilities in Kubernetes mode. Please follow Minikube's [installation guide](https://kubernetes.io/docs/tasks/tools/install-minikube/) to have it set up correctly before proceeding.

Once you have Minikube installed, we will need to start a Kubernetes cluster on it with at least 4GB of memory to run the full demo smoothly. You can allocate less memory if you plan on leaving out the [Kong Ingress Gateway](#kong-gateway) and some of the [observability steps](#prometheus-and-grafana). Another thing to note is that Kuma is tested on Kubernetes version v1.13.0 - v1.16.x, so use anything older or newer with caution. 

Run the following command to start up a cluster:
```bash
$ minikube start --cpus 2 --memory 4096 --kubernetes-version v1.16.8 -p kuma-demo
😄  [kuma-demo] minikube v1.8.2 kuon Darwin 10.15.3
✨  Automatically selected the hyperkit driver. Other choices: virtualbox, docker
🔥  Creating hyperkit VM (CPUs=2, Memory=6144MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.16.8 on Docker 19.03.6 ...
🚀  Launching Kubernetes ...
🌟  Enabling addons: default-storageclass, storage-provisioner
⌛  Waiting for cluster to come online ...
🏄  Done! kubectl is now configured to use "kuma-demo"
```

### Marketplace application

Run the following command to deploy the marketplace application via [`bit.ly/demokuma`](https://www.bit.ly/demokuma), which points to the [all-in-one YAML file](/kubernetes/kuma-demo-aio.yaml) provided in this directory:
```bash
$ kubectl apply -f https://bit.ly/demokuma
namespace/kuma-demo created
serviceaccount/postgres created
service/postgres created
replicationcontroller/es created
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
NAME                                    READY   STATUS    RESTARTS   AGE
es-mc78v                               1/1     Running   0          63s
kuma-demo-app-656c95dcb5-6pshm         1/1     Running   0          63s
kuma-demo-backend-v0-99c9878b6-wbffb   1/1     Running   0          63s
redis-master-657c58c859-9w98d          1/1     Running   0          63s
```

The [all-in-one YAML file](/kubernetes/kuma-demo-aio.yaml) deploys our application across four pods:
1. The first pod is an PostgreSQL service that stores all the items in our marketplace.
2. The second pod is the frontend application that will give you a GUI to query the items/reviews.
   * Throughout this guide, we will be port-forwarding this `kuma-demo-app-656c95dcb5-6pshm` pod to access the marketplace's frontend GUI. Please replace any reference of this pod with your pod's name.
3. The third pod is a Node application that represents a backend.
   * We have three deployments for `kuma-demo-backend-v*` in the [all-in-one YAML file](/kubernetes/kuma-demo-aio.yaml). The v1 and v2 deployments currently have 0 replicas, but will be scaled up later when we cover Kuma's Traffic Routing policy.  
4. The fourth pod is a Redis service that stores reviews for each item.

![diagram](https://github.com/Kong/kuma-website/blob/master/docs/.vuepress/public/images/diagrams/diagram-kuma-demo-basic.jpg?raw=true)

To access the front-end UI on [http://localhost:8080](http://localhost:8080), port-forward your `kuma-demo-app` like so:
```bash
$ kubectl port-forward kuma-demo-app-656c95dcb5-6pshm -n kuma-demo 8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

![frontend-gui](https://raw.githubusercontent.com/Kong/kuma-website/master/docs/.vuepress/public/images/demo/kuma-demo-app-gui.png)

This marketplace application is currently running **WITHOUT** Kuma. So all traffic is going directly between the services, and not routed through any dataplanes. In the next step, we will download Kuma and quickly deploy the mesh alongside an existing application. 

### Kuma

Kuma is an open-source control plane for modern connectivity, delivering high performance and reliability with Envoy. We will have to download it first and then install it onto the Kubernetes cluster.

#### Download

To find the correct version for your operating system, please check out [Kuma's official installation page](https://kuma.io/install). The following command will download the Mac compatible version of Kuma.

```bash
$ wget https://kong.bintray.com/kuma/kuma-0.4.0-darwin-amd64.tar.gz
--2020-03-21 18:12:13--  https://kong.bintray.com/kuma/kuma-0.4.0-darwin-amd64.tar.gz
Resolving kong.bintray.com (kong.bintray.com)... 54.191.3.105, 52.41.180.114
Connecting to kong.bintray.com (kong.bintray.com)|54.191.3.105|:443... connected.
HTTP request sent, awaiting response... 302
Location: https://akamai.bintray.com/a6/a6166a446a6e108c05f730b715883f763c639407f68c0aeab047fb483aa0d37b?__gda__=exp=1584840253~hmac=842a00e945ead8ad5ff82ef7ce815af25e05127f0441afc9651a227c2a4c0186&response-content-disposition=attachment%3Bfilename%3D%22kuma-0.4.0-darwin-amd64.tar.gz%22&response-content-type=application%2Fgzip&requestInfo=U2FsdGVkX18YHMvH_plPDrWpJf4WJqUcn8K5tThs-p1VfcOHb-Qba5Clp3NImVt39IMdcZt94rOxGdic3jtQsJTr9ixBwyNHEFF1EiIsZpKvYWg6n0dRqXZUOkxyM7Rx&response-X-Checksum-Sha1=e6eeff0b9b90c95fc9924bd0b67f5a2c2d62b79c&response-X-Checksum-Sha2=a6166a446a6e108c05f730b715883f763c639407f68c0aeab047fb483aa0d37b [following]
--2020-03-21 18:12:13--  https://akamai.bintray.com/a6/a6166a446a6e108c05f730b715883f763c639407f68c0aeab047fb483aa0d37b?__gda__=exp=1584840253~hmac=842a00e945ead8ad5ff82ef7ce815af25e05127f0441afc9651a227c2a4c0186&response-content-disposition=attachment%3Bfilename%3D%22kuma-0.4.0-darwin-amd64.tar.gz%22&response-content-type=application%2Fgzip&requestInfo=U2FsdGVkX18YHMvH_plPDrWpJf4WJqUcn8K5tThs-p1VfcOHb-Qba5Clp3NImVt39IMdcZt94rOxGdic3jtQsJTr9ixBwyNHEFF1EiIsZpKvYWg6n0dRqXZUOkxyM7Rx&response-X-Checksum-Sha1=e6eeff0b9b90c95fc9924bd0b67f5a2c2d62b79c&response-X-Checksum-Sha2=a6166a446a6e108c05f730b715883f763c639407f68c0aeab047fb483aa0d37b
Resolving akamai.bintray.com (akamai.bintray.com)... 104.123.73.154
Connecting to akamai.bintray.com (akamai.bintray.com)|104.123.73.154|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 48840921 (47M) [application/gzip]
Saving to: ‘kuma-0.4.0-darwin-amd64.tar.gz’

kuma-0.4.0-darwin-amd64.tar.gz           100%[===============================================================================>]  46.58M  40.8MB/s    in 1.1s

2020-03-21 18:12:14 (40.8 MB/s) - ‘kuma-0.4.0-darwin-amd64.tar.gz’ saved [48840921/48840921]
```

Next, unbundle the files to get the following components:

```bash
$ tar xvzf kuma-0.4.0-darwin-amd64.tar.gz
x ./
x ./bin/
x ./bin/kumactl
x ./bin/kuma-cp
x ./bin/envoy
x ./bin/kuma-prometheus-sd
x ./bin/kuma-tcp-echo
x ./bin/kuma-dp
x ./NOTICE
x ./NOTICE-kuma-init
x ./LICENSE
x ./conf/
x ./conf/kuma-cp.conf
x ./README
```

Lastly, navigate into the ./bin directory where the kuma components will be:

```bash
$ cd bin && ls
envoy		kuma-cp		kuma-dp		kuma-prometheus-sd		kuma-tcp-echo		kumactl
```
On Kubernetes, of all the Kuma binaries in the bin folder, we only need kumactl. The kumactl executable is a very important component in your journey with Kuma. It allows to retrieve the state of Kuma and the configured policies in every environment. On Kubernetes it is read-only, because you are supposed to change the state of Kuma by leveraging Kuma's CRDs. But it does provides helpers to install Kuma on Kubernetes via `kumactl install [..]` command. 

#### Installation

Using `kumactl install [..]`, install the control-plane onto the Kubernetes cluster we have deployed:

```bash
$ ./kumactl install control-plane | kubectl apply -f -
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
```

And then check the pods are up and running by getting all pods in the `kuma-system` namespace

```bash
$ kubectl get pods -n kuma-system
NAME                                 READY   STATUS    RESTARTS   AGE
kuma-control-plane-965bf6fd4-v47qh   1/1     Running   0          63s
kuma-injector-696484d998-nz7z8       1/1     Running   0          63s
```

The installation commands will deploy these two pods:
1. The first pod is Kuma control-plane. Kuma (kuma-cp) is one single executable written in GoLang that can be installed anywhere, hence why it's both universal and simple to deploy. When running on Kubernetes, no external dependencies required, since it leverages the underlying K8s API server to store its configuration. Throughout this guide, we will be port-forwarding this `kuma-control-plane-965bf6fd4-v47qh` pod to access the Kuma GUI. Please replace any reference of this pod with your pod's name.
2. The second pod is the kuma-injector service will also start in order to automatically inject sidecar dataplane proxies without human intervention. For this service to work, you need to label the namespaces with `kuma.io/sidecar-injection: enabled`. The [all-in-one YAML file](/kubernetes/kuma-demo-aio.yaml) that deployed the marketplace application already has the label so you do not need to edit it.

Now that we have the control-plane and injector in our cluster, we need to delete the existing pods (or perform a rolling update) so the injector can do its job.

```bash
$ kubectl delete pods --all -n kuma-demo
pod "es-mc78v" deleted
pod "kuma-demo-app-656c95dcb5-6pshm" deleted
pod "kuma-demo-backend-v0-99c9878b6-wbffb" deleted
pod "redis-master-657c58c859-9w98d" deleted
```
And then check the pods are up and running by getting all pods in the `kuma-demo` namespace:

```bash
$ kubectl get pods -n kuma-demo -w
NAME                                   READY   STATUS    RESTARTS   AGE
es-s86kd                               2/2     Running   0          55s
kuma-demo-app-656c95dcb5-twdl2         2/2     Running   0          55s
kuma-demo-backend-v0-99c9878b6-vfsdc   2/2     Running   0          55s
redis-master-657c58c859-prldh          2/2     Running   0          55s
```
It looks near identical **except** each pod now has an additional container. The additional container is the Envoy sidecar proxy that kuma-injector is automatically adding to each pod. 

To access the front-end UI on [http://localhost:8080](http://localhost:8080), port-forward your `kuma-demo-app` again:
```bash
$ kubectl port-forward kuma-demo-app-656c95dcb5-twdl2 -n kuma-demo 8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

The marketplace application is now running with Kuma, but will be identical to the version with Kuma. The underlying difference is that all the services are now sending traffic to the Envoy dataplane within the same pod, and the Envoy proxies will communicate to each other. But the user will not see any visual change!

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

First, get the pod name from the `kuma-system` namespace:

```bash
$ kubectl get pods -n kuma-system
NAME                                 READY   STATUS    RESTARTS   AGE
kuma-control-plane-965bf6fd4-v47qh   1/1     Running   0          63s
kuma-injector-696484d998-nz7z8       1/1     Running   0          63s
```

Then port-forward the pod on port 5681 and 5683 like so:

```bash
$ kubectl port-forward kuma-control-plane-965bf6fd4-v47qh -n kuma-system 5681 5683
Forwarding from 127.0.0.1:5681 -> 5681
Forwarding from [::1]:5681 -> 5681
Forwarding from 127.0.0.1:5683 -> 5683
Forwarding from [::1]:5683 -> 5683
```

The two ports we port-forwarded are for:
- 5681: the HTTP API server that is being used by kumactl to retrieve the state of your configuration and policies on every environment
- 5683: the HTTP server that exposes [Kuma UI](#gui)

Next, configure kumactl to point to the address where the HTTP API server sits:
```bash
$ ./kumactl config control-planes add --name=minikube --address=http://localhost:5681
added Control Plane "minikube"
switched active Control Plane to "minikube"
```

#### Inspect

Once kumactl is pointing to the correct control-plane, you can use it to inspect the dataplanes in the mesh.

```
$ ./kumactl inspect dataplanes
MESH      NAME                                             TAGS                                                                                                                      STATUS   LAST CONNECTED AGO   LAST UPDATED AGO   TOTAL UPDATES   TOTAL ERRORS
default   es-s86kd.kuma-demo                               component=postgres protocol=http service=postgres.kuma-demo.svc:5432                                              Online   2h2m44s              2h2m43s            4               0
default   kuma-demo-backend-v0-99c9878b6-vfsdc.kuma-demo   app=kuma-demo-backend env=prod pod-template-hash=99c9878b6 protocol=http service=backend.kuma-demo.svc:3001 version=v0    Online   2h2m48s              2h2m46s            4               0
default   redis-master-657c58c859-prldh.kuma-demo          app=redis pod-template-hash=657c58c859 protocol=tcp role=master service=redis.kuma-demo.svc:6379 tier=backend             Online   2h2m47s              2h2m46s            4               0
default   kuma-demo-app-656c95dcb5-twdl2.kuma-demo         app=kuma-demo-frontend env=prod pod-template-hash=656c95dcb5 protocol=http service=frontend.kuma-demo.svc:8080 version=v8   Online   2h2m46s              2h2m45s            4               0

```

There are 4 dataplanes which correlates with each component of our application

### GUI

Kuma ships with an internal GUI that will help you visualize the mesh and its policies in an intuitive format. The GUI is also open-source so you can find the source code in the [kuma-gui repository](https://github.com/Kong/kuma-gui). It can be found on port :5683 on the control-plane machine, which we just port-forwarded above. Navigate to [http://localhost:5683/](http://localhost:5683/) to use Kuma's GUI.

![kuma-gui](https://raw.githubusercontent.com/Kong/kuma-website/master/docs/.vuepress/public/images/demo/kuma-gui-welcome-0.4.0.png)

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

The dataplane can now operate in [Gateway mode](https://kuma.io/docs/latest/documentation/dps-and-data-model/#gateway). This way you can integrate Kuma with existing API Gateways like [Kong](https://github.com/Kong/kong). Run the following command to deploy [Kong for Kubernetes](https://github.com/Kong/kubernetes-ingress-controller) via [`bit.ly/demokumakong`](https://www.bit.ly/demokumakong), which points to the [kuma-demo-kong YAML file](/kubernetes/kuma-demo-kong.yaml) provided in this directory:

```bash
$ kubectl apply -f https://bit.ly/demokumakong
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

This deployment is slightly modified from the [original one](https://github.com/Kong/kubernetes-ingress-controller/blob/master/deploy/single/all-in-one-dbless.yaml) in the Kong for Kubernetes repository. We added the annotation `80.service.kuma.io/protocol: "http"` to the `kong-proxy` service and `kuma.io/gateway: enabled` annotation to the API gateway pod so the control-plane knows to inject a gateway dataplane. If you check the pods in the `kuma-demo` namespace, Kong wil be running alongside the application we deployed earlier:

```bash
$ kubectl get pods -n kuma-demo
NAME                                   READY   STATUS    RESTARTS   AGE
es-s86kd                               2/2     Running   0          11h
ingress-kong-7f4f5845b6-tpn8p          3/3     Running   0          43s
kuma-demo-app-656c95dcb5-twdl2         2/2     Running   0          11h
kuma-demo-backend-v0-99c9878b6-vfsdc   2/2     Running   0          11h
redis-master-657c58c859-prldh          2/2     Running   0          11h
```

After Kong is deployed, export the proxy IP:
```bash
$ export PROXY_IP=$(minikube service -p kuma-demo -n kuma-demo kong-proxy --url | head -1)
```

And lastly to check that the proxy IP has been exported, run:
```bash
$ echo $PROXY_IP
http://192.168.64.49:31553
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

ingress.extensions/marketplace created
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

After adding the Ingress rule, you can access the same marketplace application via the `$PROXY_IP`. You no longer have to port-forward the `kuma-demo-app` pod since all traffic into the mesh will be handled by this gateway.

### Prometheus and Grafana

Out-of-the-box, Kuma provides full integration with Prometheus and Grafana. If enabled, every dataplane will expose its metrics in Prometheus format. Furthermore, Kuma will make sure that Prometheus can automatically find every dataplane in the mesh.

#### Installation

In Kubernetes mode, we can use `kumactl install [..]` again to install the pre-configured Prometheus and Grafana components onto the Kubernetes cluster we have deployed:

```
$ kumactl install metrics | kubectl apply -f -
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

To check if everything has been deployed, check the `kuma-metrics` namespace:

```
$ kubectl get pods -n kuma-metrics
NAME                                             READY   STATUS    RESTARTS   AGE
grafana-c987548d6-5l7h7                          1/1     Running   0          2m18s
prometheus-alertmanager-655d8568-frxhc           2/2     Running   0          2m18s
prometheus-kube-state-metrics-5c45f8b9df-h9qh9   1/1     Running   0          2m18s
prometheus-node-exporter-ngqvm                   1/1     Running   0          2m18s
prometheus-pushgateway-6c894bb86f-2gflz          1/1     Running   0          2m18s
prometheus-server-65895587f-kqzrf                3/3     Running   0          2m18s
```

Once the pods are all up and running, we need to edit the Kuma Mesh object to include the `metrics: prometheus` section you see below. It is not included by default so you can edit the Mesh object using kubectl like so:

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
  metrics:
    prometheus: {}
EOF

mesh.kuma.io/default configured
```

Afterwards, port-forward the Grafana server pod on the `kuma-metrics` namespace to acess the GUI:

```bash
$ kubectl port-forward grafana-c987548d6-5l7h7 -n kuma-metrics 3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```

Visit the [Grafana dashboard](http://localhost:3000/) to query the metrics that Prometheus is scraping from Kuma mesh. If you are prompted to login, just use `admin:admin` as the username and password.

![grafana-dashboard](https://github.com/Kong/kuma-website/blob/master/docs/.vuepress/public/images/demo/mesh-grafana-dashboard.png?raw=true)

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

Using [`kumactl`](#kumactl) that you configured earlier, you can check the mesh resource and see that mTLS is turned off. You can also visualize these resource by inspecting them in the [GUI](#gui).

```bash
$ ./kumactl get meshes
NAME      mTLS   CA        METRICS
default   off    builtin   off
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
    ca:
      builtin: {}
    enabled: true
EOF
```

Once you have updated the mesh resource with mTLS enabled, check it was configured properly:

```
$ ./kumactl get meshes
NAME      mTLS   CA        METRICS
default   on     builtin   off
```

If you try to access the marketplace via the [`$PROXY_IP`](#configuration), it won't work because that traffic goes through the dataplane and is now encrypted via mTLS and the services do not have the proper permissions.

To enable traffic once mTLS has been enabled, please add [traffic permission policies](#traffic-permissions).

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Traffic Permissions

Traffic Permissions allow you to determine how services communicate. It is a very useful policy to increase security in the mesh and compliance in the organization. You can determine what source services are allowed to consume specific destination services. The service field is mandatory in both sources and destinations. 

#### Adding Traffic Permission Policy

Let's enable traffic-permission for all services so our marketplace works again:

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

And now if we go back to the marketplace, everything will work since we allow all services to send traffic to one another.

#### Adding Granular Traffic Permissions 

Imagine if someone was spamming fake reviews to compromise the integrity of our marketplace. We can easily take down our Redis service by using more granular traffic-permissions.

First, we have to delete the existing permission that allows traffic between all services:
```bash
$ kubectl delete trafficpermission -n kuma-demo --all
trafficpermission.kuma.io "everything" deleted
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
      service: kong-proxy.kuma-demo.svc:80
  destinations:
  - match:
      service: frontend.kuma-demo.svc:8080
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
      service: frontend.kuma-demo.svc:8080
  destinations:
  - match:
      service: backend.kuma-demo.svc:3001
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
      service: backend.kuma-demo.svc:3001
  destinations:
  - match:
      service: postgres.kuma-demo.svc:5432
EOF

trafficpermission.kuma.io/kong-to-frontend created
trafficpermission.kuma.io/frontend-to-backend created
trafficpermission.kuma.io/backend-to-postgres created
```

After we apply those three policies, use `kumactl` to check that the policies are in place:
```bash
$ kumactl get traffic-permissions
MESH      NAME
default   frontend-to-backend
default   backend-to-postgres
default   kong-to-frontend
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
      service: backend.kuma-demo.svc:3001
  destinations:
  - match:
      service: redis.kuma-demo.svc:6379
EOF

trafficpermission.kuma.io/backend-to-redis created
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

deployment.extensions/kuma-demo-backend-v1 scaled
```

and 

```bash
$ kubectl scale deployment kuma-demo-backend-v2 -n kuma-demo --replicas=1

deployment.extensions/kuma-demo-backend-v2 scaled
```

Check all the pods are running like this:
```bash
$ kubectl get pods -n kuma-demo
NAME                                    READY   STATUS    RESTARTS   AGE
postgres-master-0                  2/2     Running   0          35m
ingress-kong-7f4f5845b6-68c5s           3/3     Running   0          35m
kuma-demo-app-c7b9f596c-9b8sz           2/2     Running   0          35m
kuma-demo-backend-v0-7cdccd5b7c-nvcws   2/2     Running   0          35m
kuma-demo-backend-v1-568c79b548-7sd24   2/2     Running   0          57s
kuma-demo-backend-v2-b7b59d49-mrrs9     2/2     Running   0          50s
redis-master-657c58c859-b72t5           2/2     Running   0          35m
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
      service: frontend.kuma-demo.svc:8080
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

trafficroute.kuma.io/frontend-to-backend created
```

And now if we go back to our marketplace, roughly 20% of the requests will land you on the `backend-v1` service and place the first item on sale. And you will never see two sales occur at the same time because we placed a weight of 0 on the `backend-v2` service. 

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Health Check

The goal of Health Checks is to minimize the number of failed requests due to temporary unavailability of a target endpoint. By applying a Health Check policy you effectively instruct a dataplane to keep track of health statuses for target endpoints. Dataplane will never send a request to an endpoint that is considered "unhealthy".

#### Adding Health Check Policy

To apply a health check policy to backend service, run the following:
```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: kuma.io/v1alpha1
kind: TraffiHealthCheckcRoute
metadata:
  name: frontend-to-backend
  namespace: kuma-demo
mesh: default
spec:
  sources:
  - match:
      service: frontend.kuma-demo.svc:8080
  destinations:
  - match:
      service: backend.kuma-demo.svc:3001
  conf:
    activeChecks:
      interval: 10s
      timeout: 2s
      unhealthyThreshold: 3
      healthyThreshold: 1
    passiveChecks:
      unhealthyThreshold: 3
      penaltyInterval: 5s

```

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Traffic Metrics

Kuma facilitates consistent traffic metrics across all dataplanes in your mesh.

A user can enable traffic metrics by editing a mesh resource and providing the desired mesh-wide configuration. If necessary, metrics configuration can be customized for each Dataplane individually, e.g. to override the default metrics port that might be already in use on that particular machine. 

#### Adding Traffic Metric Policy

Let's enable traffic metrics by editing our mesh resource like so:

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

You can check that Prometheus metrics is enabled by checking the mesh with `kumactl get [..]`:
```bash
$ kumactl get meshes
NAME      mTLS   CA        METRICS
default   on     builtin   prometheus
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

After that service is up and running, create a TrafficLog policy to select a subset of traffic and forward its access logs into one of the logging backends configured for that Mesh:

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

If you visit your personal Loggly instance, you will see the logs appear there.

<!-- Back to top for web browser usability  -->
<br/>
<div align="right">
    <b><a href="#table-of-contents">↥ back to top</a></b>
</div>
<br/>

### Traffic Trace

With the TrafficTrace policy you can configure tracing on every Kuma DP that belongs to the Mesh. Note that tracing operates on L7 HTTP traffic, so make sure that selected dataplanes are configured with HTTP Protocol.

#### Jaeger Installation

We will be using [Jaeger](https://www.jaegertracing.io/), which is an open-source tracing tool. You can use popular alternatives like Zipkin alongside Kuma.

This Jaeger template uses an in-memory storage with a limited functionality for local testing and development. The image used defaults to the latest version released. Do not use this template in production environments. Note that functionality may differ from the pinned docker versions for production. Install everything in the current namespace:

```bash
$ kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-kubernetes/master/all-in-one/jaeger-all-in-one-template.yml

deployment.extensions/jaeger created
service/jaeger-query created
service/jaeger-collector created
service/jaeger-agent created
service/zipkin created
```

#### Adding Traffic Tracing Policy

Let's enable traffic metrics by editing our mesh resource like so:

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
  tracing:
    defaultBackend: jaeger
    backends:
    - name: jaeger
      sampling: 100.0 
      zipkin:
        url: http://jaeger-collector.default:9411/api/v1/spans
EOF

mesh.kuma.io/default configured
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
      service: '*'
  conf:
    backend: jaeger
EOF

traffictrace.kuma.io/trace-all-traffic created
```

You need to restart Kuma DP for tracing configuration to be applied. This limitation will be solved in the next versions of Kuma. 

```bash
$ kubectl delete pods -n kuma-demo --all
pod "es-d65zg" deleted
pod "ingress-kong-65bb78647-k88n2" deleted
pod "kuma-demo-app-869cd7cfbf-d6rm7" deleted
pod "kuma-demo-backend-v0-bbdfdd5f9-57pkx" deleted
pod "redis-master-6d4cf995c5-wrbl2" deleted
```

#### Visualizing Traces

After generating some traffic in the mesh, you can access the Jaeger dashboard using the following command to visualize the traces:

```bash
$ minikube service jaeger-query --url -p kuma-demo
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

In the following demo, we will be adding one policy that emcompasses all three types of failures. However, you may break this policy apart as you see fit and only use the ones that are necessary for testing your microservices. Run the following command:

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
            service: frontend.kuma-demo.svc:8080
            protocol: http
    destinations:
        - match:
            service: backend.kuma-demo.svc:3001
            protocol: http
    conf:        
        abort:
            httpStatus: 500
            percentage: 50
        delay:
            percentage: 99
            value: 5s
        responseBandwidth:
            limit: 50 mbps
            percentage: 50 
EOF

faultinjection.kuma.io/everything created
```

One thing to note about this policy is that thee sourth and desitnation services must have an additional `protocol: http` tag. Now if you return to the application, roughly half the requests will return a HTTP status code 500 thanks to the abort configuration we set above. In addition, there should be a siginifcant delay in the response because we set a 5 second delay on 99% of the requests.