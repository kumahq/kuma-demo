# Universal Deployment Guide

## Setup Environment

### 1. Vagrant Setup

We'll be using Vagrant to deploy our application and demonstrate Kuma's capabilities in universal mode. Please follow Vagrant's [installation guide](https://www.vagrantup.com/intro/getting-started/install.html) to have it set up correctly before proceeding on this guide.

### 2. Navigate into the directory where all the kuma-demo YAML files are:

```
$ cd examples/universal/kuma-demo/
```

### 3. Deploy Kuma's sample marketplace application

You can deploy the sample marketplace application via the Vagrantfile provided in this directory.

```
$ vagrant up
```

This will deploy our demo marketplace application and Kuma split across multiple machines:

1. The first machine hosts the Kuma control plane.
2. The second machine will host our frontend application that allows you to visually interact with the marketplace
3. The third machine will host our backend application that handles the logic of our application
4. The fourth machine will host the Elasticsearch service that stores all the items in our marketplace
5. The fifth machine will host Redis service that stores reviews for each item

To check if the machines are up and running after the `vagrant up` command, use `vagrant status`:

```
$ vagrant status
Current machine states:

kuma-cp                   running (virtualbox)
frontend                  running (virtualbox)
backend                   running (virtualbox)
elastic                   running (virtualbox)
redis                     running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

### 4. Download the latest version of Kuma

The following command will download the Mac compatible version of Kuma. To find the correct version for your operating system, please check out [Kuma's official installation page](https://kuma.io/install).

```
$ wget https://kong.bintray.com/kuma/kuma-0.3.1-darwin-amd64.tar.gz
--2019-12-14 02:46:22--  https://kong.bintray.com/kuma/kuma-0.3.1-darwin-amd64.tar.gz
Resolving kong.bintray.com (kong.bintray.com)... 3.124.133.231, 52.29.129.139
Connecting to kong.bintray.com (kong.bintray.com)|3.124.133.231|:443... connected.
HTTP request sent, awaiting response... 302
Location: https://akamai.bintray.com/dc/dc68a6fabafa80119b185e5cf607113777037534e2261c6d12130ce89d41f05f?__gda__=exp=1576292302~hmac=c2980feed263671a9b1df64ab971509dc7c25814b882e01c1e4ae2f6470e61b0&response-content-disposition=attachment%3Bfilename%3D%22kuma-0.3.1-darwin-amd64.tar.gz%22&response-content-type=application%2Fgzip&requestInfo=U2FsdGVkX18JO7J1vJsYfKyb7WAyEPygRS-qklLQAEPHO4ZpeosQIh3LDasvWp5jbd4lv4h_RjYbGOK3T0ktZLIvDkYncXBzUxQqAL5visXQjIg1IHfR2IBYxEFmsNNT&response-X-Checksum-Sha1=625e852b137a620980fcddb839ece0856bd06c1f&response-X-Checksum-Sha2=dc68a6fabafa80119b185e5cf607113777037534e2261c6d12130ce89d41f05f [following]
--2019-12-14 02:46:22--  https://akamai.bintray.com/dc/dc68a6fabafa80119b185e5cf607113777037534e2261c6d12130ce89d41f05f?__gda__=exp=1576292302~hmac=c2980feed263671a9b1df64ab971509dc7c25814b882e01c1e4ae2f6470e61b0&response-content-disposition=attachment%3Bfilename%3D%22kuma-0.3.1-darwin-amd64.tar.gz%22&response-content-type=application%2Fgzip&requestInfo=U2FsdGVkX18JO7J1vJsYfKyb7WAyEPygRS-qklLQAEPHO4ZpeosQIh3LDasvWp5jbd4lv4h_RjYbGOK3T0ktZLIvDkYncXBzUxQqAL5visXQjIg1IHfR2IBYxEFmsNNT&response-X-Checksum-Sha1=625e852b137a620980fcddb839ece0856bd06c1f&response-X-Checksum-Sha2=dc68a6fabafa80119b185e5cf607113777037534e2261c6d12130ce89d41f05f
Resolving akamai.bintray.com (akamai.bintray.com)... 92.122.149.209
Connecting to akamai.bintray.com (akamai.bintray.com)|92.122.149.209|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 42443207 (40M) [application/gzip]
Saving to: ‘kuma-0.3.1-darwin-amd64.tar.gz’

