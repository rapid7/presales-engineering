#!/bin/bash
##############################################################################
# Tim H 2020
# Description:
##############################################################################
AWS_REGION="us-east-1"
INSTANCE_TYPE="t2.large"                    # the medium can take long time to start the scan engine service
AMI="ami-03a941394ec9849de"					# CentOS 7
KEYPAIR="aws-marketplace-testing1"			# don't care if it gets comprimised
BOOTSTRAP_SCRIPT_FILENAME="./bootstrap-linux-insightvm-scan-engine.sh"  # Bash bootstrap script to have new VM run to download and install the InsightVM scan engine
SECURITY_GROUP="sg-0338d104836ccd813"		# My default one, access only from home and work IPs, no incoming public internet ports open
SUBNET_ID="subnet-0c1fcfd14bc1aa8df"		# Default VPC, us-east-1a (use1-az4)
COUNTER_FILE="$HOME/.aws_engine_counter.dat"    # path to a text file that stores a number to uniquely identify each scan engine

# bail if any errors occur
set -e

# verify that bootstrap script exists, bail if not
if ! test -f "$BOOTSTRAP_SCRIPT_FILENAME" ; then
	echo "Bootstrap script does not exist: $BOOTSTRAP_SCRIPT_FILENAME"
    exit 1
fi

# setup/create the counter file
# if we don't have a file, start at zero
if [ ! -f "$COUNTER_FILE" ] ; then
  AWS_INSTANCE_COUNTER=1
# otherwise read the value from the file
else
  AWS_INSTANCE_COUNTER=$(cat "$COUNTER_FILE")
fi
# increment the value
AWS_INSTANCE_COUNTER=$(( AWS_INSTANCE_COUNTER + 1))
# and save it for next time
echo "${AWS_INSTANCE_COUNTER}" > "$COUNTER_FILE"

# define fully qualified hostname
INSTANCE_NAME="ivm-scanengine-$AWS_INSTANCE_COUNTER"
NEW_FQDN="$INSTANCE_NAME.awslab.butters.me"

#	Launch an instance that uses the bootstrap script:
#   Sets the tags so that the Route53FQDN cloudformation template will automatically assign a DNS entry to this instance to
#   Sets the EBS volume to automatically delete with the instance
#   Sets the instance to terminate on shut-down, makes testing cleanup easier.
#   TODO: stop the blocking screen
aws ec2 run-instances \
--region "$AWS_REGION" \
--count 1 \
--instance-type "$INSTANCE_TYPE" \
--image-id "$AMI" \
--key-name "$KEYPAIR" \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NEW_FQDN},{Key=Route53FQDN,Value=$NEW_FQDN},{Key=Billing,Value=Rapid7Testing},{Key=GeneratedBy,Value=create_new_ec2_bootstrapped_server}]"  \
--iam-instance-profile Name=EC2-DescribeAllInstanceTagsOnly  \
--security-group-ids "$SECURITY_GROUP"  \
--subnet-id "$SUBNET_ID" \
--user-data "file://$BOOTSTRAP_SCRIPT_FILENAME" \
--block-device-mappings file://../../butters.me/ebs_termination.json \
--instance-initiated-shutdown-behavior terminate

echo "$INSTANCE_NAME"

echo "waiting for DNS..."
sleep 50

# doing the DNS lookup directly from the TLD's name server. In this case it's this AWS server.
#TODO: consider specifying a DNS server
nslookup "$NEW_FQDN"
 
echo "waiting for InsightVM engine service to start up..."

# wait 4 minutes for engine to start up
sleep 240

# console to engine pairing
# available for homelab when console is behind firewall
# Just create a normal InsightVM console user and give them permissions on at least the engine settings.
source ./.env
# uses the following variables from the .env file: IVM_API_USERNAME, IVM_API_PASSWORD, IVM_HOSTNAME_PORT
NEW_ENGINE_ID="$RANDOM" # random number placeholder, could also just pull the highest ID and add one to it

# function to create the POST data body for the upcoming RESTful API request
generate_post_data()
{
  cat <<EOF
{
	"address": "$NEW_FQDN",
	"id": $NEW_ENGINE_ID,
	"name": "$NEW_FQDN",
	"port": 40814,
	"sites": [0]
}
EOF
}

#TODO: add test to ensure connectivity to IVM console
echo "attempting connection to InsightVM console: $IVM_HOSTNAME_PORT"
# InsightVM console API v3 command to make the console initiate pairing to 
# this loves to return 40x's even though it seems to work?
curl  --insecure --trace-ascii pairing_request_body-$NEW_FQDN.log --location "https://$IVM_HOSTNAME_PORT/api/3/scan_engines" \
    --header 'Accept: application/json;charset=UTF-8' \
    --header 'Content-Type: application/json' \
    --user $IVM_API_USERNAME:$IVM_API_PASSWORD \
    --data-raw "$(generate_post_data)"

# output the request body for debugging purposes
#cat pairing_request_body-$NEW_FQDN.log

echo "initiated request to scan engine to pair"
# TODO: approve pairing on the scan engine:
# scp over the script and call it with the console's hostname/IP
# probably use the approve_scan_engine_ip.sh script to avoid having to restart the engine

#################################################
# TODO: pair engine to console
# engine to console

echo "deploy-aws-scan-engine.sh successfully completed"
