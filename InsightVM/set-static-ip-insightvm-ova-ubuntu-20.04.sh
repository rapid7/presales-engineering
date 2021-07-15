#!/bin/bash
# Tim H 2021
# Setting a Static IP for the InsightVM Console OVA here: http://download2.rapid7.com/download/InsightVM/Rapid7VA.ova
# At the time of this writing, the OVA is using Ubuntu Server 20.04.2 LTS 64-bit
# The default SSH credentials for the OVA are nexpose/nexpose
#
# References:
#   https://linuxize.com/post/how-to-configure-static-ip-address-on-ubuntu-20-04/

# exit if anything fails, do not continue
set -e

# view the virtual network adapter name, it's probably ens32 but you should double check
ip addr

# generate the netplan config file. 
# set the "addresses" equal to the static IP you want, and the CIDR address range it will be in
#   ex: the static IP desired here is 10.0.1.199 and it will be on the 10.0.1.0/24 network

cat << EOF > /etc/netplan/00-installer-config.yaml
# Example config
network:
  version: 2
  renderer: networkd
  ethernets:
    ens32:
      dhcp4: no
      addresses:
       - 10.0.1.199/24
      gateway4: 10.0.1.1
      nameservers:
          addresses: [10.0.1.11, 10.0.1.1, 208.67.222.222, 208.67.220.220]

EOF

# verify the file was written (just in case permissions are an issue)
cat /etc/netplan/00-installer-config.yaml

# apply the changes
sudo netplan apply

# view your new IP configuration
ip addr

# verify network connectivity
ping -c 3 8.8.8.8
nslookup google.com                       # test external DNS
#nslookup internal-server-name.corp.local # test internal DNS
route




##############################################################################
# OPTIONAL STUFF FOR DEBUGGING:
##############################################################################

# fetch and install OS updates first
sudo apt-get update -q
sudo apt-get upgrade

# openssh in the OVA does not have host keys created by default (for security)

# remove openssh, including the config files (where the problem is)
sudo apt-get purge -y openssh-server

# re-install it
sudo apt-get install -y openssh-server

# allow SSH for remote access
sudo ufw allow ssh  # open firewall for ssh

# start ssh:
sudo systemctl start ssh

# optional debug tool that provides ifconfig, not installed in OVA by default
sudo apt-get install net-tools
