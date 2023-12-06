#!/bin/bash
# Tim H 2023

# General network and service troubleshooting for Linux

# Install troubleshooting tools for Ubuntu:
# sudo apt-get update
# sudo apt-get install telnet openssl net-tools tcpdump dnsutils

# Install troubleshooting tools for RedHat/CentOS
# sudo yum install telnet openssl tcpdump

# check the status of various Rapid7 product services:

# InsightVM Console service:
sudo systemctl status nexposeconsole.service		

# InsightVM Scan Engine service:
sudo systemctl status nexposeengine.service

# InsightIDR collector service:
sudo systemctl status collector

# Rapid7 Insight Agent:
sudo systemctl status ir_agent

# list all services
sudo service --status-all

# check if firewall services are running:
systemctl status firewalld
systemctl status iptables

# check if SE Linux is enabled and/or running:
sestatus

# check what operating system, version, and architecture:
cat /etc/redhat-release
cat /etc/lsb-release
lsb_release -a
uname -a

# Display networking configuration:
cat /etc/networking/interfaces

# Display DNS servers:
cat /etc/resolv.conf

# Display local OS Firewall rules:
iptables -L
firewall-cmd --list-ports
firewall-cmd --list-services

# check layer 3 connectivity to internet:
ping 8.8.8.8

# display routing tables:
ip r
route

# Checking DNS:
nslookup google.com
nslookup endpoint.ingress.rapid7.com

# initiate layer 3 (TCP) connection to Rapid7 Insight Platform
telnet endpoint.ingress.rapid7.com 443
nc     endpoint.ingress.rapid7.com 443

# Port scan the Insight Platform to verify basic layer 3 connectivity:
# port 443 should be open, 80 should be closed, and 22 should be filtered
nmap -Pn -p 80,443,22 endpoint.ingress.rapid7.com

# For troubleshooting INBOUND connections
# list the ports that this local Linux system is listening on:
netstat -tlnp
lsof -i -P -n | grep LISTEN

# Test for SSL proxy that could be interfering with TLS traffic:
# this command should have this line in it:
# CN = UserInsight Root CA, OU = us-east-1, O = "Rapid7, LLC."
openssl s_client -connect endpoint.ingress.rapid7.com:443

# see what your public IP is:
# WARNING: if the Rapid7 Insight agent is installed on this system, then
# this will trigger an IDR alert
curl ifconfig.co

# list running processes:
top

# list Rapid7 processes:
ps aux | grep rapid7

# show free memory:
free -m

# show load and uptime:
uptime

# show disk space utilization, check for full disks:
df -h

# check sizes of Rapid7 and log directories:
du -sh /opt/rapid7 /var/log

# what disk IO / throughput / IOPS
iostat -mcx 5

# quick search for major problems in Rapid7 logs:
find /opt/rapid7 -type f -iname '*.log' -exec grep -i --with-filename --line-number "error\|severe\|exception" {} \;
