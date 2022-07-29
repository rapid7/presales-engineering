#!/bin/bash
# Tim H 2020,2022
# This script will setup an environment on OS X for developing 
#   custom InsightConnect plugins in Python. 
# Installing XCode *and* its dependencies takes 2-3 hours, no joke.
# Seriously, there's not a good way to reduce that amount of time that I've
# found.
# It's better to use the GUI to install it than the CLI. The CLI gives
# no updates on progress, but the GUI does.
# https://docs.rapid7.com/insightconnect/create-custom-plugins
# https://github.com/rapid7/insightconnect-plugins
# https://extensions.rapid7.com/

set -e

brew update
brew upgrade

# verify there are no major issues with brew before proceeding:
brew doctor

# installs "Command Line Tools for Xcode"
# must download latest list of updates and install them before running the 
# next commands
# Otherwise you'll get this error: 
#   "Error: Your Command Line Tools are too outdated."
# this may need to be after the xcode-select --install command
softwareupdate --all --install --force


# see where (if any) current Dev tools are installed:
xcode-select --print-path

# remove the old version of Command Line Tools, upgrading via 
#   softwareupdate will not work
# sudo rm -rf /Library/Developer/CommandLineTools

# install Xcode Command Line Tools:
#   https://www.freecodecamp.org/news/install-xcode-command-line-tools/
# pops up interactive prompt
# this will take a long time to download it:
# nominally 60 minutes, maybe hours over a slow connection
xcode-select --install

# sudo xcode-select --switch /Applications/Xcode.app

# install the Rapid7 InsightConnect plugin for Brew
brew tap rapid7/icon-plugin-homebrew https://github.com/rapid7/icon-plugin-homebrew
brew install icon-plugin

# change into a directory where you download GitHub repos
# you may need to make this directory or change it
cd "$HOME/source_code/third_party" || exit 1

# download the InsightConnect GitHub repository
# SLOW: this also takes a few minutes to run
git clone https://github.com/rapid7/insightconnect-plugins/

# updates - will ask for sudo password
cd "$HOME/source_code/third_party/insightconnect-plugins/tools" || exit 5
./update-tools.sh

pip3 install --user insightconnect-integrations-validators pyyaml flake8
npm install -g js-yaml
brew install jq
sudo gem install mdl


##############################################################################
# validate dev env
##############################################################################
# start docker daemon first
# do this in the GUI

# Test: compile an existing plugin from another repo:
# change into the newly downloaded directory
cd insightconnect-plugins/plugins/base64 || exit 2
# build the Docker image for InsightConnect's base64 plugin - just to test
# this takes several minutes
icon-plugin build image

# Test #2 - building a new plugin
# docker service must already be running
cd "$HOME/source_code/presales-engineering-tim-dev/InsightConnect" || exit 7
icon-plugin generate python example.yaml --path /tmp/example
cd /tmp/example/example || exit 8
make
# see the new image on localhost:
docker image list --all
# show the contents of the compressed file that 
# can be uploaded to InsightConnect:
tar -tvf rapid7-example-1.0.0.tar.gz

# Test 3 - download template
docker pull rapid7/insightconnect-python-3-38-slim-plugin
docker run  rapid7/insightconnect-python-3-38-slim-plugin
