#!/bin/bash
# Tim H 2020
# Network troubleshooting for InsightVM scan engine pairing to console
# Replace 10.0.1.37 with the IP of your InsightVM/Nexpose console
# Note that this is for REVERSE pairing - pairing the scan engine to the console
# which takes place over TCP 40815, NOT 40814.
#
# The following comamnds should be run from the InsightVM scan engine that is
#   having trouble connecting to the InsightVM console.

# use nmap to see if the port is open
nmap -Pn -p40815 10.0.1.37

# verify basic port connectivity, insure it doesn't immediately time out after opening
telnet 10.0.1.37 40815

# check the SSL cert served - it should be a self signed cert with
#subject=/CN=Rapid7 Security Console/O=Rapid7
#issuer=/CN=Rapid7 Security Console/O=Rapid7
# If not then you've got an SSL proxy interfering
openssl s_client -connect 10.0.1.37:40815

# comparing timing to see if there is a proxy
# if the nmap is much faster (like hundreds of times faster) than the ping, then you've probably got a transparent proxy
ping 10.0.1.37
#versus
nmap -sT 10.0.1.37 -p 40815
