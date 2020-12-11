#!/bin/bash
#	Tim H 2020
#   This script has a series of different Bash commands to assist in troubleshooting
#   dynamic discovery connections to cloud providers like Azure and AWS, and pairing to the Insight Platform
#   Log descriptions: https://docs.rapid7.com/insightvm/troubleshooting/#locating-each-log-file-and-understanding-its-purpose

echo "this script is a troubleshooting guide, not intended to be executed directly"
exit 1

# search for things that aren't INFO
grep -v "[INFO]" eso.log
grep -v "[INFO]" nsc.log

# search for warnings and errors
grep "\[WARN\]"  ./*.log
grep "\[ERROR\]" ./*.log

# general Azure search
grep -i "azure" ./*.log | cut -d " " -f2- | sort --unique
grep "Azure-Proxy-Discovery-Service" eso.log | cut -d " " -f2- | sort --unique

# searching for AWS/Azure sync activity
grep " activity log events found in subscription" eso.log | grep -v " 0 activity"
grep "resource groups found" ./*.log
grep "activity log events found in subscription" ./*.log
grep "virtual machines found in" ./*.log

# Insight Platform syncing issues, including +- 5 lines of context of each instance
grep -C5 -i -E "platform|pairing|exposure analytics" ./*.log
# can ignore "NdisImPlatform" "Local Engine Platform" "Console Platform" "OSGi platform" 
# look for "Pairing console with key" -- this is the start
#	"Starting registration with exposure analytics"
#	"Failed to pair console with pairing key"
#	"/data/ea/register/pairingKey"

grep --after-context=15 "Pairing console with key" nsc.log

grep --after-context=5 "/data/ea/register" nsc.log


#nsc.log:2020-10-19T14:40:43 [INFO] [Thread: http-nio-3780-exec-4=/data/ea/register/pairingKey] Starting registration with exposure analytics.
#628cbaf3-83a3-48a6-a49d-6618eceface2
#nsc.log:org.springframework.web.client.ResourceAccessException: I/O error on GET request for "null/ea/ipims/platform/orgId?key=628cbaf3-83a3-48a6-a49d-6618eceface2": null; nested exception is org.apache.http.client.ClientProtocolException

grep -C5 "O error on GET request for " ./*.log
# InsightVM console command (screen session) to restart the service and disconnect/unpair the from Insight Platform (Exposure Analytics)
#restart reset-cloud-config
