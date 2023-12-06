#!/bin/bash
# Tim H 2021
# Diff 2 JSON crawl maps from InsightAppSec
#
# References:
#   https://medium.com/@lucasbru/comparison-of-json-files-9b8d2fc320ca

FILE_A="$1"
FILE_B="$2"

#FILE_A="Scan (03_15_21 2_17 PM)-crawl-map.json"
#FILE_B="Scan (03_15_21 4_19 PM)-crawl-map.json"

#validate JSON first:
jsonlint --quiet "$FILE_A" && echo successA
jsonlint --quiet "$FILE_B" && echo successB

# TODO: verify that the walk.filter file exists

cat "$FILE_A" | jq -S -f walk.filter > 1.json
cat "$FILE_B" | jq -S -f walk.filter > 2.json
diff 1.json 2.json
