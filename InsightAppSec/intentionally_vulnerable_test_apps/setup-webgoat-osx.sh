#!/bin/bash
# Tim H 2020
#   Downloading, installing the intentionally vulnerable web application Webgoat 
#   Installs it manually so that third party RASP agents (like tCell) can
#      be installed. Also install WebWolf
#   Designed for OS X, but could easily be ported to Linux.
#   It's a lot easier to just deploy Webgoat to a Docker container but
#     this makes it easier to make changes
#
# After this script runs you can normally visit this page to verify it's working
# Note the HTTP not HTTPS
# http://localhost:8000/WebGoat
#
#   References:
#       https://github.com/WebGoat/WebGoat/releases

# chagne this to whatever the latest version on GitHub is
GOAT_VERSION="8.2.2"
# define what high ports (must be > 1024) are used
# shouldn't need to change these unless you're running other vulnerable apps on this same host
export WEBGOAT_PORT=8000
export WEBGOAT_HSQLPORT=9002
export WEBWOLF_PORT=9091

# Path for where to install WebGoat, doesn't need to necessarily exist
PATH_FOR_INSTALL="$HOME/webgoat"

mkdir "$PATH_FOR_INSTALL"

# move to that directory
cd "$PATH_FOR_INSTALL" || exit 1

# Download the JAR files for both WebGoat and WebWolf
wget "https://github.com/WebGoat/WebGoat/releases/download/v$GOAT_VERSION/webgoat-server-$GOAT_VERSION.jar"
wget "https://github.com/WebGoat/WebGoat/releases/download/v$GOAT_VERSION/webwolf-$GOAT_VERSION.jar"

# TODO: open the firewall?

brew tap homebrew/cask-versions
brew update
brew tap homebrew/cask

# Install java CLI in OS X
brew insall java

# verify it is installed and where
which java

# create symlink so whole OS can find Java without using PATH env variable
# https://remarkablemark.org/blog/2021/04/25/mac-java-command-line-tool-jdk/
# warning this could cause issues if you've already got Java installed in the OS
# outside of Brew
sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

# start WebGoat and leave it running
java -jar "webgoat-server-$GOAT_VERSION.jar" -Dfile.encoding=UTF-8 &
# press enter to return to command line if interactive

# wait for it to finish starting before launching WebWolf
sleep 15

# start WebWolf and leave it running
java -jar "webwolf-$GOAT_VERSION.jar" &
# press enter to return to command line if interactive

# check if it is running in command line
# if it is then you should see a bunch of HTML scroll by
curl -v "http://localhost:$WEBGOAT_PORT/WebGoat/login"
