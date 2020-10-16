#!/bin/bash
# Tim H 2020
# Finds interesting lines in logs- useful for troubleshooting InsightAppSec logs and extracting clues

echo "This is a series of notes, not designed to be executed directly"
exit 1

LOG_FILES_FULL_PATH=$1


grep -i " error " "$LOG_FILES_FULL_PATH/operation_00000.log" 
grep -i " error: " "$LOG_FILES_FULL_PATH/operation_00000.log" | grep -v "Could not execute event in the"

grep -i "\[warn\]" 	"$LOG_FILES_FULL_PATH/operation_00000.log" 
grep -i "\[error\]" 	"$LOG_FILES_FULL_PATH/operation_00000.log" 

grep -i "seconds" 	"$LOG_FILES_FULL_PATH/operation_00000.log" 

grep "Response Time: "		"$LOG_FILES_FULL_PATH/trafficmetadata_00000.log" | cut --delimiter="\ " -f2


head -n 500 "$LOG_FILES_FULL_PATH/trafficmetadata_00000.log" | grep "Response Time: " | cut -d ' ' -f3 | cut -d "m" -f1 > tempfile.txt

grep "Response Time: " "$LOG_FILES_FULL_PATH/trafficmetadata_00000.log" | cut -d ' ' -f3 | cut -d "m" -f1 > tempfile.txt

# sift through operation log for unique URLs that are problematic
# noisy, needs work:
grep -i " seconds - " *.log | cut -d " " -f8 | sort --unique


grep "Sender: " trafficmetadata_00000.log | sort --unique
grep "Operation: " trafficmetadata_00000.log | sort --unique

