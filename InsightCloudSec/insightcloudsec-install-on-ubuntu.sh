#!/bin/bash
# Tim H 2022, 2023
# Installing InsightCloudSec on Ubuntu 20.04
# References:
# https://docs.rapid7.com/insightcloudsec/linux-test-drive-deployment/

# 16 GB RAM, 4 cores, 40 GB storage

sudo apt-get update
sudo apt-get -y install docker-compose

ICS_INSTALL_PATH="/opt/rapid7/InsightCloudSec"
sudo mkdir -p "$ICS_INSTALL_PATH"
sudo chown "$(whoami)":root "$ICS_INSTALL_PATH"
sudo chmod 770 "$ICS_INSTALL_PATH"
cd "$ICS_INSTALL_PATH" || exit 1

# pre-install check
# Nov 20, 2023 - seems like this script is old and several of the checks
# fail when they should not
# wget https://s3.amazonaws.com/divvypreflight/preflight.sh
# chmod u+x preflight.sh
# sudo ./preflight.sh

# download installer
wget https://s3.amazonaws.com/get.divvycloud.com/testdrive/testdrive.sh
chmod u+x testdrive.sh
sudo ./testdrive.sh

# view the new crontab:
sudo crontab -l -u root

# list running containers:
sudo docker ps

# show listening ports:
sudo netstat -tunlp | grep docker

# now visit this page from your web browser to create creds
# curl https://$(hostname):8001/setup
#
# after signing in, view your license information here. You'll have a 30 day
# trial by default
# https://hostname/settings/license
