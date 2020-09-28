#!/bin/bash
#	Tim H 2020
#	unit test script for approve_scan_engines_ip.sh
#	Loops through a provided consoles.xml file and enables all the IPs.
#	
# 	Example usage: does not take any parameters
#		./test-approve_scan_engine_ip.sh

set -e

CONSOLES_FILE="example_consoles.xml"
IP_LIST=$(grep "console id" "$CONSOLES_FILE" | cut -d\" -f10)

for i in $IP_LIST
do
	echo "---------------------------------------------------------------"
	echo "IP being tested: $i"
	./approve_scan_engine_ip.sh "$i"
done
