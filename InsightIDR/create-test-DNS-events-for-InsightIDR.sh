#!/bin/bash
# Tim H 2020
#
# Description: this script will test InsightIDR DNS logs by generating
#    easily found DNS entries in Rapid7 InsightIDR.
# Used in POCs by prospects that want to confirm the DNS logging is working

# the IP address (or FQDN) of your local DNS server that is sending logs to InsightIDR
DNS_SERVER="10.0.1.11"

# the Top Level Domain (anything unique) to use; you'll use this in the Log Search to 
# confirm the findings
TARGET_TLD="rickrolled.com"

# number of DNS requests to send
NUMBER_OF_TESTS=1000

# min and max number of seconds to wait (at random) between requests
MIN_RANDOM_TIME_SEC=0
MAX_RANDOM_TIME_SEC=30


################################################################################
#	TEMPLATE & DEFINITIONS
################################################################################
# immediately exit if any errors occur
set -e

THIS_SCRIPT_NAME=$(basename "$0")                 # can't use the --suffix since it isn't supported in OS X like it is in Linux
LOGFILE="$HOME/history-$THIS_SCRIPT_NAME.log"         # filename of file that this script will log to. Keeps history between runs.
export THIS_SCRIPT_NAME
export LOGFILE

# shellcheck source=../.env
source ../.env
# shellcheck source=../common-functions.sh
source ../common-functions.sh

# output to the log file instead of the screen
setup_logging

################################################################################
#		MAIN PROGRAM
################################################################################
# start a log so I know it ran
log "========= START ============="

COUNTER_FILE="$HOME/.dnstest-counter.dat"

# if we don't have a file, start at zero
if [ ! -f "$COUNTER_FILE" ] ; then
  DNS_TEST_NUMBER=2
# otherwise read the value from the file
else
  DNS_TEST_NUMBER=$(cat "$COUNTER_FILE")
fi

# increment the value
DNS_TEST_NUMBER=$(( DNS_TEST_NUMBER + 1))

# and save it for next time
echo "${DNS_TEST_NUMBER}" > "$COUNTER_FILE"

# create a new and unique FQDN
TARGET_SUB_DOMAIN="test-$DNS_TEST_NUMBER.$TARGET_TLD"

RUNTIME_MIN=$(echo "($MIN_RANDOM_TIME_SEC + $MAX_RANDOM_TIME_SEC) / 2 * $NUMBER_OF_TESTS / 60" | bc)
RUNTIME_HOURS=$(echo "(1.0 * $RUNTIME_MIN) / 60.0" | bc)

# log some debug info before starting
log "
==============================================
starting DNS test at $(date)
DNS SERVER:          $DNS_SERVER
TARGET SUBDOMAIN:    $TARGET_SUB_DOMAIN
NUMBER OF TESTS:     $NUMBER_OF_TESTS
MIN RANDOM TIME:     $MIN_RANDOM_TIME_SEC SECONDS
MAX RANDOM TIME:     $MAX_RANDOM_TIME_SEC SECONDS
APPROX TEST RUNTIME: $RUNTIME_MIN      MINUTES or $RUNTIME_HOURS   HOURS

"

# loop through the designated number of tests
for (( c=1; c<=NUMBER_OF_TESTS; c++ ))
do
    # do the lookup on the DNS server but don't wait for the response
    nslookup "$c.$TARGET_SUB_DOMAIN" "$DNS_SERVER" &
    
    # sleep a random amount of time
    sleep "$(shuf -i $MIN_RANDOM_TIME_SEC-$MAX_RANDOM_TIME_SEC -n 1)"
done

log "==== SCRIPT ENDED SUCCESSFULLY ====="
