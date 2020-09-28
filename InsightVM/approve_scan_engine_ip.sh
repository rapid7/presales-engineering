#!/bin/bash
#
#	This script will enable a remote scan engine on an IVM console based off its public IP
#	Designed to be used on R7 hosted shared scan engines to simplify process of approving
#	prospect's POC consoles
# 	
#	Example usage:
#	./approve_scan_engine_ip.sh 1.2.3.4
#
#	Optional second parameter: path to the consoles.xml file (if it was not installed to the default location)
#	./approve_scan_engine_ip.sh 1.2.3.4 /mnt/insightvm/nexpose/nse/conf/consoles.xml
#
#	TODO: add feedback or verify that it is enabled after sending command
#
#	References:
#		https://raymii.org/s/snippets/Sending_commands_or_input_to_a_screen_session.html
#		https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
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
