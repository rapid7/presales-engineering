#!/bin/bash
# AWS Bootstrap script for installing InsightVM/Nexpose on Ubuntu 16/18
# Sets the default web console username/password to nxadmin/nxpassword

# exit if anything fails, do not continue
set -e

# move into root user's home directory
cd "$HOME" || cd /root

#TODO: use Curl instead of wget, avoid the logging CPU slowdown that wget seems to be causing
apt-get update -q
apt-get -y install wget

# Download the installer for both InsightVM and Nexpose (same) and MD5 hashsum file
# This makes sure you're getting the latest installer
wget https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.sha512sum

# Check the integrity of the download
sha512sum --check Rapid7Setup-Linux64.bin.sha512sum

# Mark installer as executable
chmod u+x Rapid7Setup-Linux64.bin

# install InsightVM, but don't start the service yet
# unfortunately these command line arguments aren't publicly documented
./Rapid7Setup-Linux64.bin -q -overwrite -Djava.net.useSystemProxies=false \
    -Vfirstname='NAME' \
    -Vlastname='NAME' \
    -Vcompany='COMPANY' \
    -Vusername='nxadmin' \
    -Vpassword1='nxpassword' \
    -Vpassword2='nxpassword' \
    "-Vsys.component.typical$Boolean=true" \
    "-Vsys.component.engine$Boolean=false" \
    "-VcommunicationDirectionChoice$Integer=1" \
    "-VinitService$Boolean=false"

# follow documentation, here is where you'd enable FIPS mode if needed.
# https://docs.rapid7.com/insightvm/enabling-fips-mode/#enabling-fips-mode

# start it up, not started by default
systemctl start nexposeconsole.service

###########################
# Additional notes for firewalls and more
# wait until the service finishes starting
# usually 30 minutes on very first boot after install, depending on hardware specs

# Can activate the license via RESTful API using the activateLicense method, which also supports offline file activation
# https://help.rapid7.com/insightvm/en-us/api/index.html#operation/activateLicense

# TODO: optionally disable database integrity checks before first launch to speed it up
# TODO: install security updates before
#apt-get -y install unattended-upgrades 
#unattended-upgrade -d

# TODO: Automatically resize the disk if not using the whole thing:
#resize2fs $(mount | grep "/ " | cut -f1 -d" " )

# open firewall on CentOS 7 with firewalld
#firewall-cmd --permanent --zone=public --add-port=3780/tcp
#firewall-cmd --permanent --zone=public --add-service=https
#systemctl restart firewalld
