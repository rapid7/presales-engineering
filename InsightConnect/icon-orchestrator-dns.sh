#!/bin/bash
# Tim H 2022
# Fixing containers not using on-prem DNS as defined by OS
# stop the orchestrator service
# delete all the containers, images, volumes
# uninstall the yum packages dnsmasq and NetworkManager
# manually configure for DHCP here: /etc/sysconfig/network-scripts/ifcfg-ens160
# reboot, trigger workflows
# the dns caching service dnsmasq was at fault

# https://docs.docker.com/config/containers/container-networking/#dns-services
# https://www.opentechguides.com/how-to/article/centos/165/centos7-network-config.html
# https://docs.rapid7.com/insightconnect/command-line-help#command-shortcuts
# https://docs.rapid7.com/insightconnect/troubleshoot-a-plugin/#plugin-actions-cannot-connect-to-external-resources
# https://docs.docker.com/engine/reference/commandline/network_inspect/
# https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes

# stop the service, does not stop containers
sudo systemctl stop rapid7-orchestrator

# delete all containers and force redownload
# stop and remove all containers
sudo docker stop $(docker ps -a -q)
sudo docker rm $(docker ps -a -q)

# delete all images
sudo docker rmi $(docker images -a -q)

# clean up anything else left over
sudo docker system prune --all --force

# important extra step, volumes not covered by --all for some reason
sudo docker system prune --volumes --force

# prune unused (all) docker networks
# doesn't do anything, I guess they're all in use?
docker network prune --force

# remove networkmanager and setup manual DHCP
# also, delete dnsmasq files
sudo yum remove -y dnsmasq NetworkManager

# delete all dnsmasq stuff when networkmanager is installed
find / -iname '*dnsmasq*' -delete 2>/dev/null

# set the adapter name and DHCP mode
sudo bash -c "cat > /etc/sysconfig/network-scripts/ifcfg-ens160" <<EOF
NAME="ens160"
DEVICE="ens160"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
EOF

sudo reboot now

# make sure you got an IP address and DHCP is working
ifconfig

# verify that DNS server IPs and domains are listed here,
# and NOT 127.0.0.1 in the CentOS VM

cat /etc/resolv.conf

# orchestrator service will automatically restart

# then trigger workflows
# containers will be re-downloaded as they are triggered
# they won't be all downloaded immediately
