apt-get update
apt-get install -y apt-transport-https curl lsb-core
echo "deb https://kong.bintray.com/kong-deb `lsb_release -sc` main" | sudo tee -a /etc/apt/sources.list
curl -o bintray.key https://bintray.com/user/downloadSubjectPublicKey?username=bintray
apt-key add bintray.key
apt-get update
apt-get install -y kong
