#!/bin/bash
# Tim H 2023

# Network sensor install on Ubuntu 20.04 LTS

# show network adapters
sudo lshw -C network

# list adapters by name
ip a

ifconfig ens192 up

sudo ethtool ens192

# add the adapter in /etc/netplan/....

# remember that the SPAN port won't get an IP address

# must uninstall R7 agent before installing sensor, otherwise it'll fail
sudo systemctl stop ir_agent
wget "https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/1673466817/linux/x86_64/agent_control_1673466817_x64.sh"
chmod u+x agent_control_1673466817_x64.sh
sudo ./agent_control_1673466817_x64.sh uninstall

# download and install sensor
wget "https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/latest/linux/x86_64/sensor_installer_latest_x64.sh"
chmod u+x sensor_installer_latest_x64.sh
sudo ./sensor_installer_latest_x64.sh install_start --token us:e11b79d9-1111-1111-1111-54526a1775f7

# iface eth1 inet dhcp