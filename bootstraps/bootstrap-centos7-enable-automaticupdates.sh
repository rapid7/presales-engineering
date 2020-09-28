#!/bin/bash
# Tim H 2020
# enable automatic updates in CentOS 7

yum install -y yum-cron
vim /etc/yum/yum-cron.conf
systemctl start  yum-cron.service
systemctl enable yum-cron.service
systemctl status yum-cron.service
