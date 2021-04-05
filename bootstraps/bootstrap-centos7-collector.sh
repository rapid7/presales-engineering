#!/bin/bash
# Tim H 2021
# AWS Bootstrap script for CentOS 7 - prepare for the Rapid7 Collector install
# does not perform the install, just preps for it.

NEW_FQDN="collector-test01.company.local" # MUST BE fully qualified domain name, must have periods in the title

# disable SELinux
setenforce 0
echo "SELINUX=disabled
SELINUXTYPE=targeted" > /etc/selinux/config

# set the new hostname
echo "$NEW_FQDN" > /etc/hostname
hostname "$NEW_FQDN"

# sync the time, make sure it is accurate. Collector will fail to install if the clock is off by more than (X) minutes.
ntpdate pool.ntp.org

# disable the firewall
# depends on how you have it configured.

# Download the collector installer
curl -o InsightSetup-Linux64.sh    https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh

# mark it as executable
chmod u+x ./InsightSetup-Linux64.sh

# reboot to apply firewall, hostname changes and kernel updates
reboot now

# now ssh in and run the installer after it finishes rebooting
