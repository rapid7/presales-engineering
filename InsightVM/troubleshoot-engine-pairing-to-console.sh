#!/bin/bash
# Tim H 2020
# Network troubleshooting for InsightVM scan engine pairing to console
# Replace 10.0.1.37 with the IP of your InsightVM/Nexpose console
# Note that this is for REVERSE pairing - pairing the scan engine to the console
# which takes place over TCP 40815, NOT 40814.
#
# The following comamnds should be run from the InsightVM SCAN ENGINE that is
#   having trouble connecting to the InsightVM console.
#
# References:
#   https://docs.rapid7.com/insightvm/post-installation-engine-to-console-pairing/#reverse-pair-engine-to-console


echo "This script is a tutorial and not intended to be executed directly. Exiting"
exit 1

# use nmap to see if the port is open, scanning your InsightVM console on TCP 40815
# if you see anything besides open:
#       PORT      STATE SERVICE
#       40815/tcp open  unknown
# Then either the service isn't running on the InsightVM console or there is a firewall blocking access on outbound TCP 40815
nmap -Pn -p40815 10.0.1.37

# verify basic port connectivity, ensure it doesn't immediately time out after opening.
telnet 10.0.1.37 40815

# check the SSL cert served - it should be a self signed cert with the following:
#       subject=/CN=Rapid7 Security Console/O=Rapid7
#       issuer=/CN=Rapid7 Security Console/O=Rapid7
# If not then you've got an SSL proxy interfering. Whitelist the InsightVM's IP with your SSL proxy so it doesn't attempt to proxy the traffic.
openssl s_client -connect 10.0.1.37:40815

# Comparing timing to see if there is a (transparent) proxy
# If there is a substantial difference in timing then then you've probably got a transparent proxy
# beware that Rapid7 hosted consoles do not respond to ping.
ping 10.0.1.37
#versus
nmap -sT 10.0.1.37 -p 40815


# TODO: add Nexpose console commands for troubleshooting
add console 10.0.1.37
connect to console 1
add shared secret 1
#then enter the shared secret in the interactive prompt: 1234-5678-AABB-3978-794F-E1C6-E196-13D8
enable console 1
