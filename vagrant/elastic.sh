sudo apt-get install apt-transport-https

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo add-apt-repository "deb https://artifacts.elastic.co/packages/6.x/apt stable main"

sudo apt-get update

sudo apt-get install elasticsearch

sudo /bin/systemctl enable elasticsearch.service

sudo systemctl start elasticsearch.service

# Add to PATH
export PATH=$PATH:/home/vagrant/kuma/bin
echo "export PATH=$PATH:/home/vagrant/kuma/bin" >> /home/vagrant/.bashrc

# Adding Kuma-cp to /etc/hosts
echo "
192.168.33.10 kuma-cp
" >> /etc/hosts

# Navigate to new direcotry
cd /home/vagrant/kuma

# Download Kuma
wget -nv https://kong.bintray.com/kuma/kuma-0.3.0-ubuntu-amd64.tar.gz

# Extract the archive
tar xvzf kuma-0.3.0-ubuntu-amd64.tar.gz

kumactl config control-planes add --name=universal --address=http://kuma-cp:5681 --overwrite

# create Dataplane (update in future)
echo "
mesh: default
name: elastic
networking:
  inbound:
  - interface: 192.168.33.40:19200:9200
    tags:
      service: elastic
type: Dataplane" | /home/vagrant/kuma/bin/kumactl apply -f -

# start Dataplane
touch /etc/systemd/system/kuma-dp.service
cat > /etc/systemd/system/kuma-dp.service <<EOL
[Service]
ConditionPathExists=/home/vagrant/kuma/certs/kuma-dp/elastic/token
Environment=KUMA_DATAPLANE_MESH=default
Environment=KUMA_DATAPLANE_NAME=elastic
Environment=KUMA_CONTROL_PLANE_API_SERVER_URL=http://kuma-cp:5681
Environment=KUMA_DATAPLANE_RUNTIME_TOKEN_PATH=/home/vagrant/kuma/certs/kuma-dp/elastic/token
ExecStart=/home/vagrant/kuma/bin/kuma-dp run --admin-port=9901
EOL

systemctl start kuma-dp
systemctl status kuma-dp