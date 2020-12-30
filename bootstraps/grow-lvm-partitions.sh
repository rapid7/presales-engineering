#!/bin/bash
# Tim H 2020
# Increasing the size of LVM partitions in CentOS 7 virtual machines
#   You should power off the virtual machine and increase the disk size BEFORE running this script
#   Don't forget to take a snapshot before you make any changes.
# References:
#   https://stackoverflow.com/questions/26305376/resize2fs-bad-magic-number-in-super-block-while-trying-to-open
#   https://www.tecmint.com/extend-and-reduce-lvms-in-linux/

# check which Filessystem is used on /, should be EXT4 or XFS for this script
df -T

# check the free space available on virtual disk. There should be some free blocks to add.
#   In this example, there are 2048 free blocks to add
#   In this example, the outer container is named /dev/mapper/centos_centos7std-root
vgdisplay

# extend the outer container by 2048 blocks
lvextend -l +2048 /dev/mapper/centos_centos7std-root

# extend the inner partition for XFS systems
# automatically extends it to the maximum size
xfs_growfs /dev/mapper/centos_centos7std-root

# different command used for EXT4 file systems: resize2fs
#resize2fs /dev/mapper/centos_centos7std-root
