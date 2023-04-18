#!/bin/bash
# Tim H 2021
#
#   Script for detailed network troubleshooting for pairing the Rapid7 InsightVM console to the Rapid7 Insight Platform
#   This script will perform a variety of network tests such as DNS, telnet, and certificate checking via openssl
#
#   You should absolutely run the GUI based diagnostics first before using this script:
#       https://docs.rapid7.com/insightvm/troubleshooting/#running-diagnostics
#   This script should be only used in the VERY RARE instance where the GUI diagnostics are all green, but there are still networking issues.

# References:
#   https://docs.rapid7.com/insightvm/configure-communications-with-the-insight-platform/
#   https://docs.pingidentity.com/bundle/solution-guides/page/iqs1569423823079.html

# check basic internet connectivity
nslookup google.com
ping 8.8.8.8
sudo apt-get update

# install dependencies for commands used in this script
# Assumes Ubuntu 18.04
#sudo apt-get install curl dnsutils net-tools netcat nmap tcpdump tcpflow telnet traceroute     # additional ones that you might use for more troubleshooting beyond this script
sudo apt-get install -y curl dnsutils net-tools netcat telnet

# test basic visit to google.com using curl
curl https://www.google.com

# Loop to iterate through all the required FQDNs of the Insight Platform with InsightVM in your AWS region:

# All US regions
#for R7_FQDN_ITER in exposure-analytics.insight.rapid7.com data.insight.rapid7.com s3.amazonaws.com us2.exposure-analytics.insight.rapid7.com us2.data.insight.rapid7.com s3.us-east-2.amazonaws.com us3.exposure-analytics.insight.rapid7.com us3.data.insight.rapid7.com s3.us-west-2.amazonaws.com

# Just US region 1 in N. Virginia
for R7_FQDN_ITER in exposure-analytics.insight.rapid7.com data.insight.rapid7.com s3.amazonaws.com
do
    echo "
==============================================================================
Testing connectivity to $R7_FQDN_ITER ..."
    nslookup "$R7_FQDN_ITER"        # check DNS resolution
    nc -z "$R7_FQDN_ITER" 443       # check layer 4 connectivity, make sure an outbound firewall isn't blocking IVM console from initiating communication over TCP 443
    #echo "Q" | openssl s_client -connect "$R7_FQDN_ITER":443 -showcerts
    echo "SSL certificate information:"
    echo "Q" | openssl s_client -connect "$R7_FQDN_ITER":443 -showcerts 2>&1 | grep -E "^subject|^issuer"   # display the SSL certificate information, used for detecting any SSL proxies that might screw up communication
done

echo "script finished successfully."

#echo "Q" | openssl s_client -connect exposure-analytics.insight.rapid7.com:443
