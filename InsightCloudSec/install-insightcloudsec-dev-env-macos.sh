#!/bin/bash
# Tim H 2023
# Installing InsightCloudSec tiny version on OS X
# this should probably work for Linux command line too
# References:
# https://docs.rapid7.com/insightcloudsec/mac-test-drive-deployment/

# 4 GB RAM, 2 cores, 40 GB storage

ICS_INSTALL_PATH="$HOME/.docker/InsightCloudSec"
mkdir -p "$ICS_INSTALL_PATH"
cd "$ICS_INSTALL_PATH" || exit 1

# Download the docker files
curl -sO https://s3.amazonaws.com/get.divvycloud.com/compose/prod.env
curl -s https://s3.amazonaws.com/get.divvycloud.com/compose/docker-compose.db-local.yml -o docker-compose.yml

# change some settings so that only 1 worker node is created instead of 8
sed -i'.original' -e 's/scale:\ 8/scale:\ 1/g' docker-compose.yml
sed -i "" -e 's/.*\/var\/lib\/mysql.*/&\n    command:\n     - --lower-case-table-names=1/' docker-compose.yml

# chmod -R +r "$ICS_INSTALL_PATH"

# start docker desktop on MacOS if it isn't started already:
# skip this if using Linux:
# open -a Docker

# wait 60 seconds or so for it to finish launching

# start the InsightCloudSec images for the first time, takes several minutes
docker-compose up -d

# list running containers:
docker ps

# show listening ports:
# netstat -tunlp | grep docker

# now visit this page from your web browser to create creds
# curl http://$(hostname):8001/setup
#
# after signing in, view your license information here. You'll have a 30 day
# trial by default
# https://hostname/settings/license
