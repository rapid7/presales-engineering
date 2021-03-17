#!/bin/bash
# Tim H 2021
# AWS Bootstrap script for CentOS 7 - prepare for the Rapid7 Orchestrator install
# does not perform the install, just preps for it.

echo "bootstrap started $(date)" >> /home/centos/bootstrap.log

NEW_FQDN="orchestrator-test01"
NEW_TIMEZONE="America/New_York"

# disable SELinux
setenforce 0
cat "SELINUX=disabled
SELINUXTYPE=targeted" > /etc/selinux/config

# set the new hostname
echo "$NEW_FQDN" > /etc/hostname
hostname "$NEW_FQDN"

# set the time zone
timedatectl set-timezone "$NEW_TIMEZONE"

# sync the time, make sure it is accurate
ntpdate pool.ntp.org

# install latest updates first
# This section adds about 5 minutes
#yum update -y
# install dependencies and tools
# not installing Java/JRE/JDK: java-11-openjdk-devel
#yum install -y atop autoconf automake awscli bind-utils ca-certificates \
#    cloud-utils-growpart coreutils curl dkms elfutils-libelf-devel \
#    epel-release gcc glances glibc-common grep htop iftop initscripts iotop \
#    kernel-devel kernel-headers libtool lsof lvm2 make \
#    mlocate nc net-tools nfs-utils nload nmap npm ntpdate open-vm-tools \
#    openldap-devel openssh-server openssl openssl-devel pam-devel \
#    python3 python3-pip screen sudo sysstat tar tcpdump tcpflow \
#    telnet traceroute tree unzip vim vim-enhanced wget which \
#    xfsprogs yum-cron yum-utils zlib-devel

# opening firewall for Insight Agent to be scanning used InsightVM
firewall-cmd --zone=public --add-port=31400/udp --permanent
firewall-cmd --reload

# Download the InsightVM installer
curl "https://us.downloads.connect.insight.rapid7.com/orchestrator/installers/r7-orchestrator-installer.sh" \
		-o "/home/centos/r7-orchestrator-installer.sh"

# mark it as executable
chmod 500 /home/centos/r7-orchestrator-installer.sh
chown centos:centos /home/centos/r7-orchestrator-installer.sh
echo "bootstrap finished $(date)" >> /home/centos/bootstrap.log

# reboot to apply firewall, hostname changes and kernel updates
reboot now

# now ssh in and run the installer after it finishes rebooting
