#!/bin/bash
#	Tim H 2020,2022
#	This script will whitelist an InsightVM console when run from an InsightVM scan engine.
#   This script runs on the scan engine, not on the console. It is designed for console to engine pairing: 
#	as documented here: https://docs.rapid7.com/insightvm/configuring-distributed-scan-engines/#standard-pair-console-to-engine
# 	
#	Workflow:
#		1) Sign into the InsightVM console web interface and add a new scan engine by IP
#		2) ssh into the scan engine
#		3) run this script and provide the public IP of the InsightVM console that was attempting to pair to it.
#
#	Example usage:
#	./approve_scan_engine_ip.sh 1.2.3.4
#
#	Optional second parameter: path to the consoles.xml file (if it was not installed to the default location)
#	./approve_scan_engine_ip.sh 1.2.3.4 /mnt/insightvm/nexpose/nse/conf/consoles.xml
#
#
#	References:
#		https://raymii.org/s/snippets/Sending_commands_or_input_to_a_screen_session.html
#
set -e
SCAN_ENGINE_IP=$1
CONSOLES_FILE="${2:-/opt/rapid7/nexpose/nse/conf/consoles.xml}"

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 4
fi

# verify that user provided the public IP of the engine
if [ -z "${SCAN_ENGINE_IP}" ]; then 
	echo "IP not defined."
	exit 6
fi

# verify that consoles.xml file exists
if test -f "$CONSOLES_FILE" ; then
	echo "$CONSOLES_FILE exists"
else
	echo "Consoles file does not exist: $CONSOLES_FILE"
	exit 5
fi

# test if the scan engine's IP is in consoles.xml file
if grep "$SCAN_ENGINE_IP" "$CONSOLES_FILE" ; then
	echo "Found the IP in the consoles file."
	GREP_LINE=$(grep "$SCAN_ENGINE_IP" "$CONSOLES_FILE")
	CONSOLE_ENABLED=$(echo "$GREP_LINE" | cut -d\" -f4)
	CONSOLE_ID=$(echo "$GREP_LINE" | cut -d\" -f2)

	case $CONSOLE_ENABLED in

	  0)
	    echo "console was not enabled, enabling"
		screen -S nexposeconsole -p 0 -X stuff "enable console $CONSOLE_ID^M"
	    ;;

	  1)
	    echo "console was already enabled, exiting without taking any action"
	    exit 0
	    ;;

	  *)
	    echo "console in unknown state, exiting"
	    exit 2
	    ;;
	esac

else
	echo "Did not find IP in consoles file. Perhaps it is the wrong IP 
	or their firewall is blocking the scan engine from communicating with the console"
	exit 1
fi
