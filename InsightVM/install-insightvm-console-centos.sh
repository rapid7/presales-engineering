#!/bin/bash
# Tim H 2020-2021
#   Bootstrap installer for InsightVM Console on CentOS 7 64-bit
#   sets default UI creds as nxadmin/nxpassword
#   Estimated runtime on AWS t2.large: ~5 min for install, 10-20 min before webpage is displayed
#
# Common mistakes:
# 1) Forgetting to DISABLE SE LINUX
# 2) Forgetting to add additional engines to the license count - default licenses are often just 1 scan engine
# 3) Forgetting to open firewall to allow incoming connections on TCP 3780 and 40815
# 4) Not meeting the bare minimum system requirements (2 cores, 8 GB RAM, 80 GB HDD), 16 GB RAM is highly recommended
# 5) Forgetting to include the top line of this script #!/bin/bash when pasting into User Data in AWS

# exit if anything fails, do not continue
set -e

if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 1
fi

# move into root user's home directory
cd "$HOME" || cd /root

# disable SELinux immediately  required for InsightVM to work properly
sudo setenforce 0

# disable SELinux on all future reboots. Depending on which user you are,
#   you may have to do do the following to manually type this in, or sudo su - 
# vim /etc/selinux/config
# TODO: make sure this is using sudo:
echo "SELINUX=disabled
SELINUXTYPE=targeted" > /etc/selinux/config
# TODO: make sure that selinux is in fact disabled before running installing

# OPTIONAL - update local package list from Yum, but don't download any updates
sudo yum makecache

# OPTIONAL - install common tools for troubleshooting later. Not mandatory but recommended for troubleshooting/config
sudo yum install -y atop bind-utils coreutils curl \
    glances grep htop iftop iotop lsof \
    mlocate nc net-tools nload nmap ntpdate open-vm-tools \
    openldap-devel openssh-server openssl openssl-devel \
    screen sudo sysstat tar tcpdump tcpflow \
    telnet traceroute tree unzip vim vim-enhanced wget which

# OPTIONAL - install system updates before installing InsightVM
#sudo yum update -q -y

# Download the installer for both InsightVM and Nexpose (same) hashsum file
# This makes sure you're always getting the latest installer
curl -o Rapid7Setup-Linux64.bin             https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin
curl -o Rapid7Setup-Linux64.bin.sha512sum   https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.sha512sum

# check the integrity of the InsightVM installer; delete it if it doesn't match
sha512sum --check Rapid7Setup-Linux64.bin.sha512sum || rm -f Rapid7Setup-Linux64.bin

# Mark installer as executable
chmod u+x Rapid7Setup-Linux64.bin

# install InsightVM console, but don't start the service yet
# unfortunately these command line arguments aren't publicly documented
# the Vfirstname, Vlastname and Vcompany are only used for the self-signed SSL certificate
# this is the non-interactive version that will automatically install InsightVM console
# if you want to do the interactive install, just do:
#   sudo ./Rapid7Setup-Linux64.bin
sudo ./Rapid7Setup-Linux64.bin -q -overwrite  \
    -Djava.net.useSystemProxies=false \
    -Vfirstname='Rapid7 InsightVM Console' \
    -Vlastname='POC' \
    -Vcompany='Rapid7' \
    -Vusername='nxadmin' \
    -Vpassword1='nxpassword' \
    -Vpassword2='nxpassword'

# follow documentation, here is where you'd enable FIPS mode if needed. Enabling FIPS mode MUST be done BEFORE the first service start.
# https://docs.rapid7.com/insightvm/enabling-fips-mode/#enabling-fips-mode

# start the InsightVM console service, not started by default with non-interactive install
sudo systemctl start nexposeconsole.service

########## END OF REQUIRED STEPS, the following are optional for automated deployments:

# wait for a long time: 45 minutes, should be enough time for even a slow system to finish starting the service for the first time
sleep 45m
# TODO: switch to an "at" command and set reboot for midnight

# GOTCHA: there's odd stuff that happens on the first service start
# This fixes random weird things that aren't reproducible
systemctl restart nexposeconsole.service
