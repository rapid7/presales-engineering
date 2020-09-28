#!/bin/bash
# Tim H 2020
# fix ICMP redirection flaw in Ubuntu
# InsightVM finds this vuln on all default Ubuntu systems

echo "
###########################################
# Added via script
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
###########################################
" >> /etc/sysctl.conf

echo "reboot now for changes to take effect"
