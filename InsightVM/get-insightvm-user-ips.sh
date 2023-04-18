#!/bin/bash
# Tim H 2021
# Some examples on searching InsightVM/Nexpose's logs
# These examples are focused on users logging into the web interface
#   not the scan engines authenticating into endpoints
# Designed for troubleshooting authentication issues or grabbing the history of authentication
#   for a particular user

# searching for particular usernames
grep -i "first.lastname" /opt/rapid7/nexpose/nsc/logs/*

# example log lines showing a successful authentication. First line shows
# successful auth, second line shows the session ID generated 
# /opt/rapid7/nexpose/nsc/logs/auth.log:2021-03-18T16:29:32 [INFO] [Thread: http-nio-443-exec-5=/data/user/login] [Principal: test123456] Authentication attempt succeeded.
# /opt/rapid7/nexpose/nsc/logs/auth.log:2021-03-18T16:29:32 [INFO] [Thread: http-nio-443-exec-5=/data/user/login] [Principal: "test123456"] [Session ID: 031D4671C882A83A70D75DAAA910A00E15AAB5CFF5C1BBA0FC5A0D471F97EF8E] [Total sessions for principal: 1] Session created.

# search the logs for successful web interface authentications
zgrep -i "Authentication attempt succeeded" /opt/rapid7/nexpose/nsc/logs/*

# search the logs for a particular session ID
zgrep "031D4671C882A83A70D75DAAA910A00E15AAB5CFF5C1BBA0FC5A0D471F97EF8E" /opt/rapid7/nexpose/nsc/logs/*

# search the logs for a particular session ID and paticular source IP addresses
zgrep "031D4671C882A83A70D75DAAA910A00E15AAB5CFF5C1BBA0FC5A0D471F97EF8E" /opt/rapid7/nexpose/nsc/logs/* | grep "IP-address-here"

# get session IDs
grep "Session created" /opt/rapid7/nexpose/nsc/logs/auth.log 
grep "Session created" /opt/rapid7/nexpose/nsc/logs/auth.log | cut --delimiter=":" -f5-6 | cut --delimter=""
grep "Session created" /opt/rapid7/nexpose/nsc/logs/auth.log | grep -e "\[(.*?)\]"
grep "Session created" /opt/rapid7/nexpose/nsc/logs/auth.log | grep -Po '(^|[ ,])Principal:\K[^,]*'

# zgrep is important to catch historical stuff from yesterday and before
zgrep -i "username_here" /opt/rapid7/nexpose/nsc/logs/*
grep -i  "username_here" /opt/rapid7/nexpose/nsc/logs/*

# search for IP addresses associated with a particular session ID
zgrep SESSION_ID_HERE /opt/rapid7/nexpose/nsc/logs/* | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort --unique
zgrep 5B1F2349E20AB7B056D163B71D0C9DAC1BB913C5F879AC08CD926BE3D54E9C55 /opt/rapid7/nexpose/nsc/logs/*  | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort --unique
