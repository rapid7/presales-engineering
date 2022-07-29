#!/bin/bash
# Tim H 2020-2021
# Bootstrap script for installing InsightVM/Nexpose on Ubuntu 20.04 64-bit
#   sets default UI creds as nxadmin/nxpassword
#
# Common mistakes:
# 1) Forgetting to add additional engines to the license count - trial licenses are often just 1 scan engine
# 2) Forgetting to open firewall to allow incoming connections on TCP 3780 and 40815
# 3) Not meeting the bare minimum system requirements (2 cores, 16 GB RAM, 80 GB HDD)

# exit if anything fails, do not continue
set -e

# move into root user's home directory
cd "$HOME" || cd /root

# OPTIONAL - update the package list
# sudo apt-get update -q

# Download the installer for both InsightVM and Nexpose (same) 
# and MD5 hashsum file
# This makes sure you're getting the latest installer
curl -o Rapid7Setup-Linux64.bin             https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin
curl -o Rapid7Setup-Linux64.bin.sha512sum   https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.sha512sum

# Check the integrity of the download, makes sure IPSes or 
# SSL proxies didn't mess with the installer.
sha512sum --check Rapid7Setup-Linux64.bin.sha512sum

# Mark installer as executable
chmod u+x Rapid7Setup-Linux64.bin

# install InsightVM console, but don't start the service yet
# unfortunately these command line arguments aren't publicly documented
# the Vfirstname, Vlastname and Vcompany are only used for the self-signed SSL certificate
# this is the non-interactive version that will automatically install InsightVM console
# if you want to do the interactive install, just do:
#   sudo ./Rapid7Setup-Linux64.bin
#
# WARNING: do not use this first account as a personal account
#   do not attempt to use Platform Login with it.

sudo ./Rapid7Setup-Linux64.bin -q -overwrite  \
    -Djava.net.useSystemProxies=false \
    -Vfirstname='Rapid7 InsightVM Console' \
    -Vlastname='POC' \
    -Vcompany='Rapid7' \
    -Vusername='nxadmin' \
    -Vpassword1='nxpassword' \
    -Vpassword2='nxpassword'

# If you're going to enable FIPS mode, you must do it before starting
# the service for the first time. See more here:
# https://docs.rapid7.com/insightvm/enabling-fips-mode/#enabling-fips-mode

# Now is a good time to add remote mount points for the backups location
# make sure those backup files are not on the same virtual machine
# the backups directory does not exist until the first backup is created, so
# you'll need to create it first.
# sudo mkdir /opt/rapid7/nexpose/nsc/backups
# here is an example of an NFS mount point
# echo "10.0.1.35:/volume1/nfs_insightvm /opt/rapid7/nexpose/nsc/backups      nfs auto,nofail,noexec,noatime,nolock,intr,tcp,actimeo=1800 0 0" | sudo tee -a /etc/fstab
# sudo mount /opt/rapid7/nexpose/nsc/backups

# start it up, not started by default
sudo systemctl start nexposeconsole.service

###########################
# Additional notes for firewalls and more
# wait until the service finishes starting
# usually 30 minutes on very first boot after install, depending on hardware specs

# Can activate the license via RESTful API using the activateLicense method, which also supports offline file activation
# https://help.rapid7.com/insightvm/en-us/api/index.html#operation/activateLicense

# TODO: optionally disable database integrity checks before first launch to speed it up

# Enable automatic security updates:
# apt-get -y install unattended-upgrades 
# unattended-upgrade -d

# Automatically resize the disk if not using the whole thing:
# resize2fs $(mount | grep "/ " | cut -f1 -d" " )
