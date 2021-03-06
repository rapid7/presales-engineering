#!/bin/bash
#   Tim H 2020
# Generates a crawl map based off Rapid7 InsightAppSec logs ZIP files
# TODO: rename varables, I'm even confusing myself.

# takes a single parameter: a path to a ZIP file of logs you downloaded from IAS
# Yeah, the script is ghetto but it works.
# Run two different scans on a site, then diff the crawl maps to see what parts of the site it missed/found
# example usage:
#   ./create_crawl_maps.sh downloaded_file.zip
# outputs to a new text file adjacent to original ZIP file.

LOG_ZIP_FILE_FULL_PATH=$1

# TODO: add if directory exists to avoid errors
#ORIG_DIR=$(pwd)
PATH_TO_LOGS=$(dirname "$LOG_ZIP_FILE_FULL_PATH")
ZIP_BASE_NAME=$(basename "$LOG_ZIP_FILE_FULL_PATH")
EXTRACT_PATH="$PATH_TO_LOGS/$ZIP_BASE_NAME-extract"
OUTPUT_FILE1="output1.txt"
OUTPUT_FILE2="output2.txt"
OUTPUT_FILE3="$PATH_TO_LOGS/$ZIP_BASE_NAME-crawl_map_v3.txt"

rm -Rf "$EXTRACT_PATH"
rm -f "$OUTPUT_FILE2"
rm -f "$OUTPUT_FILE3"

# bail if anything throws errors
set -e

# extract the ZIP file
unzip -q -o "$LOG_ZIP_FILE_FULL_PATH" -d "$EXTRACT_PATH"

cd "$EXTRACT_PATH/logfiles"

# filter down to just the response code and URLs, then remove the phrases URL and Response code to just have URLs and codes. Store in temp file
#GET / HTTP/1.1
#HTTP/1.1 200 OK
# seeing HTTP/1.1 201 Created. that is screwing up my grep
#grep "^GET " traffic_00000.log | cut -d" " -f2 | cut -d"?" -f1 | sort --unique
#grep "^GET\|^POST\|^PUT\|^DELETE\|^HEAD\|^TRACE\|^OPTIONS\|^CONNECT\|^PATCH" traffic_00000.log | cut -d"?" -f1 | sort --unique
#grep --no-filename "^GET\|^POST\|^PUT\|^DELETE\|^HEAD\|^TRACE\|^OPTIONS\|^CONNECT\|^PATCH" traffic_*.log | cut -d"?" -f1 | sort --unique 
#grep --no-filename "^GET\|^POST\|^PUT\|^DELETE\|^HEAD\|^TRACE\|^OPTIONS\|^CONNECT\|^PATCH" traffic_*.log | cut -d"?" -f1 | cut -d" " -f2 | sort --unique | wc -l
# seems like crawl only uses get and post, no others
# attack uses all of them but muddles the result URLs

#grep --no-filename "HTTP/1.1 \|GET \\" traffic_*.log | sed 's/HTTP\/1.1 //g' | sed 's/Response Code: //' > "$OUTPUT_FILE1"

# extract just the GET pages and response codes
grep --no-filename "HTTP\/1.1 \|GET \/" traffic_*.log | sed 's/HTTP\/1.1//' | sed 's/Response Code: //' > "$OUTPUT_FILE1"

# filter down to just the URLs that replied with 2xx codes
while read -r ONE; do
    read -r TWO
    #If the response code starts with a 2 (2xx's) then consider it part of the crawl map
    if [[ $TWO == 2* ]] ; 
	then
		echo "$ONE" >> "$OUTPUT_FILE2"
	fi
done < "$OUTPUT_FILE1"

# remove anything after a ?
# remove duplicates, including whitespace and invisible characters
cut -d"?" -f1 "$OUTPUT_FILE2" | sort --unique -b -i > "$OUTPUT_FILE3"
#echo "$PATH_TO_LOGS/$ZIP_BASE_NAME-crawl_map.txt    about to delete: $EXTRACT_PATH"

#cd "$ORIG_DIR"
#rm "$OUTPUT_FILE2" "$OUTPUT_FILE1"
#rm -Rf "$EXTRACT_PATH"
echo "File output to: $OUTPUT_FILE3"

echo "create_crawl_maps.sh ended successfully."
