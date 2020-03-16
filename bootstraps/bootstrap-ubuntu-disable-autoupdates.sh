#!/bin/bash
# Bootstrap script to disable unattended upgrades on Ubuntu systems
# Designed for checking for vulns, ensure accuracy of findings for base AMI, not a patched version
# Stop the service ASAP
service unattended-upgrades stop

# Wait a second just in case
sleep 1

# Forcibly kill it, if it is still running
pkill -f "unattended-upgrades"

# grab the list of updates, but do not actually update. Often needed before you can do a remove
apt-get update -qq

# uninstall the package to prevent it from happening on reboot or ever
apt-get remove -qq -y unattended-upgrades

# leave a market in user home directories to let them know this script ran
apt-get upgrade --dry-run > /root/updates-have-been-disabled.log

# Additional optional things that weren't needed at least for the short power on/off test.
# after a test run, the following directory had all logs as 0 bytes and hadn't been changed since power on
#  /var/log/unattended-upgrades/
#
# Kill any other APT processes from autostarting
#rm -f /etc/apt/apt.conf.d/20auto-upgrades
#rf -f /etc/apt/apt.conf.d/50unattended-upgrades
