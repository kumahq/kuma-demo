#!/bin/sh

set -e

if [ -z "${KUMA_VERSION}" ]; then
  echo "Error: environment variable KUMA_VERSION is not set"
  exit 1
fi

if [ -z "${KUMA_HOME}" ]; then
  echo "Error: environment variable KUMA_HOME is not set"
  exit 1
fi

# Configure Kuma in all interactive bash shells
echo "
export KUMA_HOME=${KUMA_HOME}
export PATH=\$PATH:\$KUMA_HOME/bin
" > /etc/profile.d/kuma.sh

cd /tmp

# Download latest version of Kuma for Ubuntu, please check out https://kuma.io/install for more options
wget -nv https://kong.bintray.com/kuma/kuma-${KUMA_VERSION}-ubuntu-amd64.tar.gz

mkdir -p $KUMA_HOME

# Extract the Kuma archive
tar xvzf kuma-${KUMA_VERSION}-ubuntu-amd64.tar.gz -C $KUMA_HOME
