#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

   ____ ___  _   _ _____ ____   ___  _       ____  _        _    _   _ _____ 
  / ___/ _ \| \ | |_   _|  _ \ / _ \| |     |  _ \| |      / \  | \ | | ____|
 | |  | | | |  \| | | | | |_) | | | | |     | |_) | |     / _ \ |  \| |  _|  
 | |__| |_| | |\  | | | |  _ <| |_| | |___  |  __/| |___ / ___ \| |\  | |___ 
  \____\___/|_| \_| |_| |_| \_\\___/|_____| |_|   |_____/_/   \_\_| \_|_____|
                                                                                                                                                      
EOF

cp /vagrant/control-plane/kuma/kuma-cp.service /etc/systemd/system/kuma-cp.service

# Always run the `systemctl daemon-reload` command after creating new unit files or modifying existing unit files.
# Otherwise, the `systemctl start` or `systemctl enable` commands could fail due to a mismatch between states of systemd
# and actual service unit files on disk.
systemctl daemon-reload

# Ensure the `kuma-cp` service starts whenever the system boots
systemctl enable kuma-cp

# Start the `kuma-cp` service on the local machine
systemctl start kuma-cp
