#!/bin/bash
# bootsrap for CentOS 8
# standard install

sudo yum install -y mlocate openssh-server net-tools htop telnet nmap nc openssl unzip wget curl tcpdump traceroute sysstat bind-utils lsof vim open-vm-tools gcc automake autoconf libtool make pam-devel yum-utils openldap-devel openssl-devel glibc-common epel-release vim-enhanced python3-pip  tar  grep 
sudo yum groupinstall -y 'Development Tools'

# disable auditd for Rapid7 Insight Agent
systemctl disable auditd
service auditd stop
systemctl restart ir_agent.service
