#!/bin/bash
# Tim H 2021
#
#   Script for detailed network troubleshooting for pairing the Rapid7 InsightVM console to the Rapid7 Insight Platform
#   This script will perform a variety of network tests such as DNS, telnet, and certificate checking via openssl
# References:
#   https://docs.rapid7.com/insightvm/configure-communications-with-the-insight-platform/
#   https://docs.pingidentity.com/bundle/solution-guides/page/iqs1569423823079.html

# check basic internet connectivity
nslookup google.com
ping 8.8.8.8
sudo apt-get update

# install dependencies
#sudo apt-get install curl dnsutils net-tools netcat nmap tcpdump tcpflow telnet traceroute
sudo apt-get install curl dnsutils net-tools netcat telnet

# test basic visit to google.com using curl
curl https://www.google.com

# All US regions
#for R7_FQDN_ITER in exposure-analytics.insight.rapid7.com data.insight.rapid7.com s3.amazonaws.com us2.exposure-analytics.insight.rapid7.com us2.data.insight.rapid7.com s3.us-east-2.amazonaws.com us3.exposure-analytics.insight.rapid7.com us3.data.insight.rapid7.com s3.us-west-2.amazonaws.com

# Just US region 1 in N. Virginia
for R7_FQDN_ITER in exposure-analytics.insight.rapid7.com data.insight.rapid7.com s3.amazonaws.com
do
    echo "
==============================================================================
Testing connectivity to $R7_FQDN_ITER ..."
    nslookup "$R7_FQDN_ITER"
    nc -z "$R7_FQDN_ITER" 443
    #echo "Q" | openssl s_client -connect "$R7_FQDN_ITER":443 -showcerts
    echo "SSL certificate information:"
    echo "Q" | openssl s_client -connect "$R7_FQDN_ITER":443 -showcerts 2>&1 | grep -E "^subject|^issuer"
done

echo "script finished successfully."

#echo "Q" | openssl s_client -connect exposure-analytics.insight.rapid7.com:443 2>&1 | egrep "^subject|^issuer"
