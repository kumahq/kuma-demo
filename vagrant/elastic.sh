sudo apt-get install apt-transport-https

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo add-apt-repository "deb https://artifacts.elastic.co/packages/6.x/apt stable main"

sudo apt-get update

sudo apt-get install elasticsearch

sudo /bin/systemctl enable elasticsearch.service

sudo systemctl start elasticsearch.service