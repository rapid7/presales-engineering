#!/bin/bash
# Tim H 2020
# Searches through logs to return the count of each Response status code
# For example: there were 37 instances of 2xx's and 128 instances of 4xx codes.

LOG_FILES_FULL_PATH=$1

set -e

if [ ! -d "$LOG_FILES_FULL_PATH" ] ; then
	echo "Directory does not exist. Exiting."
	exit 1
fi

for i in $(seq 1 6); do 
	# count the number of instances
	INSTANCE_CODE_COUNT=$(grep -c "Response Code: $i" "$LOG_FILES_FULL_PATH/trafficmetadata_00000.log")
	echo "Response code {$i}xx     $INSTANCE_CODE_COUNT instances found in log"
done

echo "script finished successfully."
