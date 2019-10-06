# Kubernetes Deployment Guide

## Setup Environment

1.

```
$ minikube start --kubernetes-version v1.15.4
😄  minikube v1.4.0 on Darwin 10.14.6
🔥  Creating virtualbox VM (CPUs=2, Memory=4096MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.15.4 on Docker 18.09.9 ...
🚜  Pulling images ...
🚀  Launching Kubernetes ...
⌛  Waiting for: apiserver proxy etcd scheduler controller dns
🏄  Done! kubectl is now configured to use "minikube"
```

2.

```
$ wget https://kong.bintray.com/kuma/kuma-0.2.1-darwin-amd64.tar.gz
--2019-10-06 16:58:34--  https://kong.bintray.com/kuma/kuma-0.2.1-darwin-amd64.tar.gz
Resolving kong.bintray.com (kong.bintray.com)... 52.35.217.225, 54.201.76.60
Connecting to kong.bintray.com (kong.bintray.com)|52.35.217.225|:443... connected.
HTTP request sent, awaiting response... 302
Location: https://akamai.bintray.com/8e/8ef951bb416ac52e3033db1b4c5ececb9c92076d5f9a2c3fc9e983a503376de7?__gda__=exp=1570353035~hmac=4c5d5f126d705a267f07d0322f93ff32bf89928f584be95072e42305b9c4bd6a&response-content-disposition=attachment%3Bfilename%3D%22kuma-0.2.1-darwin-amd64.tar.gz%22&response-content-type=application%2Fgzip&requestInfo=U2FsdGVkX1_RZbMi86-s_h7RlNn_7_VfLY-HUMhj8VvN4CPju8RvqAOYGpYg5yxiK2MOgSwmELzgHYP5Dybnqwl-UVQSnx_tgvPSFzo9fvKCdCQnYkzsiIPqLa8SVZKw&response-X-Checksum-Sha1=d1592fe993fcbf9c1c6f95cfe8b192a484d0f996&response-X-Checksum-Sha2=8ef951bb416ac52e3033db1b4c5ececb9c92076d5f9a2c3fc9e983a503376de7 [following]
--2019-10-06 16:58:35--  https://akamai.bintray.com/8e/8ef951bb416ac52e3033db1b4c5ececb9c92076d5f9a2c3fc9e983a503376de7?__gda__=exp=1570353035~hmac=4c5d5f126d705a267f07d0322f93ff32bf89928f584be95072e42305b9c4bd6a&response-content-disposition=attachment%3Bfilename%3D%22kuma-0.2.1-darwin-amd64.tar.gz%22&response-content-type=application%2Fgzip&requestInfo=U2FsdGVkX1_RZbMi86-s_h7RlNn_7_VfLY-HUMhj8VvN4CPju8RvqAOYGpYg5yxiK2MOgSwmELzgHYP5Dybnqwl-UVQSnx_tgvPSFzo9fvKCdCQnYkzsiIPqLa8SVZKw&response-X-Checksum-Sha1=d1592fe993fcbf9c1c6f95cfe8b192a484d0f996&response-X-Checksum-Sha2=8ef951bb416ac52e3033db1b4c5ececb9c92076d5f9a2c3fc9e983a503376de7
Resolving akamai.bintray.com (akamai.bintray.com)... 23.210.237.168
Connecting to akamai.bintray.com (akamai.bintray.com)|23.210.237.168|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 44296374 (42M) [application/gzip]
Saving to: ‘kuma-0.2.1-darwin-amd64.tar.gz’

kuma-0.2.1-darwin-amd 100%[=======================>]  42.24M  7.45MB/s    in 6.0s

2019-10-06 16:58:41 (7.02 MB/s) - ‘kuma-0.2.1-darwin-amd64.tar.gz’ saved [44296374/44296374]
```

3.

```
$ $ tar xvzf kuma-0.2.1-darwin-amd64.tar.gz
x ./
x ./conf/
x ./conf/kuma-cp.conf
x ./bin/
x ./bin/kuma-dp
x ./bin/envoy
x ./bin/kuma-tcp-echo
x ./bin/kumactl
x ./bin/kuma-cp
x ./README
x ./LICENSE

```

4.

```
$ cd bin && ls
envoy   kuma-cp   kuma-dp   kuma-tcp-echo kumactl
```

5.

```
$ kumactl install control-plane | kubectl apply -f -
namespace/kuma-system created
secret/kuma-injector-tls-cert created
secret/kuma-sds-tls-cert created
secret/kuma-admission-server-tls-cert created
configmap/kuma-injector-config created
serviceaccount/kuma-control-plane created
customresourcedefinition.apiextensions.k8s.io/dataplaneinsights.kuma.io created
customresourcedefinition.apiextensions.k8s.io/dataplanes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/meshes.kuma.io created
customresourcedefinition.apiextensions.k8s.io/proxytemplates.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficlogs.kuma.io created
customresourcedefinition.apiextensions.k8s.io/trafficpermissions.kuma.io created
clusterrole.rbac.authorization.k8s.io/kuma:control-plane created
clusterrolebinding.rbac.authorization.k8s.io/kuma:control-plane created
role.rbac.authorization.k8s.io/kuma:control-plane created
rolebinding.rbac.authorization.k8s.io/kuma:control-plane created
service/kuma-injector created
service/kuma-control-plane created
deployment.apps/kuma-control-plane created
deployment.apps/kuma-injector created
mutatingwebhookconfiguration.admissionregistration.k8s.io/kuma-admission-mutating-webhook-configuration created
mutatingwebhookconfiguration.admissionregistration.k8s.io/kuma-injector-webhook-configuration created
```

