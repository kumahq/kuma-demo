# Kuma Demo Application

[![][kuma-logo]][kuma-url]

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/kumahq/kuma/blob/master/LICENSE)
[![Slack](https://chat.kuma.io/badge.svg)](https://chat.kuma.io/)
[![Twitter](https://img.shields.io/twitter/follow/KumaMesh.svg?style=social&label=Follow)](https://twitter.com/intent/follow?screen_name=KumaMesh)

Kuma is a universal open source control-plane for Service Mesh and Microservices that can run and be operated natively across both Kubernetes and VM environments, in order to be easily adopted by every team in the organization.

This repository houses the demo application used to illustrate Kuma's extensive features. To find the source of Kuma, please check out Kuma's [repository](https://github.com/kumahq/kuma).

## Table of contents
- [Kuma Demo Application](#kuma-demo-application)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Deployment](#deployment)
  - [Application Components](#application-components)
    - [Frontend](#frontend)
    - [Backend](#backend)
    - [PostgreSQL](#postgresql)
    - [Redis](#redis)

## Introduction
[![][diagram]][diagram]

The Kuma Demo Application is a clothing marketplace where you can browse listed items along with the reviews left by users. It consists of four components: [Vue frontend UI](#frontend), [Node backend API](#backend), [PostgreSQL](#PostgreSQL), and [Redis](#Redis).

## Deployment

Kuma is a universal control plane that can run across both modern environments like Kubernetes and more traditional VM-based ones.

The first step is obviously to [download and install Kuma](https://kuma.io/install/) on the platform of your choice. Different distributions will present different installation instructions that follow the best practices for the platform you have selected. Regardless of what platform you decide to use, the fundamental behavior of Kuma at runtime will not change across different distributions.

To see examples of how to deploy Kuma alongside this marketplace application, please check out the following instructions:

- [Kubernetes](kubernetes/README.md)
- [Universal](vagrant/README.md) 

## Application Components

### Frontend

The frontend UI is built using [VuePress](https://vuepress.vuejs.org/) and the source code can be found in the [app directory](app/README.md). It gives the users a webpage where they can browse items and reviews. 

### Backend

The backend API is built using [Node.js](https://nodejs.org/en/) and the source code can be found in the [api directory](api/README.md). It contains endpoints that enables the user to query the PostgreSQL and Redis databases.

### PostgreSQL

The PostgreSQL database is used to store all the items. The list of items can be found in this [JSON file](api/db/items.json). Here is a sample of how each object in our list of items look:

```json
...
  {
    "index": 0,
    "price": "$354.80",
    "quantity": 3,
    "company": "Manufact",
    "size": "M",
    "categoryIndex": 7,
    "picture": "https://i.imgur.com/HJarGs0.jpg",
    "category": "Frugal Sun Dress",
    "name": "Manufact Frugal Sun Dress - Size M",
    "productDetail": "Elit dolor eu excepteur quis officia cillum cillum eiusmod nisi ex. Commodo nisi deserunt duis et ipsum non. Aute dolore proident Lorem mollit consectetur pariatur in reprehenderit.\r\n",
    "reviews": [
      {
        "id": 0,
        "name": "Trina Baldwin",
        "review": "Culpa exercitation anim do qui anim non aliquip et aute laborum tempor eiusmod et.",
        "rating": 1
      },
      {
        "id": 1,
        "name": "Erica Hickman",
        "review": "Fugiat nostrud fugiat sunt mollit cillum mollit minim ex culpa.",
        "rating": 5
      },
      {
        "id": 2,
        "name": "Williamson Justice",
        "review": "Ut incididunt adipisicing irure et aliquip deserunt in voluptate ipsum tempor duis incididunt et.",
        "rating": 2
      },
      {
        "id": 3,
        "name": "Frieda Watts",
        "review": "Commodo labore non consequat et minim irure et amet eu laborum id dolor excepteur.",
        "rating": 1
      },
      {
        "id": 4,
        "name": "Willa Rodriguez",
        "review": "Ipsum et sint excepteur aliquip ut est Lorem qui mollit.",
        "rating": 1
      }
    ]
  },
...
```

All this information will be saved in PostgreSQL **EXCEPT** the reviews. Reviews will be separated out and stored in Redis.

### Redis

The Redis database is used to store all the items' reviews. The list of reviews for each item can be found in this [JSON file](api/db/items.json). 

## License

```
Copyright 2020 the Kuma Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[kuma-url]: https://kuma.io/
[kuma-logo]: https://kuma-public-assets.s3.amazonaws.com/kuma-logo-v2.png
[diagram]: https://github.com/kumahq/kuma-website/blob/master/docs/.vuepress/public/images/diagrams/diagram-kuma-demo-basic.jpg?raw=true