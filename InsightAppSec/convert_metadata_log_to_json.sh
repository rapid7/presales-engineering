#!/bin/bash
# Tim H 2020
# Converts a trafficmetadata log file into JSON format

# TODO: strip the "ms" out of the response time 
#       using JSON since quotes and other things will break CSV      
#       should double check some of the injection attacks or strip them, they could break the JSON too


# ============= Request ===================
# Index: 11163
# Time: 2020/10/06,22:29:04
# Method: GET
# Host: https://redacted-hostname.azure.redacted.com
# IP Address: 1.2.3.123
# Port: 443
# URL: /api'/fake/List
# Failed: No
# Response Code: 405
# Response Time: 109ms
# Response Size: 227
# Sender: Attacker
# Operation: Module 'SQL Injection', Attack 'DBI02', AttackPoint: Parameter: 'Directory[0]', location 'Directory', link 'https://redacted-hostname.azure.redacted.com/api/redacted/List'
# Retry: 0
# Requests: 11163

METADATA_LOG_FILE="$1"

echo "starting script"

OUTPUT_JSON_FILE="$METADATA_LOG_FILE.json"

# delete the output file if it already exists, removed since using > intead of >> on first output to the file
#rm -f "$OUTPUT_JSON_FILE"

# bomb out if any errors occur
set -e

################################################################################
#		FUNCTION DEFINITIONS
################################################################################

# define a function that converts a single line of the metadatatraffic log to a key value pair for JSON
convert_line_to_json () {
	original_full_line="$@"

    # test if the input was blank, bail if so
    if [[ -z $original_full_line ]]; then
        echo "blank line, exiting"
        exit 2
    fi

    # extract the "key" the first part of the line up until the very first colon (:) but not including it
    key=$(echo "$original_full_line" | cut -d ':' -f1)

    # extract the "value" - everything after the first colon (:), and strip any leading whitespace
    value=$(echo "$original_full_line" | cut -d ':' -f2- | sed -e 's/^[[:space:]]*//')

    # output it for use in other place
    echo "\"$key\": \"$value\""
}


################################################################################
#		MAIN
################################################################################

# output a header for the top of the new JSON file. Overwrites any existing file and removes need for deleting it
echo "{
	\"Traffic\": [
" > "$OUTPUT_JSON_FILE"

# loop through every line of the file passed in
while IFS= read -r line
do

    # if starting new section output an indented {
    if [ "$line" = "============= Request ===================" ]; then
       # echo "header line"
        echo "   {" >> "$OUTPUT_JSON_FILE"
    elif [[ "$line" == Requests* ]]; then
        # if ending a section, output the last line and add a trailing } with a trailing comma
        echo "      $(convert_line_to_json $line)" >> "$OUTPUT_JSON_FILE"
        echo "   }," >> "$OUTPUT_JSON_FILE"
    else
        # regular line that isn't a header or footer
        echo "      $(convert_line_to_json $line)," >> "$OUTPUT_JSON_FILE"
    fi
done < "$METADATA_LOG_FILE"

# output some footer info at the very bottom of th JSON file
echo "
   ]
}" >> "$OUTPUT_JSON_FILE"

# TODO: have to manually clean up the final comma at the end of the file

#echo "validating JSON..."
#jsonlint "$OUTPUT_JSON_FILE"

echo "script finished successfully"
