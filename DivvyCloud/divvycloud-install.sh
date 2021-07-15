#!/bin/bash
# Tim H 2020
# installing and testing DivvyCloud

# 8GB w/ 2 cores

yum remove -y docker docker-compose
yum autoremove

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker.service

curl -s https://s3.amazonaws.com/divvypreflight/preflight.sh | sudo bash
curl -s https://s3.amazonaws.com/get.divvycloud.com/testdrive/testdrive.sh | sudo bash

systemctl enable docker.service
