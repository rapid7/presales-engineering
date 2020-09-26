#!/bin/bash
# create vulnerable server. In beta version, doesn't work on all VMs yet.
#
# References:
#   https://phoenixnap.com/kb/how-to-install-vagrant-on-centos-7
#   https://github.com/rapid7/metasploitable3


yum clean all
yum makecache
yum update -y


yum install -q -y  curl wget

yum install -y epel-release
yum install -y gcc dkms make qt libgomp patch
yum install -y kernel-headers kernel-devel binutils glibc-headers glibc-devel font-forge

cd /etc/yum.repos.d/
wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo

yum update -y


yum install -y VirtualBox-5.2
virtualbox --version

mkdir $HOME/metasploitable-setup
cd $HOME/metasploitable-setup
wget https://releases.hashicorp.com/vagrant/2.2.2/vagrant_2.2.2_x86_64.rpm
yum install -y vagrant_2.2.2_x86_64.rpm
vagrant ––version

