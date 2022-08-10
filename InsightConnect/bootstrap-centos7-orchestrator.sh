#!/bin/bash
# Tim H 2021
# Bootstrap script for CentOS 7

# disable SELinux, required for Orchestrator
setenforce 0
echo "SELINUX=disabled
SELINUXTYPE=targeted" > /etc/selinux/config

# opening firewall for Insight Agent to be scanning used InsightVM
# firewall-cmd --zone=public --add-port=31400/udp --permanent
# firewall-cmd --reload

# Download the InsightVM installer
wget "https://us.downloads.connect.insight.rapid7.com/orchestrator/installers/r7-orchestrator-installer.sh"

# mark it as executable
chmod 500 ./r7-orchestrator-installer.sh
sudo ./r7-orchestrator-installer.sh
