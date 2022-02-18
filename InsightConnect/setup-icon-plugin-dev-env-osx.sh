#!/bin/bash
# Tim H 2020
# This script will setup an environment on OS X for developing custom InsightConnect
#   plugins in Python. 
# https://docs.rapid7.com/insightconnect/create-custom-plugins
# https://github.com/rapid7/insightconnect-plugins

brew tap rapid7/icon-plugin-homebrew https://github.com/rapid7/icon-plugin-homebrew

# must download latest list of updates and install them before running the next commands
# Otherwise you'll get this error: "Error: Your Command Line Tools are too outdated."
softwareupdate --all --install --force

# remove the old version of Command Line Tools, upgrading via softwareupdate will not work
sudo rm -rf /Library/Developer/CommandLineTools

# install Xcode Command Line Tools: https://www.freecodecamp.org/news/install-xcode-command-line-tools/
# this will take a long time to download it, maybe hours over a slow connection
xcode-select --install

# install the Rapid7 InsightConnect plugin for Brew
brew install icon-plugin

# change into a directory where you download GitHub repos
# you may need to make this directory or change it
cd "$HOME/source_code/" || exit 1

# download the InsightConnect GitHub repository
git clone https://github.com/rapid7/insightconnect-plugins/

# change into the newly downloaded directory
cd insightconnect-plugins/plugins/base64 || exit 2

# start docker daemon first
# do this in the GUI

# build the Docker image for InsightConnect's base64 plugin - just to test
# this takes several minutes
icon-plugin build image
