#!/bin/bash
# convert list of URLs to FQDNs
# Written by Tim H 2020
# pass in path to text file as only parameter. Outputs directly to stdout
awk -F/ '{print $3}' "$1" | sort --unique
