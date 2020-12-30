#!/bin/bash
# Tim H 2020
# Finds interesting lines in logs- useful for troubleshooting InsightAppSec logs and extracting clues

echo "This is a series of notes, not designed to be executed directly"
exit 1

LOG_FILES_FULL_PATH="$HOME/Downloads/logfiles"



grep -i " error " "$LOG_FILES_FULL_PATH/operation_00000.log" 
grep -n -i " error: " "$LOG_FILES_FULL_PATH/operation_00000.log" | grep -v "Could not execute event in the"

egrep "(?:[4-5]|\d{2,})\b Response" "$LOG_FILES_FULL_PATH/operation_00000.log" 
egrep "(?:[4-5]|\d{2,})\b Response" "$LOG_FILES_FULL_PATH/operation_00000.log" | cut -d " " -f2- | sort --unique
grep "401 Response" "operation_00000.log" | cut -d ":" -f5- | sort --unique




grep "HTTP/1.1 401" --before-context=10 --after-context=20 -m 1 traffic_*.log
grep "HTTP/1.1 401" -H --line-number -C 10 --max-count=1 traffic_*.log


grep "GET /api/" traffic_*.log | sort --unique

grep "/api/goals" -H --line-number -C 10 traffic_*.log


grep "HTTP/1.1 401" -H --line-number -C 10 traffic_*.log

#Grep for "Response Code: 401" in the trafficemetadata file
#/api/goals



grep -i "\[warn\]" 	"$LOG_FILES_FULL_PATH/operation_00000.log" 
grep -i "\[error\]" 	"$LOG_FILES_FULL_PATH/operation_00000.log" 

grep -i "seconds" 	"$LOG_FILES_FULL_PATH/operation_00000.log" 

grep "GET /api/goals" -H --line-number traffic_*.log
grep "GET /api/goals" -C 40 traffic_*.log


grep "Response Time: "		"$LOG_FILES_FULL_PATH/trafficmetadata_00000.log" | cut --delimiter="\ " -f2

head -n 500 "$LOG_FILES_FULL_PATH/trafficmetadata_00000.log" | grep "Response Time: " | cut -d ' ' -f3 | cut -d "m" -f1 > tempfile.txt

grep "Response Time: " "$LOG_FILES_FULL_PATH/trafficmetadata_00000.log" | cut -d ' ' -f3 | cut -d "m" -f1 > tempfile.txt

# sift through operation log for unique URLs that are problematic
# noisy, needs work:
grep -i " seconds - " "*.log" | cut -d " " -f8 | sort --unique

grep "Sender: " trafficmetadata_00000.log | sort --unique
grep "Operation: " trafficmetadata_00000.log | sort --unique

