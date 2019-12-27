#!/bin/sh

set -e

cat << "EOF"
oooo    oooo   .oooooo.   ooooo      ooo   .oooooo.    
`888   .8P'   d8P'  `Y8b  `888b.     `8'  d8P'  `Y8b   
 888  d8'    888      888  8 `88b.    8  888           
 88888[      888      888  8   `88b.  8  888           
 888`88b.    888      888  8     `88b.8  888     ooooo 
 888  `88b.  `88b    d88'  8       `888  `88.    .88'  
o888o  o888o  `Y8bood8P'  o8o        `8   `Y8bood8P'   
EOF

apt-get update
apt-get install -y apt-transport-https curl lsb-core
echo "deb https://kong.bintray.com/kong-deb `lsb_release -sc` main" | sudo tee -a /etc/apt/sources.list
curl -o bintray.key https://bintray.com/user/downloadSubjectPublicKey?username=bintray
apt-key add bintray.key
apt-get update
apt-get install -y kong