kuma-0.3.1-darwin-amd64.tar.gz                 100%[=================================================================================================>]  40.48M  2.75MB/s    in 19s

2019-12-14 02:46:43 (2.09 MB/s) - ‘kuma-0.3.1-darwin-amd64.tar.gz’ saved [42443207/42443207]
```

### 5. Unbundle the files to get the following components:

```
$ tar xvzf kuma-0.3.1-darwin-amd64.tar.gz
x ./
x ./LICENSE
x ./NOTICE
x ./bin/
x ./bin/kuma-tcp-echo
x ./bin/kumactl
x ./bin/kuma-dp
x ./bin/envoy
x ./bin/kuma-cp
x ./README
x ./conf/
x ./conf/kuma-cp.conf
```

### 6. Go into the ./bin directory where the kuma components will be:

```
$ cd bin && ls
envoy   kuma-cp   kuma-dp   kuma-tcp-echo   kumactl
```

### 8. Setup `kumactl` to point to our control-plane machine

The `kumactl` application is a CLI client for the underlying HTTP API of Kuma. Therefore, you can access the state of Kuma by leveraging with the API directly. On Universal you will be able to also make changes via the HTTP API, while on Kubernetes the HTTP API is read-only.

You can configure `kumactl` to point to any remote kuma-cp instance. Configure your local `kumactl` to point to our Vagrant machine by running:

```
$ ./kumactl config control-planes add --name=vagrant --address=http://192.168.33.10:5681
added Control Plane "vagrant"
switched active Control Plane to "vagrant"
```

### 9. You can use `kumactl` to look at the dataplanes in the mesh.

```
$ ./kumactl inspect dataplanes
MESH      NAME       TAGS                         STATUS   LAST CONNECTED AGO   LAST UPDATED AGO   TOTAL UPDATES   TOTAL ERRORS
default   frontend   service=frontend             Online   3m49s                2m36s              4               0
default   backend    service=backend version=v0   Online   2m36s                25s                5               0
default   elastic    service=elastic              Online   1m29s                1m28s              2               0
```

There are only 3 dataplanes. Our script automatically deploys dataplanes along the services in each machine, except for Redis. We will use Redis as a example of how to deploy the dataplane on step [#14](#14.-Dataplane-for-Redis).

### 10. You can also use `kumactl` to look at the mesh. As shown below, our default mesh does not have mTLS enabled.

```
$ ./kumactl get meshes
NAME      mTLS
default   off
```

### 11. Upload some mock data into our databases:

```bash
$ curl -X POST http://192.168.33.30:13001/upload

Mock data updated in Redis and ES!
```

### 12. Visit the application via browser:

You can now shop at Kuma's marketplace if you go to http://192.168.33.20:8080. All the traffic between the machines are routed through Kuma's dataplane. But if you click on `[Read Reviews]` for each item, it won't load because we do not have a dataplane set up for that machine.

### 13. Access Redis Machine

First, ssh into the Redis machine using the following command:

```bash
$ vagrant ssh redis
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.4.0-170-generic x86_64)
```

### 14. Dataplane for Redis

`kumactl` will be installed in this machine. So for our first step, create the dataplane resource for the control-plane to know that this dataplane will exist and where to look for it. Use `kumactl apply` as shown below:

```$ echo "mesh: default
name: redis
networking:
  inbound:
  - interface: 192.168.33.50:16379:6379
    tags:
      service: redis
