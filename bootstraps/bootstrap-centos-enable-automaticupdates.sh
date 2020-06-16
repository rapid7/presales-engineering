#!/bin/bash
# enable automatic updates in CentOS

# CentOS 7
yum install -y yum-cron
vim /etc/yum/yum-cron.conf
systemctl start  yum-cron.service
systemctl enable yum-cron.service
systemctl status yum-cron.service



# CentOS 8
dnf install dnf-automatic
rpm -qi dnf-automatic
vim /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer
systemctl list-timers *dnf-*