Check the pods are up and running by checking the `kuma-system` namespace

```
$ kubectl get pods -n kuma-system
NAME                                  READY   STATUS    RESTARTS   AGE
kuma-control-plane-7bcc56c869-lzw9t   1/1     Running   0          70s
kuma-injector-9c96cddc8-745r7         1/1     Running   0          70s
```

In the following steps, we will be using the pod name of the `kuma-control-plane-*************` pod. Please replace any `{KUMA_CP_POD_NAME}` with your pod name.

6.

```
$ kubectl apply -f kuma-demo-aio.yaml
namespace/kuma-demo created
serviceaccount/elasticsearch created
service/elasticsearch created
replicationcontroller/es created
deployment.apps/redis-master created
service/redis-master created
service/kuma-demo-api created
deployment.apps/kuma-demo-app created
```

This will deploy our demo marketplace application split across 3 pods. The first pod is an Elasticsearch service that stores all the items in our marketplace. The second pod is a Redis service that stores reviews for each item. The last pod is our Node/Vue application that allows you to visually query the Elastic and Redis endpoints.

Check the pods are up and running by checking the `kuma-demo` namespace

```
kubectl get pods -n kuma-demo
NAME                             READY   STATUS    RESTARTS   AGE
es-pkm29                         2/2     Running   0          7m23s
kuma-demo-app-5b8674794f-7r2sf   3/3     Running   0          7m23s
redis-master-6b88967745-8ct5c    2/2     Running   0          7m23s
```

In the following steps, we will be using the pod name of the `kuma-demo-app-*************` pod. Please replace any `{KUMA_DEMO_APP_POD_NAME}` with your pod name.

7.

```
$ kubectl apply -f kuma-demo-log.yaml
namespace/logging created
service/logstash created
configmap/logstash-config created
deployment.apps/logstash created
```

8. Upload some sample data into Elasticsearch and Redis

<pre><code>$ kubectl exec -ti <b>{KUMA_DEMO_APP_POD_NAME}</b> -c kuma-be -n kuma-demo -- curl -XPOST http://localhost:3001/upload
Mock data updated in Redis and ES!
</code></pre>

9.

<pre><code>$ kubectl port-forward <b>{KUMA_DEMO_APP_POD_NAME}</b> -n kuma-demo 8080 3001
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Forwarding from 127.0.0.1:3001 -> 3001
Forwarding from [::1]:3001 -> 3001
</code></pre>

Now you can access the application through your web browser at http://localhost:3001.

10.

<pre><code>$ kubectl -n kuma-system port-forward <b>{KUMA_CP_POD_NAME}</b> 5681
Forwarding from 127.0.0.1:5681 -> 5681
Forwarding from [::1]:5681 -> 5681
</code></pre>

Please refer to step 5 to copy the correct `{KUMA_CP_POD_NAME}`.

11.

```
$ kumactl config control-planes add --name=kuma-app --address=http://localhost:5681
added Control Plane "kuma-app"
switched active Control Plane to "kuma-app"
```

12.

```
$ kumactl get dataplanes
MESH      NAME                             TAGS
default   es-pkm29                         component=elasticsearch service=elasticsearch.kuma-demo.svc:80
default   kuma-demo-app-5b8674794f-7r2sf   app=kuma-demo-api pod-template-hash=5b8674794f service=kuma-demo-api.kuma-demo.svc:3001
default   redis-master-6b88967745-8ct5c    app=redis pod-template-hash=6b88967745 role=master service=redis-master.kuma-demo.svc:6379 tier=backend
```

13.

```
$ kumactl get meshes
NAME      mTLS   DP ACCESS LOGS
default   off    off
```

14.

```
$ kubectl apply -f kuma-demo-policy.yaml
Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply
mesh.kuma.io/default configured
trafficlog.kuma.io/everything created
trafficpermission.kuma.io/everyone-to-everyone created
```

15.

```
kumactl get meshes
NAME      mTLS   DP ACCESS LOGS
default   on     off
```

16.

```
$ kubectl delete pods --all -n kuma-demo
pod "es-pkm29" deleted
pod "kuma-demo-app-5b8674794f-7r2sf" deleted
pod "redis-master-6b88967745-8ct5c" deleted
```

17.

```
kubectl get pods -n kuma-demo
NAME                             READY   STATUS    RESTARTS   AGE
es-djlsb                         2/2     Running   0          57s
kuma-demo-app-5b8674794f-4qrq7   3/3     Running   0          57s
redis-master-6b88967745-z7cm5    2/2     Running   0          57s
```

18.

<pre><code>$ kubectl exec -ti <b>{KUMA_DEMO_APP_POD_NAME}</b> -c kuma-be -n kuma-demo -- curl -XPOST http://localhost:3001/upload
Mock data updated in Redis and ES!
</code></pre>

19.

<pre><code>$ kubectl port-forward <b>{KUMA_DEMO_APP_POD_NAME}</b> -n kuma-demo 8080 3001
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Forwarding from 127.0.0.1:3001 -> 3001
Forwarding from [::1]:3001 -> 3001
Handling connection for 3001
</code></pre>

Now if you try to access the reviews in the UI at http://localhost:3001, it will no longer work because of our traffic permissions applied on step 14. You can also use `kumactl` to check what we set:
```
$ kumactl get traffic-permissions -o yaml
items:
- mesh: default
  name: node-api-to-elasticsearch-only
  rules:
  - destinations:
    - match:
        service: elasticsearch.kuma-demo.svc:80
    sources:
    - match:
        service: kuma-demo-api.kuma-demo.svc:3001
  type: TrafficPermission
  ```
  