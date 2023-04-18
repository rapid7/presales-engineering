#!/bin/bash
# Tim H 2018

# yum update -y

# install dependencies
sudo yum install -y wget sudo unzip which vim initscripts

# go to user's home directory
cd "$HOME" || exit 1

# download the collector instaler
wget --quiet --output-document=Collector_installer.sh "https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh"

# mark it as executable
chmod u+x Collector_installer.sh

# run it
sudo ./Collector_installer.sh

# set to autostart, otherwise it won't. Need to have initscripts installed in CentOS.
sudo chkconfig collector on
