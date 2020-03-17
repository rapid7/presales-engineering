#!/bin/bash

aws cloudformation create-stack --stack-name "pptp-vpn" \
    --template-body file://aws-pptp-cloudformation/pptp-server.yaml \
    --parameters file://aws-pptp-cloudformation/pptp-server-params.json \
    --region us-east-1

echo "Waiting for VPN to spin up before checking status..."
sleep 60

aws cloudformation describe-stacks --stack-name "pptp-vpn" \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`VPNServerAddress`].OutputValue' \
    --output text

