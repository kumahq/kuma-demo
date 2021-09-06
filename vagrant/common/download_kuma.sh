#!/bin/sh

set -e

if [ -z "${KUMA_HOME}" ]; then
  echo "Error: environment variable KUMA_HOME is not set"
  exit 1
fi

# Configure Kuma in all interactive bash shells if user SSH into machine
echo "
export KUMA_HOME=${KUMA_HOME}
export PATH=\$PATH:\$KUMA_HOME/bin
" > /etc/profile.d/kuma.sh

ARCHIVE_DIR=`mktemp -d`
cd "$ARCHIVE_DIR"

# Download Kuma for the detected OS, please check out https://kuma.io/install
# for more options. If $KUMA_VERSION is set, dowload that version, otherwise
# download the latest.
if [ -n "$KUMA_VERSION" -a "$KUMA_VERSION" != "latest" ]; then
    curl --silent https://kuma.io/installer.sh | VERSION="$KUMA_VERSION" sh >/dev/null 2>&1
else
    curl --silent https://kuma.io/installer.sh | sh >/dev/null 2>&1
fi

# Copy Kuma binaries from the versioned download to the VM home directory.
mkdir -p "$KUMA_HOME/bin/"
cp -r kuma-*/bin/* "$KUMA_HOME/bin/"

rm -rf kuma-*
