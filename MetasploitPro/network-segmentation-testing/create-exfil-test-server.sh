#!/bin/bash
# Tim H 2020
# external IP exfiltration list for AWS
# ami-0011546a

AWS_REGION="us-east-1"
INSTANCE_TYPE="t1.micro"					# the only one allowed
AMI="ami-0011546a"					        # Ubuntu 12.04
KEYPAIR="aws-marketplace-testing1"			# one I don't care if it gets comprimised
BOOTSTRAP_SCRIPT_FILENAME="file://./TBD.sh"
SECURITY_GROUP="sg-0338d104836ccd813"		# My default one, only from home and work
SUBNET_ID="subnet-0c1fcfd14bc1aa8df"		# Default VPC, us-east-1a (use1-az4)

# bail if any errors
set -e

# attach the new interface
# reboot

#--secondary-private-ip-addresses

INSTANCE_FQDN="exfil-test.aws.butters.me"

#	Launching an instance that uses the bootstrap script:
aws ec2 run-instances \
    --region "$AWS_REGION" \
    --count 1 \
    --instance-type "$INSTANCE_TYPE" \
    --image-id "$AMI" \
    --key-name "$KEYPAIR" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_FQDN},{Key=Route53FQDN,Value=$INSTANCE_FQDN},{Key=Billing,Value=Rapid7Testing},{Key=GeneratedBy,Value=create_new_ec2_bootstrapped_server}]"  \
    --iam-instance-profile Name=EC2-DescribeAllInstanceTagsOnly  \
    --security-group-ids "$SECURITY_GROUP"  \
    --subnet-id "$SUBNET_ID" \
    --user-data "$BOOTSTRAP_SCRIPT_FILENAME" \
    --block-device-mappings file://ebs_termination.json \
    --instance-initiated-shutdown-behavior terminate

#TODO: ignore the blocking step from previous, just output to screen and keep going so it won't delay the sleep
