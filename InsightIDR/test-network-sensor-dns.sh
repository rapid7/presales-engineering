#!/bin/bash
# Tim H 2021
# Test the passive DNS collection from the Rapid7 Insight Network Sensor
#   Ensures that each test is ALWAYS unique, easily traced in IDR logs
#   for troubleshooting

TARGET_DNS_SERVER="10.0.1.11"
NUM_ITERATIONS="30"
SLEEP_TIME="5"

COUNTER_FILE="$HOME/.dns-test-counter.dat"

# if we don't have a file, start at zero
if [ ! -f "$COUNTER_FILE" ] ; then
    COUNTER_ITERATOR=0
# otherwise read the value from the file
else
    COUNTER_ITERATOR=$(cat "$COUNTER_FILE")
fi
# increment the value
COUNTER_ITERATOR=$(( COUNTER_ITERATOR + 1))
# and save it for next time
echo "${COUNTER_ITERATOR}" > "$COUNTER_FILE"

# get the domain-less hostname of the localhost
SHORT_HOSTNAME=$(hostname -s)
# DNS_FRIENDLY_TARGET=$(echo "$TARGET_DNS_SERVER" | sed  's/\./\-/g')
DNS_FRIENDLY_TARGET=${TARGET_DNS_SERVER//\./\-}

# build the 
FQDN_SUFFIX="dnstest-$COUNTER_ITERATOR-from-$SHORT_HOSTNAME-to-$DNS_FRIENDLY_TARGET.easysearch.whatever.com"

# TODO: hide output
for iter in $(seq 1 $NUM_ITERATIONS); do
    nslookup "$iter-of-$NUM_ITERATIONS.$FQDN_SUFFIX" "$TARGET_DNS_SERVER"
    sleep "$SLEEP_TIME"
done

