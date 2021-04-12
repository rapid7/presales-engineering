#!/bin/bash
# Tim H 2021
# 
# References:
#   * https://docs.rapid7.com/insightidr/alerts/#built-in-alerts
#   * https://linuxhint.com/bash_loop_list_strings/

NUMBER_OF_REPETITIONS="3"

# check to see if 
service ir_agent status
realm list
cat /etc/resolv.conf

date

# Declare an array of string with type
declare -a LookAlikeDomainsList=("g00gle.com" "rapld7.com" "googie.com" "gooogle.com" )
 
# Iterate the string array using for loop
for ITER_DOMAIN in ${LookAlikeDomainsList[@]}; do
    for iter in $(seq 1 $NUMBER_OF_REPETITIONS); do
        nslookup "$ITER_DOMAIN"
        sleep 0.5
    done
done
