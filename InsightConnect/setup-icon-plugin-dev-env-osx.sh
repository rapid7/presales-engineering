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

# install brew if it's not already installed
brew update
brew upgrade

# reinstall all installed versions of Python from Brew:
# helps fix minor issues that creep up over the years:
brew list --formula -1 | grep 'python@' | xargs -n1 brew reinstall

# verify there are no major issues with brew before proceeding:
brew doctor

# other dependencies:
# verify that python is at least v 3.0 or later
python3 --version
# check "python" version - you may get prompted for installing dev tools
# that will take 90-120 minutes even thought it says 23 min
python --version

# upgrade PIP, both sudo and regular are needed for some dumb reason
sudo pip3 install --upgrade pip
pip3 install --upgrade pip

# verify Docker is installed:
docker --version

# verify make is installed:
make --version

# install "Command Line Tools for Xcode"
# this takes a few hours too, but the command line looks like it freezes
# and it seems like there is no progress.
softwareupdate --all --install --force

# see where (if any) current Dev tools are installed:
xcode-select --print-path

# remove the old version of Command Line Tools, upgrading via 
#   softwareupdate will not work
# sudo rm -rf /Library/Developer/CommandLineTools

# install Xcode Command Line Tools:
# pops up interactive prompt
# this will take a long time to download it:
# nominally 60 minutes, maybe hours over a slow connection
xcode-select --install

# remove old or broken version of stuff:
rm -Rf /usr/local/Homebrew/Library/Taps/rapid7/

# install the Rapid7 InsightConnect plugin for Brew
# this is broken for some reason
# brew tap --verbose rapid7/icon-plugin-homebrew https://github.com/rapid7/icon-plugin-homebrew
# Error: Invalid formula: /usr/local/Homebrew/Library/Taps/rapid7/homebrew-icon-plugin-homebrew/icon-plugin.rb
# icon-plugin: wrong number of arguments (given 1, expected 0)
# Error: Cannot tap rapid7/icon-plugin-homebrew: invalid syntax in tap!
# brew install icon-plugin

# manual OS X install of icon-plugin:
cd "$HOME/Downloads" || exit 5
wget "https://github.com/rapid7/icon-plugin-homebrew/releases/download/v4.11.6/icon-plugin_v4.11.6_Darwin_x86_64.tar.gz"
tar -xf icon-plugin_v4.11.6_Darwin_x86_64.tar.gz
cp icon-plugin /usr/local/bin/

# change into a directory where you download GitHub repos
# you may need to make this directory or change it
cd "$HOME/source_code/third_party" || exit 1

# download the InsightConnect GitHub repository
# SLOW: takes a few minutes to run
git clone https://github.com/rapid7/insightconnect-plugins/

# updates - will ask for sudo password
# this also has errors, may have to do with SentinelOne agent
# npm ERR! Error: EPERM: operation not permitted, lchown '/usr/local/bin/sentinelctl'
# cd "$HOME/source_code/third_party/insightconnect-plugins/tools" || exit 5
# sudo ./update-tools.sh

# manual replacement for update-tools.sh:
pip install --user insightconnect-integrations-validators pyyaml flake8
npm install -g js-yaml
brew install jq
sudo gem install mdl

##############################################################################
# validate dev env
##############################################################################
# start docker daemon first
# do this in the GUI

# Test 1: compile an existing plugin from another repo:
# change into the newly downloaded directory
cd "$HOME/source_code/third_party/insightconnect-plugins/plugins/base64" || exit 2
# build the Docker image for InsightConnect's base64 plugin - just to test
# this takes several minutes
icon-plugin build image
# compile code, does not require sudo:
make

# Test #2 - building a new plugin
# docker service must already be running
cd "$HOME/source_code/ubiquiti-udmp-api/insightconnect/plugins/example" || exit 7
rm -Rf /tmp/example
icon-plugin generate python plugin.spec.yaml --path /tmp/example
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
