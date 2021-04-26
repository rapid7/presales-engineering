#!/bin/bash
# Tim H 2020
# Increasing the size of LVM partitions in CentOS 7 virtual machines with XFS file system
#   You should power off the virtual machine and increase the disk size BEFORE running this script
#   May have to delete snapshots before resizing
# References:
#   https://stackoverflow.com/questions/26305376/resize2fs-bad-magic-number-in-super-block-while-trying-to-open
#   https://www.tecmint.com/extend-and-reduce-lvms-in-linux/
#   https://kb.vmware.com/s/article/1006371

# install dependencies for commands called in this script
yum install -y coreutils lvm2 xfsprogs cloud-utils-growpart

# check which Filessystem is used on /, should be EXT4 or XFS for this script
df -T /

fdisk /dev/sda
# n p 3 [enter] [enter] w

# maybe I'll do it this way automated one day
#	https://serverfault.com/questions/258152/fdisk-partition-in-single-line/721878
#parted -a optimal /dev/sda mkpart primary 0% 4096MB

# mandatory reboot after resizing
reboot

pvcreate /dev/sda3
vgextend centos_centos7std /dev/sda3

# check the free space available on virtual disk. There should be some free blocks to add.
#   In this example, there are 2048 free blocks to add
#   In this example, the outer container is named /dev/mapper/centos_centos7std-root
vgdisplay centos_centos7std | grep "Free"

# extend the outer container by XXXX blocks

lvextend -l +XXXX /dev/mapper/centos_centos7std-root

# extend the inner partition for XFS systems
# automatically extends it to the maximum size
xfs_growfs /dev/mapper/centos_centos7std-root

# see final results
df -hT /

# different command used for EXT4 file systems: resize2fs
#resize2fs /dev/mapper/centos_centos7std-root