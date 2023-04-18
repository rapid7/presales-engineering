#!/bin/bash
# Tim H 2021, 2022
# AWS Bootstrap script for CentOS 7 - prepare for the Rapid7 Collector install
# Also works on regular ISO installs of CentOS
# Does not perform the install, just preps for it.

NEW_FQDN="collector-test01.company.local" # MUST BE fully qualified domain name, must have periods in the title

# install some dependencies for this script
sudo yum install -y ntpdate curl

# disable SELinux, won't take effect until reboot since I think it's a kernel driver/module
sudo setenforce 0
echo "SELINUX=disabled
SELINUXTYPE=targeted" | sudo tee /etc/selinux/config

# set the new hostname immediately and persistently
echo "$NEW_FQDN" > /etc/hostname
sudo hostname "$NEW_FQDN"

# sync the time, make sure it is accurate. Collector will fail to install if the clock is off by more than (X) minutes.
sudo ntpdate pool.ntp.org

# disable the firewall, depends on how you have it configured.
# you can do this on your own, depending on how your org works.
# If you're using a vanilla AWS/ISO version of Core (minimal install) CentOS then you can also skip this step for now
# Might need to open inbound ports once you start adding event sources that send syslogs to this collector

# Download the collector installer
curl -o InsightSetup-Linux64.sh    https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh

# mark it as executable
sudo chmod u+x ./InsightSetup-Linux64.sh

# MUST reboot here to apply SE Linux changes
# I don't think it's possible to disable SE Linux without rebooting
sudo reboot now

#-----------------------------------------------------------------------------
## The following commands should be pasted in AFTER the reboot
## you can remove the leading # character

## run the installer after reboot:
# sudo ./InsightSetup-Linux64.sh

## check to see if the service has started
# status collector service

## if it has not started, then start it:
# sudo service collector start

## watch the logs to see what the activation key is.
## NOTE: this key will change if you restart the service/server:
# tail -f /opt/rapid7/collector/logs/bootstrap.0.log

## Now you can paste that key into InsightIDR to start the pairing process
## If you see "Generating Cryptographic Keys" in InsightIDR then it is working