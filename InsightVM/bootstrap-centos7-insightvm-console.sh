#!/bin/bash
# Tim H 2021
#   Bootstrap installer for InsightVM Console on CentOS 7
#   sets default UI creds as nxadmin/pxpassword
#
# Common mistakes:
# 1) Forgetting to DISABLE SE LINUX
# 2) Forgetting to add additional engines to the license count - default licenses are often just 1 scan engine
# 3) Forgetting to open firewall to allow incoming connections on TCP 3780 and 40815

# exit if anything fails, do not continue
set -e

if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 1
fi

# move into root user's home directory
cd "$HOME" || cd /root

setenforce 0
echo "SELINUX=disabled
SELINUXTYPE=targeted" > /etc/selinux/config

# update local package list
yum makecache

# install common tools for troubleshooting later. Not mandatory.
yum install -y atop bind-utils coreutils curl \
    glances grep htop iftop  iotop lsof \
    mlocate nc net-tools nload nmap ntpdate open-vm-tools \
    openldap-devel openssh-server openssl openssl-devel pam-devel \
    screen sudo sysstat tar tcpdump tcpflow \
    telnet traceroute tree unzip vim vim-enhanced wget which
    
yum update -q -y

# Download the installer for both InsightVM and Nexpose (same) and MD5 hashsum file
# This makes sure you're getting the latest installer
curl -o Rapid7Setup-Linux64.bin             https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin
curl -o Rapid7Setup-Linux64.bin.sha512sum   http://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.sha512sum

# check the integrity of the IVM installer delete it if it doesn't match
sha512sum --check Rapid7Setup-Linux64.bin.sha512sum || rm -f Rapid7Setup-Linux64.bin

# Mark installer as executable
chmod u+x Rapid7Setup-Linux64.bin

# install InsightVM console, but don't start the service yet
# unfortunately these command line arguments aren't publicly documented
./Rapid7Setup-Linux64.bin -q -overwrite  \
    -Djava.net.useSystemProxies=false \
    -Vfirstname='NAME' \
    -Vlastname='NAME' \
    -Vcompany='COMPANY' \
    -Vusername='nxadmin' \
    -Vpassword1='nxpassword' \
    -Vpassword2='nxpassword' \

# start it up, not started by default
systemctl start nexposeconsole.service

# wait for a long time: 45 minutes, should be enough time for even a slow system to finish starting the service for the first time
sleep 45m
# TODO: switch to an "at" command and set reboot for midnight

# GOTCHA: there's odd stuff that happens on the first service start
# This fixes random weird things that aren't reproducible
systemctl restart nexposeconsole.service
