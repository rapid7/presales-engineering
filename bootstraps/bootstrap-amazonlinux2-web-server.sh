#!/bin/bash
#   Tim H 2019
##############################################################################
#
#		Installs Apache and serves a webpage that describes
#		EC2 instance information. For use with identifying servers
#		behind load balancers
#		Designed for use with Amazon Linux 2
#		Intended to be a boot strap script for use in USER DATA
#		for AWS EC2 instances.
#
#		Note: this only runs on the initial power on and not on 
#		reboots or subsequent starts. It does not run as a cron either.
#	
#		Requirements: this EC2 instanace to have a role that has
#			a policy that allows use of ec2-describe-tags and ec2-describe-instances
#
# 	Documentation links
#		curl http://169.254.269.254/
#		https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
#		https://aws.amazon.com/code/ec2-instance-metadata-query-tool/
#		https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-tags.html
#		https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
#		https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output.html
#		https://www.thegeekstuff.com/2017/07/aws-ec2-cli-userdata/
#
##############################################################################
# Set up logging to external file
LOGFILE="/root/bootstrap.log" 

# redirect all output to a logfile
exec >> "$LOGFILE"
exec 2>&1

#TODO: ensure this is the proper OS and aws packages are installed!!
#TODO: add logic for checks to ensure this instance has role permissions, leave a note if it does not have permissions

# set the time zone as US EAST
echo "ZONE=America/New_York
UTC=true" > /etc/sysconfig/clock
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

echo "Boot strap start: $(date)"

# bail if any errors occur
#set -e 

# Install web server, start it, have it autostart on future boots
yum install httpd deltarpm -q -y
service httpd start
chkconfig httpd on

# Fetch the current instance's region and Instance id.
AWS_REGION=$(ec2-metadata --availability-zone | cut -d " " -f2 | sed 's/.$//')
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f2)

# Fetch information about this instance using the API. If the role isn't enabled, then these fields will be blank
NAME_TAG=$(aws  ec2 describe-tags      --region "$AWS_REGION" --filters "Name=resource-id,Values=${INSTANCE_ID}" | grep -2 Name | grep Value | tr -d ' ' | cut -f2 -d: | tr -d '"' | tr -d ',')
VPC_ID=$(aws    ec2 describe-instances --region "$AWS_REGION" --instance-ids "$INSTANCE_ID" --output text --query "Reservations[0].Instances[0].VpcId")
SUBNET_ID=$(aws ec2 describe-instances --region "$AWS_REGION" --instance-ids "$INSTANCE_ID" --output text --query "Reservations[0].Instances[0].SubnetId")

# log instances details for debug purposes
aws ec2 describe-tags --region "$AWS_REGION" --filters "Name=resource-id,Values=${INSTANCE_ID}" 

# generate an HTML file that has relevant information about this instance
# saves time from having to SSH in.
echo "<html><body><h1>Server Name Tag: $NAME_TAG </h1></p>
Timestamp of when created:  $(date) </p>
Region    : $AWS_REGION </p>
VPC Id    : $VPC_ID </p>
Subnet Id : $SUBNET_ID</p>
$(ec2-metadata --local-hostname) </p> 
$(ec2-metadata --local-ipv4) </p> 
$(ec2-metadata --availability-zone)	</p>
$(ec2-metadata --public-hostname)  	</p> 
$(ec2-metadata --public-ipv4)   </p> 
$(ec2-metadata --security-groups)   </p>
$(ec2-metadata --instance-id)       </p>
$(ec2-metadata --instance-type)     </p>
</p></body></html>" > /var/www/html/index.html

# Install other things I might need
# in Amazon Linux 2 by default: screen openssl tcpdump iostat md5sum netstat vim get
yum install telnet nmap-ncat nmap amazon-efs-utils -q -y

echo "Installing security updates..." 
yum --security update -y -q

echo "Bootstrap script complete: $(date)"

# if using AWS NFS host to dump files for longer term storage
# most people can probably ignore this unless you're doing a more advanced setup
NFS_HOST="172.30.0.48"	#us-east-1a EFS in master account

# Save this Index.html file to a permanent location for record: EFS mount
#TODO: make sure can ping/connect to NFS target first? Security groups might not allow inter-LAN traffic
mkdir /efs
mount -t nfs4  "$NFS_HOST:/" /efs
mount | grep efs
cp /var/www/html/index.html "/efs/$INSTANCE_ID.html"

# Copy this log file off to permanent storage for record keeping
cp "$LOGFILE" "/efs/$INSTANCE_ID.log"
