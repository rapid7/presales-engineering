#!/bin/bash
# Tim H 2020
#   ___ INCOMPLETE, UNFINISHED____
#
# create vulnerable server. In beta version, doesn't work on all VMs yet.
# designed for hardware CentOS v7 systems. May not work on VMs that aren't configured correctly
#
# References:
#   https://phoenixnap.com/kb/how-to-install-vagrant-on-centos-7
#   https://github.com/rapid7/metasploitable3

# bail if anything fails
set -e

# clean up Yum and install any updates
yum clean all
yum makecache
yum update -y

# install dependencies
yum install -q -y  curl wget

# add new repo for additional dependencies
yum install -y epel-release

# install additional dependencies
yum install -y gcc dkms make qt libgomp patch
yum install -y kernel-headers kernel-devel binutils glibc-headers glibc-devel font-forge

# download VirtualBox repo
cd /etc/yum.repos.d/
wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo

# force update to pull new repo
yum update -y

# install VirtualBox
yum install -y VirtualBox-5.2

# verify installation
virtualbox --version

# download Vagrant
mkdir "$HOME/metasploitable-setup"
cd "$HOME/metasploitable-setup" || exit 1
wget https://releases.hashicorp.com/vagrant/2.2.2/vagrant_2.2.2_x86_64.rpm
yum install -y vagrant_2.2.2_x86_64.rpm
vagrant ––version

#TODO: download and install Metasploitable3
