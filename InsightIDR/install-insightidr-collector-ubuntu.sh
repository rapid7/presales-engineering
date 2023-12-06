#!/bin/bash
# Tim H 2018
# Installing the InsightIDR collector on Ubuntu Linux

# pull down the latest list of updates to the next command will work
sudo apt-get update

# install dependencies 
sudo apt-get install -y wget sudo 

# go to user's home directory
cd "$HOME" || exit 1

# download the collector instaler
wget --quiet --output-document=Collector_installer.sh "https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh"

# mark it as executable
chmod u+x Collector_installer.sh

# run it
sudo ./Collector_installer.sh

# service should automatically start after install
# you can verify it is running here:
sudo service collector status

# next you will have to pair the collector.
# you can programatically extract the collector's pairing key by following
# this script:
# https://github.com/rapid7/presales-engineering/blob/tim-dev/InsightIDR/extract-InsightIDR-collector-pairing-key.sh
