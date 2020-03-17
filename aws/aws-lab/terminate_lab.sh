#!/bin/bash
##############################################################################
#
#	Terminates all EC2 instances in a given region that match a tag generated
#		by the create_new_ec2_bootstrapped_server.sh script
#
#	TODO: make it work for all regions, or import region from other bash file
#		terminate all types of resources (beyond just EC2) that were created
#		as part of this lab
#		or just kill everything but the security groups and auth keys and IAM
#
#	References:
#		https://github.com/aws/aws-cli/issues/368
#		https://stackoverflow.com/questions/23936216/how-can-i-get-list-of-only-running-instances-when-using-ec2-describe-tags
##############################################################################

AWS_REGION="us-east-1"

# get a list of instances that match a particular filter, even if terminated:
# TODO: create list of only running ones
LIST_OF_INSTANCE_IDS_TO_TERMINATE=$(aws ec2 describe-instances --region "$AWS_REGION" --filter Name=tag:GeneratedBy,Values=create_new_ec2_bootstrapped_server --query "Reservations[*].Instances[*].InstanceId" --output text)

# terminate them in batch in a single region
aws ec2 terminate-instances --region "$AWS_REGION" --instance-ids "$LIST_OF_INSTANCE_IDS_TO_TERMINATE"
