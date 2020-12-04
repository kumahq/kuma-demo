#!/bin/sh

set -e

# Create a dataplane token for each service (each service has its own dataplane)

# Frontend
mkdir -p /vagrant/.vagrant.data/frontend/var/secrets/kuma.io/kuma-dp/
kumactl generate dataplane-token --name=frontend > /vagrant/.vagrant.data/frontend/var/secrets/kuma.io/kuma-dp/token

# Backend
mkdir -p /vagrant/.vagrant.data/backend/var/secrets/kuma.io/kuma-dp/
kumactl generate dataplane-token --name=backend > /vagrant/.vagrant.data/backend/var/secrets/kuma.io/kuma-dp/token

# Backend-v1
mkdir -p /vagrant/.vagrant.data/backend-v1/var/secrets/kuma.io/kuma-dp/
kumactl generate dataplane-token --name=backend-v1 > /vagrant/.vagrant.data/backend-v1/var/secrets/kuma.io/kuma-dp/token

# PostgreSQL
mkdir -p /vagrant/.vagrant.data/postgresql/var/secrets/kuma.io/kuma-dp/
kumactl generate dataplane-token --name=postgresql > /vagrant/.vagrant.data/postgresql/var/secrets/kuma.io/kuma-dp/token

# Redis
mkdir -p /vagrant/.vagrant.data/redis/var/secrets/kuma.io/kuma-dp/
kumactl generate dataplane-token --name=redis > /vagrant/.vagrant.data/redis/var/secrets/kuma.io/kuma-dp/token

# Kong
mkdir -p /vagrant/.vagrant.data/kong/var/secrets/kuma.io/kuma-dp/
kumactl generate dataplane-token --name=kong > /vagrant/.vagrant.data/kong/var/secrets/kuma.io/kuma-dp/token
