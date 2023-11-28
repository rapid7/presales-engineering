#!/bin/bash
# Tim H 2022
# Installing InsightCloudSec on Ubuntu 20.04
# Most relevant: https://docs.divvycloud.com/docs/linux-test-drive-deployment

# 16 GB RAM, 4 cores, 40 GB storage

sudo apt-get update
sudo apt-get install docker-compose

# Installer looks in the wrong path for docker-compose, have to create
# symlink. Oddly  enough, the preflight uses $PATH and finds it, but the
# installer doesn't find it.
sudo ln -s /usr/bin/docker-compose /usr/local/bin/docker-compose

# pre-install check
wget https://s3.amazonaws.com/divvypreflight/preflight.sh
chmod u+x preflight.sh
sudo ./preflight.sh

# download installer
wget https://s3.amazonaws.com/get.divvycloud.com/testdrive/testdrive.sh
chmod u+x testdrive.sh

# install InsightCloudSec "test drive" - takes a few minutes to download
# all the container images:
sudo ./testdrive.sh

# view the new crontab:
sudo crontab -l -u root

# list running containers:
sudo docker ps

# show listening ports:
sudo netstat -tunlp | grep docker

# now visit this page from your web browser to create creds

# https://hostname/setup
# after signing in, view your license information here. You'll have a 30 day
# trial by default
# https://hostname/settings/license
