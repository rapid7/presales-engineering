#!/bin/bash
# Tim H 2018
# Installing the InsightIDR collector on Ubuntu Linux

# pull down the latest list of updates to the next command will work
apt-get update

# install dependencies 
apt-get install -y wget sudo 

# go to user's home directory
cd "$HOME" || exit 1

# download the collector instaler
wget --quiet --output-document=Collector_installer.sh "https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh"

# mark it as executable
chmod u+x Collector_installer.sh

# run it
sudo ./Collector_installer.sh
