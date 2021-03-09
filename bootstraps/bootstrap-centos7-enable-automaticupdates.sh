#!/bin/bash
# Tim H 2020
# enable automatic updates in CentOS 7

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# install dependencies
yum install -y yum-cron vim

# check if it is running and setup already:
grep "apply_updates\|update_cmd" /etc/yum/yum-cron.conf
systemctl status yum-cron.service

# change the settings
#apply_updates = no    should be yes
#update_cmd = default  should be security
sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
sed -i 's/update_cmd = default/update_cmd = security/g' /etc/yum/yum-cron.conf

# verify changes
grep "apply_updates\|update_cmd" /etc/yum/yum-cron.conf

# start the service, set it to autostart, verify it is running
systemctl start  yum-cron.service
systemctl enable yum-cron.service
systemctl status yum-cron.service
