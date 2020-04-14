#!/bin/sh

set -e

# ASCII art generated using http://patorjk.com/software/taag/ with font "Standard" and default width/height
cat << "EOF"

  ____   ___  ____ _____ ____ ____  _____ ____   ___  _     
 |  _ \ / _ \/ ___|_   _/ ___|  _ \| ____/ ___| / _ \| |    
 | |_) | | | \___ \ | || |  _| |_) |  _| \___ \| | | | |    
 |  __/| |_| |___) || || |_| |  _ <| |___ ___) | |_| | |___ 
 |_|    \___/|____/ |_| \____|_| \_\_____|____/ \__\_\_____|
                                                                                                        
EOF

# Set environment variables
export POSTGRES_USER=kumademo 
export POSTGRES_PASSWORD=kumademo 
export POSTGRES_DB=kumademo 

# Start with the import of the GPG key for PostgreSQL packages.
apt-get -y -q install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

# Install PostgreSQL on Ubuntu
apt-get -y -q update
apt-get -y -q install postgresql postgresql-contrib 