#!/bin/bash
# Tim H 2019
# manual steps for forcing updates on Rapid7 InsightVM console

# install Ubuntu system updates first if needed.
# sudo apt-get update
# sudo apt-get -y upgrade

# resume the existing screen session to get access to the InsightVM
# interactive console
sudo su
screen -r nexposeconsole

# trigger update for InsightVM Con
update now

# updates the local and other scan engines for product updates
update engines

# update content on InsightVM console
update content

# trigger manual sync w/ Insight Platform
sync cloud

sync policy benchmarks

# clean up memory
garbagecollect

# show details about the InsightVM console
show host

# Ctrl+A then d to exit the screen seession

# update some OS packages if EC2 instance
# sudo apt-get -y upgrade linux-aws linux-headers-aws linux-image-aws

# reboot if necessary
# sudo reboot now

# upgrade Ubuntu LTS version:
# sudo do-release-upgrade
