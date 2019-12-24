#!/bin/sh

set -e

cat << "EOF"
oooooooooooo ooooo              .o.        .oooooo..o ooooooooooooo ooooo   .oooooo.   
`888'     `8 `888'             .888.      d8P'    `Y8 8'   888   `8 `888'  d8P'  `Y8b  
 888          888             .8"888.     Y88bo.           888       888  888          
 888oooo8     888            .8' `888.     `"Y8888o.       888       888  888          
 888    "     888           .88ooo8888.        `"Y88b      888       888  888          
 888       o  888       o  .8'     `888.  oo     .d8P      888       888  `88b    ooo  
o888ooooood8 o888ooooood8 o88o     o8888o 8""88888P'      o888o     o888o  `Y8bood8P'  
EOF

# Get Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

#  Update your system with unsupported packages
add-apt-repository "deb https://artifacts.elastic.co/packages/6.x/apt stable main"
apt-get update

# Install package into system
apt-get install -y elasticsearch

# Enable the Elasticsearch service
systemctl enable elasticsearch.service

# Start the Elasticsearch service
systemctl start elasticsearch.service
