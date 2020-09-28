#!/bin/bash
#   Tim H 2020
# convert list of URLs to FQDNs, deduplicates list.
# pass in path to text file as only parameter. Outputs directly to stdout
# designed for generating list of FQDNs to whitelist as targets in InsightAppSec
#
# example usage:
#   ./convert_urls_to_fqdns.sh list_of_urls.txt

awk -F/ '{print $3}' "$1" | sort --unique
