#!/bin/bash
# Tim H 2021
# Bootstrap script for CentOS 7

# disable SELinux, required for Orchestrator
setenforce 0
echo "SELINUX=disabled
SELINUXTYPE=targeted" | sudo tee /etc/selinux/config

# opening firewall for Insight Agent to be scanning used InsightVM
# firewall-cmd --zone=public --add-port=31400/udp --permanent
# firewall-cmd --reload

# Download the InsightVM installer
# this link typically doesn't change over time
wget "https://us.downloads.connect.insight.rapid7.com/orchestrator/installers/r7-orchestrator-installer.sh"

# mark it as executable
chmod 500 ./r7-orchestrator-installer.sh

# install the orchestrator. It is interactive and will prompt for questions
sudo ./r7-orchestrator-installer.sh

# run diagnostics if there are any problems
orch-diagnostics

# verify the service is running
sudo systemctl status rapid7-orchestrator

# manually print out the activation key if you missed it at the end of install
sudo rapid7-orchestrator --print-activation

