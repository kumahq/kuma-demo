# Universal Deployment Guide

In directory, you will find the necessary files and instruction to get Kuma up and running in universal mode via Vagrant. 

When running in Universal mode, there is two ways to store Kuma's state: in-memory or PostgreSQL. The first option stores all the state in-memory. This means that restarting Kuma will delete all the data. Only recommend when playing with Kuma locally. We will be using this option for the following demo. The second option is to utilize a PostgreSQL database to store its state. The PostgreSQL database and schema will have to be initialized accordingly to the installation instructions. 

## Summary

- [🛠 Setup Environment](#Setup-Environment)
  - [💻 Vagrant Setup](#1.-Vagrant-Setup)
  - [🐻 Kuma Setup](#2.-Kuma-Setup)
- [🚀 Launch Marketplace Application](#Launch-Marketplace-Application)


## Setup Environment

Before we deploy our sample application and improve it with Kuma, we need two dependencies on our local machine for this universal deployment guide.

### 1. Vagrant Setup

We'll be using Vagrant to deploy our application and demonstrate Kuma's capabilities in universal mode. Please follow Vagrant's [installation guide](https://www.vagrantup.com/intro/getting-started/install.html) to have it set up correctly before proceeding on this guide.

### 2. Kuma Setup

The second thing we need to setup on our local machine is Kuma's `kumactl`. The `kumactl` executable is a very important component in your journey with Kuma. It allows to:

* Retrieve the state of Kuma and the configured policies in every environment.
* On Universal environments, it allows to change the state of Kuma by applying new policies with the kumactl apply [..] command.
* On Kubernetes it is read-only, because you are supposed to change the state of Kuma by leveraging Kuma's CRDs.
* It provides helpers to install Kuma on Kubernetes, and to configure the PostgreSQL schema on Universal (kumactl install [..]).

#### 2a. Download the latest version of Kuma

The following command will download the Mac compatible version of Kuma. To find the correct version for your operating system, please check out [Kuma's official installation page](https://kuma.io/install). `kumactl` is bundled in the Kuma package. 

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

#### 2b. Unbundle the files to get the following components:

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

#### 2c. Go into the ./bin directory where the kuma components will be:

```
$ cd bin && ls
envoy   kuma-cp   kuma-dp   kuma-tcp-echo   kumactl
```

#### 2d. Setup `kumactl` to point to our control-plane machine

The `kumactl` application is a CLI client for the underlying HTTP API of Kuma. You can configure `kumactl` to point to any remote kuma-cp instance. Configure your local `kumactl` to point to our Vagrant machine by running:

```
$ ./kumactl config control-planes add --name=vagrant --address=http://192.168.33.10:5681
added Control Plane "vagrant"
switched active Control Plane to "vagrant"
```

#### 2e. [Optional] Add `kumactl` bin directory to PATH
If you want to call `kumactl` from other directories, just add this bin directory to your PATH:
```
export PATH=$PATH:$(pwd)
```

## Launch Marketplace Application

We built out a marketplace application to help illustrate how Kuma would work in a real-world example. The marketplace application has a ton of items for sale and reviews left by previous shoppers. Here is a sample diagram of how the application would work. The frontend would hit a backend API. And that backend API would query either Elasticsearch for items or Redis for reviews.

![Marketplace Application](https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/uploads/2019/11/diagram-12.jpg "Kuma Marketplace")

Since each component of the application will be in its own virtual machine, we offer a lightweight deployment that will only use the backend and Redis component of the application. This means you will ***NOT*** be able to visualize the application via the GUI and see the items for sale. If your machine has sufficient resources, we recommend sticking with the full application since it will illustrate Kuma's potential better.

### Full Application

### Lite Application