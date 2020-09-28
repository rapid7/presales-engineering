#!/bin/bash
#   Tim H 2019
# automatic updates for Ubuntu
# unknown version of Ubuntu, probably 16 or 18
#
apt-get update
apt-get install -y unattended-upgrades
vim /etc/apt/apt.conf.d/50unattended-upgrades
vim /etc/apt/apt.conf.d/20auto-upgrades
unattended-upgrades --dry-run --debug
cat /var/log/unattended-upgrades/unattended-upgrades.log
