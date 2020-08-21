#!/bin/bash
# convert ZAP and IAS crawl maps and diff them, outputs a file named "diff.txt"
# written by Tim H 2020

ZAP_CRAWL_MAP_INPUT="./ZAP_comparison/ZAP_results/ZAP-webscantest-unauth-crawlmap.txt"
IAS_CRAWL_MAP_INPUT="./ZAP_comparison/InsightAppSec _results/WebScanTest - InsightAppSec crawl map.json"

################################################################################
#		FUNCTION DEFINITIONS
################################################################################
cleanup () {
	# prepares a crawl map in plain text format for diffing
	# removes the following from a set of strings and returns to stdout
	#	http:// or https://
	#	leading and trailing whitespace
	#	parameters in URLs - anything after a ? including the ?
	#	trailing forward slashes (/)
	#	duplicates
	#	differences in encoding and line endings
	iconv options -f ISO-8859-1 -t UTF-8//TRANSLIT -i "$1" | sed 's/^ *//;s/ *$//;s/  */ /;' | tr -d '\15\32' | sed 's~http[s]*://~~g' | sed 's/?.*//' | sed 's/^ *//;s/ *$//;s/  */ /;' | sed -e 's#/$##' | sort --unique
}

################################################################################
# going through the ZAP output
################################################################################
ZAP_CRAWL_MAP_OUTPUT="$ZAP_CRAWL_MAP_INPUT-output.txt"

cleanup "$ZAP_CRAWL_MAP_INPUT" > "$ZAP_CRAWL_MAP_OUTPUT"


################################################################################
# going through the IAS output
################################################################################
IAS_CRAWL_MAP_TMP="$IAS_CRAWL_MAP_INPUT.tmp"
IAS_CRAWL_MAP_OUTPUT="$IAS_CRAWL_MAP_INPUT-output.txt"

# strip out the URLs from the JSON format before handing it off to the cleanup
grep "url\": " "$IAS_CRAWL_MAP_INPUT" | sed 's/^ *//g' | cut -d \" -f4 > "$IAS_CRAWL_MAP_TMP"
cleanup "$IAS_CRAWL_MAP_TMP" > "$IAS_CRAWL_MAP_OUTPUT"


################################################################################
# final comparison
################################################################################
diff --ignore-all-space --strip-trailing-cr --text --suppress-common-lines  --side-by-side "$ZAP_CRAWL_MAP_OUTPUT" "$IAS_CRAWL_MAP_OUTPUT" > diff.txt