type: Dataplane" | kumactl apply -f -
```

Next thing we need to do is create a service unite file so we can run `kuma-dp` with systemd:

```bash
$ sudo bash -c 'cat > /etc/systemd/system/kuma-dp.service ' << EOF
[Service]
ConditionPathExists=/home/vagrant/kuma/certs/kuma-dp/redis/token
Environment=KUMA_DATAPLANE_MESH=default
Environment=KUMA_DATAPLANE_NAME=redis
Environment=KUMA_CONTROL_PLANE_API_SERVER_URL=http://kuma-cp:5681
Environment=KUMA_DATAPLANE_RUNTIME_TOKEN_PATH=/home/vagrant/kuma/certs/kuma-dp/redis/token
ExecStart=/home/vagrant/kuma/bin/kuma-dp run --admin-port=9901
EOF
```

Once we have the service unit file created, use systemctl to start the `kuma-dp` service:

```
$ sudo systemctl start kuma-dp
```

and systemctl status command should help us verify that it is up and running correctly:

```
$ sudo systemctl status kuma-dp
● kuma-dp.service
   Loaded: loaded (/etc/systemd/system/kuma-dp.service; static; vendor preset: enabled)
   Active: active (running) since Thu 2019-12-12 11:27:09 UTC; 12s ago
 Main PID: 2625 (kuma-dp)
    Tasks: 20
   Memory: 11.8M
      CPU: 143ms
   CGroup: /system.slice/kuma-dp.service
           ├─2625 /home/vagrant/kuma/bin/kuma-dp run --admin-port=9901
           └─2636 /home/vagrant/kuma/bin/envoy -c /tmp/kuma-dp-307190745/bootstrap.yaml --drain-time-s 30 --disable-hot-restart
```

Once that is complete, you can exit out of the machine:

```
$ exit
```

### 15. Check Dataplanes

Use `kumactl` to check that the Redis dataplane is up and running in our mesh:

```
$ kumactl inspect dataplanes
MESH      NAME       TAGS                         STATUS   LAST CONNECTED AGO   LAST UPDATED AGO   TOTAL UPDATES   TOTAL ERRORS
default   frontend   service=frontend             Online   38m4s                32m7s              11              0
default   backend    service=backend version=v0   Online   36m51s               9m43s              14              0
default   elastic    service=elastic              Online   35m44s               32m8s              4               0
default   redis      service=redis                Online   1m12s                1m12s              6               0
```

Hit the upload endpoint one more time so this time Redis will be populated as well:
```bash
$ curl -X POST http://192.168.33.30:13001/upload
Mock data updated in Redis and ES!
```

You can also verify that it is working by accessing the frontend webpage at http://192.168.33.20:8080.

### 15. Let's enable mTLS using `kumactl`:

```
$ cat <<EOF | kumactl apply -f -
type: Mesh
name: default
mtls:
  enabled: true
  ca:
    builtin: {}
EOF
```

Using `kumactl`, inspect the mesh again to see if mTLS is enabled:

```
$ ./kumactl get meshes
NAME      mTLS
default   on
```

If you try to access the [marketplace](http://192.168.33.20:8080), it won't work because everything is encrypted.

### 16. Now let's enable traffic-permission for all services so our application will work like it use to:
```
$ cat <<EOF | kumactl apply -f -
type: TrafficPermission
name: permission-all
mesh: default
sources:
  - match:
      service: '*'
destinations:
  - match:
      service: '*'
EOF
```

### 17. Granular control:

Imagine if someone was spamming fake reviews to compromise the integrity of our marketplace. We can easily take down our Redis service by using more granular traffic-permissions.

First, we have to delete the existing permission that allows traffic between all services:
```
$ kumactl delete traffic-permission permission-all
deleted TrafficPermission "permission-all"
```

Next, apply the two policies below. In the first one,we allow the frontend to communicate with the backend. And in the second one, we allow the backend to communicate with Elasticsearch. By not providing any permissions to Redis, traffic won't be allowed to that service.

```
$ cat <<EOF | kumactl apply -f - 
type: TrafficPermission
name: frontend-to-backend
mesh: default
sources:
  - match:
      service: 'frontend'
destinations:
  - match:
      service: 'backend'
EOF
```
and
```
$ cat <<EOF | kumactl apply -f - 
type: TrafficPermission
name: backend-to-elasticsearch
mesh: default
sources:
  - match:
      service: 'backend'
destinations:
  - match:
      service: 'elastic'
EOF
```

Use `kumactl` to check that the policies are in place:
```
kumactl get traffic-permissions
MESH      NAME
default   frontend-to-backend
default   backend-to-elasticsearch
```

And now if we go back to our [marketplace](http://192.168.33.20:8080), everything will work except the reviews.