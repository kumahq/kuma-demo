#!/bin/sh

set -e

cat << "EOF"
oooo    oooo ooooo     ooo ooo        ooooo       .o.                 .oooooo.   ooooooooo.   
`888   .8P'  `888'     `8' `88.       .888'      .888.               d8P'  `Y8b  `888   `Y88. 
 888  d8'     888       8   888b     d'888      .8"888.             888           888   .d88' 
 88888[       888       8   8 Y88. .P  888     .8' `888.            888           888ooo88P'  
 888`88b.     888       8   8  `888'   888    .88ooo8888.   8888888 888           888         
 888  `88b.   `88.    .8'   8    Y     888   .8'     `888.          `88b    ooo   888         
o888o  o888o    `YbodP'    o8o        o888o o88o     o8888o          `Y8bood8P'  o888o        
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
