#!/bin/sh

set -e

# Create directory for TLS certificate for server
mkdir -p /vagrant/.vagrant.data/control-plane/var/secrets/kuma.io/kuma-cp/tls/

# Remove existing secrets
rm -f /vagrant/.vagrant.data/control-plane/var/secrets/kuma.io/kuma-cp/tls/*

# Use `kumactl` to generate a TLS certificate for server
kumactl generate tls-certificate \
--cert-file=/vagrant/.vagrant.data/control-plane/var/secrets/kuma.io/kuma-cp/tls/server.crt \
--key-file=/vagrant/.vagrant.data/control-plane/var/secrets/kuma.io/kuma-cp/tls/server.key \
--type=server \
--cp-hostname=kuma-cp
