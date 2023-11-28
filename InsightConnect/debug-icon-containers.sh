#!/bin/bash
# Tim H 2022

# Testing inside InsightConnect containers

# get command line inside a container
docker ps -a
# docker ps -a | grep dig
# use the "NAMES" column in the output from docker ps
CONTAINER_NAME="rapid7_dig_2.0.0_action"
# it must be the "sh" command, /bin/bash and bash don't work
sudo docker exec -u 0 -i -t "$CONTAINER_NAME" sh
whoami # should be root
nslookup vsphere.int.butters.me
cat /etc/resolv.conf

# outside the container
sudo sysctl -a | grep forward

docker network ls
docker network inspect --verbose bridge host

# ICON config file, not docker config
cat /home/rapid7/config.json

# list all containers
#sudo docker ps -a

# list all images
#sudo docker images -a

# list all networks
#docker network ls

# troubleshooting curl
sudo docker exec -u 0 -i -t rapid7_rest_5.0.3_action sh

nslookup vsphere.int.butters.me
# curl command not installed
# manually install curl
# https://www.jasom.net/how-to-install-curl-command-manually-on-debian-linux/
cd /usr/local/bin || exit 96
wget https://curl.se/download/curl-7.84.0.tar.gz

tar -xvzf curl-*.tar.gz
cd curl* || exit 69
./configure --with-openssl
make
make install
# wow, it worked.


VSPHERE_USERNAME="svc-bash-api@vsphere.local"
VSPHERE_PASSWORD='REDACTED'
curl --insecure -X POST "https://vsphere.local/api/session" -u "$VSPHERE_USERNAME:$VSPHERE_PASSWORD"
# ^ this worked fine on command line
