#!/bin/sh

set -e

# Upload mock data to Elasticsearch and Redis using /upload endpoint
curl -vX POST localhost:3001/upload
