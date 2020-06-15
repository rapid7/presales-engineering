#!/bin/bash
#
# CentOS 8 time sync for VMs

dnf install chrony
systemctl enable chronyd
echo "Server pool.ntp.org" >> "/etc/chrony.conf"
systemctl restart chronyd
chronyc sources 
