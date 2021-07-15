#!/bin/bash
# Tim H 2019
# General Linux system info and diagnostic info
#	Useful for prospects who want to check a server's specs but aren't 
#	comfortable with command line Linux
# This script does not require root perms
# Does not modify anything or assume any packages are installed
#
#	Usage:
#		1) copy this file onto the Linux server (SCP or WinSCP)
#		2) mark it as executable:
#			chmod +x linux_diag.sh
#		3) run it:
#			./linux_diag.sh
#		4) copy and paste the output to your Rapid7 Sales Engineer

#
#	TODO:
#		* ip route tables
#		* test internet connectivity
#		* test if products installed
#		* test if dependencies installed
#		* DNS settings

#LOGFILE="linux_diag.log"

section_title () {
echo "
==========================================================================
=			$1
==========================================================================
"
}

# redirect all output to a logfile
#rm -f "$LOGFILE"	# clear the log if it already exists
#exec >> "$LOGFILE"
#exec 2>&1

echo "Current user: $(whoami)"
echo "Kernel: $(uname -a)"

section_title "Disk partitions and free space"
df -h

section_title "CPU info"
cat /proc/cpuinfo

section_title "Total and Free memory in megabytes"
free -m

section_title "File system Mount Points"
cat /etc/fstab

section_title "Total size of installed Rapid7 product(s)"
du -sh /opt/rapid7

section_title "Network configuration"
ifconfig

