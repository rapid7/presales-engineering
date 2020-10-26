#!/bin/bash
# Tim H 2020
# enable automatic updates in CentOS 8

dnf install dnf-automatic
rpm -qi dnf-automatic
vim /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer
systemctl list-timers *dnf-*
