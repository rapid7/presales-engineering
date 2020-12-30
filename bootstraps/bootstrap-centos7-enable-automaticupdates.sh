#!/bin/bash
# Tim H 2020
# enable automatic updates in CentOS 7
#   still requires manual work in the yum-cron.conf file

echo "this script is not yet ready to be automatically run."
exit 1

yum install -y yum-cron vim
#apply_updates = no    should be yes
#update_cmd = default  should be security
vim /etc/yum/yum-cron.conf
#TODO: fix the enabled via sed instead of manually via VIM
systemctl start  yum-cron.service
systemctl enable yum-cron.service
systemctl status yum-cron.service
