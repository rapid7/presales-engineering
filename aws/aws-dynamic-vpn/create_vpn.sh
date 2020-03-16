#!/bin/bash
##############################################################################
#
#	References:
#		https://github.com/t04glovern/aws-pptp-cloudformation	
#		https://apple.stackexchange.com/questions/128297/how-to-create-a-vpn-connection-via-terminal
#		https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=pptp-vpn&templateURL=https://s3.amazonaws.com/devopstar/resources/aws-pptp-cloudformation/pptp-server.yaml
#		https://s3.amazonaws.com/devopstar/resources/aws-pptp-cloudformation/pptp-server.yaml
#
##############################################################################
set -e

CONFIG_DIRECTORY="$HOME/Documents/no_backup/aws-pptp-cloudformation"
REGION="us-east-1"
#TODO: potentially make the directory, do a git clone if necessary

# Stack name can include letters (A-Z and a-z), numbers (0-9), and dashes (-).
CURRENT_DATE=$(date +%Y-%m-%d-%H-%M-%S)
STACK_NAME="pptp-vpn-$CURRENT_DATE"
PARAMS_FILE="$CONFIG_DIRECTORY/pptp-server-params-$STACK_NAME.json"

# Generate random username, password, passphrase; avoid confusing characters
randpw(){ openssl rand -base64 64 | tr -cd 'a-hj-km-zA-HJ-KM-Z2-9' | cut -c1-16; }

# must start with letter
VPN_USERNAME=$(echo -n "u" && randpw)  #always must start with letter
VPN_PASSWORD=$(echo -n "p" && randpw)
VPN_PHRASE=$(echo -n "ph"  && randpw)

# output to a unique config file
cat > "$PARAMS_FILE" <<- EOM
[
    {
        "ParameterKey": "VPNUsername",
        "ParameterValue": "$VPN_USERNAME"
    },
    {
        "ParameterKey": "VPNPassword",
        "ParameterValue": "$VPN_PASSWORD"
    },
    {
        "ParameterKey": "VPNPhrase",
        "ParameterValue": "$VPN_PHRASE"
    },
    {
        "ParameterKey": "InstanceSize",
        "ParameterValue": "Standard.VPN-t2.micro"
    },
    {
        "ParameterKey": "DNSServerPrimary",
        "ParameterValue": "1.1.1.1"
    },
    {
        "ParameterKey": "DNSServerSecondary",
        "ParameterValue": "1.0.0.1"
    }
]
EOM

# mark this file as read only by the current user, limit access to sensitive info
chmod 400 "$PARAMS_FILE"

#TODO: make this an IF statement, bomb out if can't built it
# failed because my master account is ec2-classic and can't have a default VPC
aws cloudformation create-stack --stack-name "$STACK_NAME" \
    --template-body "file://$CONFIG_DIRECTORY/pptp-server.yaml" \
    --parameters "file://$PARAMS_FILE" \
    --region "$REGION"

echo "Started stack deployment $STACK_NAME"

# wait and poll until the stack is finished spinning up
while true
do
	STACK_STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --output text | grep "$STACK_NAME" | awk -F\t '{print $NF}' )

    if [ "$STACK_STATUS" == "CREATE_COMPLETE" ] ; then
       break;
    elif [ "$STACK_STATUS" == "ROLLBACK_COMPLETE" ]
    then
        echo "build failed, aborting: $STACK_STATUS"
        exit
	else
	   echo "waiting on stack to start... $STACK_STATUS"
	   sleep 7
	fi
done

# store the IP
STACK_IP=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --query 'Stacks[0].Outputs[?OutputKey==`VPNServerAddress`].OutputValue' --output text)

echo "Build finished, IP is $STACK_IP"

# wait until the VPN port is open
while true
do
	PORT_STATUS=$( nmap -Pn -p 1723 "$STACK_IP" | grep 1723 | cut -d' ' -f2 )

	if [ "$PORT_STATUS" == "open" ]; then
		break;
	else
	   echo "Waiting on port to open on IP... $PORT_STATUS"
	   sleep 10
	fi
done

echo "VPN is now ready for you to connect:
IP:       $STACK_IP
Username: $VPN_USERNAME
Password: $VPN_PASSWORD
Phrase:   $VPN_PHRASE
"

# get list of local OS X VPNs
#scutil --nc list

# in the future replace this with importing from JSON file
#source vpn_creds.config

#scutil --nc trigger "$STACK_IP" --user "$VPN_USERNAME" --password "$VPN_PASSWORD" --secret "$VPN_SECRET"

# update local Mac config to use this address or just initiate it, maybe clear DNS cache
#sudo killall -HUP mDNSResponder;say DNS cache has been flushed
#sudo dscacheutil -flushcache

#TODO: Lambda function or other bash script to automatically terminate cloudformation template on disconnect or within 15 minutes of disconnect
