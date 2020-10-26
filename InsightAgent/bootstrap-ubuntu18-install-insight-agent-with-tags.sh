#!/bin/bash
#   Tim H 2020
##############################################################################
#		Proof of concept code, absolutely not designed for production usage
#
#	Description:
#		This bash script is designed to be used as a boot strap (User Data) script
#		with EC2 instances created in Amazon Web Services to manually specify
#		AWS tags as attributes for the Rapid7 Insight Agent install.
#		This script downloads a customer-specific copy of the agent, then pulls
#		a list of AWS tags and installs the agent with the specified tags.
#
#	Required for this EC2 instance:
#		Role to allow read-only access to the bucket where the agent installer is
#		Role to allow ec2 describe-tags API call
#		This script is designed for Ubuntu 18.04
#
#	Limitations / POC code
#		This prototype will not work with spaces or any funky punctuation.
#		This will only work with basic tags like TagName1,TagValue1.
#		The EC2 instance must have tags.
#		You're welcome to add additional text processing to convert unsupported
#		characters to supported ones. If an unsupported character is used, then
#		installation will fail. If more than 1 instance is launched together
#		it will add tags that have a : in them and will cause the install to fail
##############################################################################

# change into current (root) user's home directory, different AMI's start in different places
cd ~ || exit 1

# Ubuntu version - install dependencies in vanilla Ubuntu 18.04
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install python3-pip unzip awscli
pip3 install awscli --upgrade --user

# copy the Linux installer from an S3 bucket
aws s3 cp s3://ivm-agent-test1/agents-linux.zip .

# unzip the file
unzip agents-linux.zip

# mark it as executable
chmod u+x agent_installer.sh

# get the current region
AWS_REGION=$(ec2metadata --availability-zone | cut -d " " -f2 | sed 's/.$//')

# get the instance ID for my current instance for the later API call
INSTANCE_ID=$(ec2metadata --instance-id | cut -d " " -f2)

# pull the list of tags and transform them into usable format
TAGS_LIST=$(aws ec2 describe-tags --region "$AWS_REGION" --filters "Name=resource-id,Values=${INSTANCE_ID}" --output text | cut -d$'\t' -f2,5 | sed -e 's/\t/=/g' | sed -e ':a;N;$!ba;s/\n/,/g' )

# install with the listed tags as attributes
sudo ./agent_installer.sh install_start --attributes "$TAGS_LIST"
