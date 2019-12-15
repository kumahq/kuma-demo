#!/bin/sh

set -e

# Configure `kumactl` for current user
kumactl config control-planes add --name=universal --address=http://kuma-cp:5681 --overwrite
