#!/bin/bash
#	Tim H 2020
#   This script has a series of different bash commands to assist in troubleshooting
#   dynamic discovery connections to cloud providers like Azure and AWS
#   Log descriptions: https://docs.rapid7.com/insightvm/troubleshooting/#locating-each-log-file-and-understanding-its-purpose

echo "this script is a troubleshooting guide, not intended to be executed directly"
exit 1

# search for things that aren't INFO
grep -v "[INFO]" eso.log
grep -v "[INFO]" nsc.log

# search for warnings and errors
grep "\[WARN\]" "*.log"
grep "\[ERROR\]" "*.log"

# general Azure search
grep -i "azure" "*.log" | cut -d " " -f2- | sort --unique
grep "Azure-Proxy-Discovery-Service" eso.log | cut -d " " -f2- | sort --unique

# searching for sync activity
grep " activity log events found in subscription" eso.log | grep -v " 0 activity"
grep "resource groups found" :"*.log"
grep "activity log events found in subscription" "*.log"
grep "virtual machines found in" "*.log"
