#!/bin/bash
# Tim H 2021
#   Summary:
#       This script is designed to help test InsightIDR's ability to detect spearphishing
#       campaigns via DNS collection.
#
#   Pre-requisites:
#       1) Have a DNS event source added that logs all DNS traffic from the endpoints used in testing.
#       2) Enable the Spearphishing Alert in the Settings page (change it from Disabled to Alert). This is not enabled by default
#       3) Add rapid7.com in the Tagged Domains section in the settings menu.
#
#   Instructions for use:
#       1) open SSH sessions to 3 different Linux servers
#       2) paste this script into each SSH session
#       3) wait ~5 min to see InsightIDR alert.
#
#   Windows equivalent in powershell:
#       nslookup rapld7.com     (paste this 3 times in 3 different Windows servers)
# 
# References:
#   * https://docs.rapid7.com/insightidr/alerts/#built-in-alerts
#   * https://linuxhint.com/bash_loop_list_strings/

# number of times to do a DNS lookup on each example domain
NUMBER_OF_REPETITIONS="3"

# optional but recommened - verify if the Rapid7 insight agent is installed and running
#service ir_agent status

# optional - verify if this system is joined to a domain. optional.
#realm list

# verify that the clock on this system isn't too far off
#date

# see which DNS server this Linux system uses. Make sure this DNS server is sending logs to InsightIDR
cat /etc/resolv.conf

# Declare an array of strings that is the list of fake phishing domains to use
declare -a LookAlikeDomainsList=("g00gle.com" "rapld7.com" "googie.com" "gooogle.com" )
 
# Iterate through each domain to look up
for ITER_DOMAIN in ${LookAlikeDomainsList[@]}; do

    # call a DNS lookup (3) number of times to trigger the Alert in InsightIDR
    for iter in $(seq 1 $NUMBER_OF_REPETITIONS); do
        nslookup "$ITER_DOMAIN"
        sleep 0.5   # wait half a second between requests to avoid overloading DNS server
    done
done
