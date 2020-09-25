#!/bin/bash
# Tim H 2020
#
# Description:
#   This bash script will modify a CentOS 6 (not 7) recently powered on AMI to make it intentionally vulnerable
#   It is designed to be a bootstrap (run once and only once at EC2 creation) to provide good data for demo'ing the 
#   Rapid7 InsightVM AWS Asset Sync connector. This will provide a handul of vulns and get authenticated scanning working
#   At the time of this writing, this script is designed for AMI: ami-03a941394ec9849de - CentOS 6 (x86_64) - with Updates HVM
#   This script takes about 40 seconds to run on a t2.medium


# bomb out in case anything runs an error. Shouldn't happen but can disable if needed
set -e

# set variables
AGENT_ATTRIBUTES="intentionally_vulnerable,aws_test,ephemeral" 
AGENT_TOKEN="us:559dea28-1eb2-48f3-91ff-80671564c960"   #Tim's homelab
LOGFILE="/root/bootstrap.log"


# redirect all output to a logfile
rm -f "$LOGFILE"	# clear the log if it already exists
exec >> "$LOGFILE"
exec 2>&1

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

################################################################################
#		FUNCTION DEFINITIONS
################################################################################

log () {
	# formatted log output including timestamp
	echo -e "[bootstrap] $(date)\t $@"
}


################################################################################
#		MAIN
################################################################################

log "Starting bootstrap script."

# change to root's home directory
cd "$HOME" || cd /root

log "Cleaning up Yum."

# clean up old Yum without installing updates
yum clean all
yum makecache

# set the time zone to US Eastern
# used later in hostname
log "Setting the time zone."
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

# install vulnerable versions of Samba, NFS, and Apache
log "Installing vulnerable software."
yum install -y samba-3.6.23-51.el6 nfs-utils-1.2.3-78.el6 httpd-2.2.15-69.el6.centos

#TODO: disable automatic updates

# drop scanner public key, must be RSA for InsightVM. AWS's default keys aren't compatible with InsightVM, this must be custom.
log "Deploying an SSH public key for InsightVM authenticated scanning"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCz2do9y9lun2/FokTyFm9u1FbkovG/dh8DcAyA7cxrYjDbVATx4ehlsm3imnMhYhxVMxWL83mg0EOFgBI/wfgPNU+BmSvI7k8rbzneUplTqBL+u+aIPOUCtfQbE+BABysBWEx+IAZaZdlBOo5YdwBJVUQC0VVK4aNsnJ8/0attnVoSDJWNuKbor34SKDK2Bw3mT1j7RIaX2x8dJ3cO9ZpTcPNG6oWTLsSWKhpRanpEBzprB7f6imGrEHR+2dMJM3LGoba7zS9eLwDgOf2UhLXoBoaJg7RyAX5E3c3P5rsofRkLyQlMscDQ0W0Xjs7AvxCuITzVjPMiAe5mi+eyzf4iai8h4epN/tXmSqGAQ0Zg2VXhs5VHfFtpv8qqMtzd2hCSOtb6U7q579/2igxC9qkTMJHKGJIpkYVZ+pwxO9hcj2puRm2OKamYeQq7N1nJKpFm6pFXhskzHcoTzZYbOZ40CtoXAWMV5MLUo/+7yZ06YywvJ1qKBPI2qU8rHJETFMOqys1zYa5DSpQ/hZW0JDUAbklRyUoOzZsw8aFIf84k4NDxPRpywLaJ9ElE8sz4FkRtkrXm3+ht4Rw4r3Ygaxk3JO5DBs+OnhffIUdZg76e6L+I86pBGeXFtmyYtMVBUOY3BPALGq+BiklKTCL8Pcf0HvQsqn9X9uE28BRargM/wQ== root@centos7gold.int.butters.me" >> "/home/centos/.ssh/authorized_keys"

# set hostname to identify that it is vulnerable
mdate=$(date +"%Y-%m-%d_%H-%M-%S")
log "Setting new hostname."
hostname "aws-tmp-vulnerable-centos6-$mdate"
#TODO: make hostname change permanent

# disable firewall
# TODO: make change permanent
log "Disabling the firewall"
service iptables stop   && chkconfig iptables off

# start all the vulnerable services
log "Starting all the new vulnerable services."
service httpd start     && chkconfig httpd on
service smb start       && chkconfig smb on
service nfs start       && chkconfig nfs on
service rpcbind start   && chkconfig rpcbind on

log "New vulnerable services started successfully."

# download and install R7 agent
log "Downloading and installing the Rapid7 Insight Agent.
Assigning tags: $AGENT_ATTRIBUTES
Assigning token: $AGENT_TOKEN

"
yum install -y wget
wget --quiet --output-document=agent_installer.sh  https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/1598479690/linux/x86/agent_control_1598479690.sh
chmod u+x agent_installer.sh
./agent_installer.sh install_start --attributes "$AGENT_ATTRIBUTES" --token "$AGENT_TOKEN"
# verify it is running
service ir_agent status

yum install -y at
log "AT installed, about to start AT service"
service atd start && chkconfig atd on
log "AT service started, about to schedule the shutdown"

echo "shutdown -h now" | at now +5 minutes

log "shutdown scheduled but should not be initiated for a while."

log "Bootstrap script finished successfully."
