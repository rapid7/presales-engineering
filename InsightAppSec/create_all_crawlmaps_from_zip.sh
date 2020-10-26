#!/bin/bash
# Tim H 2020
# Deprecated due to new InsightAppSec GUI features
# Description:
#   generates a text based crawl map of all ZIP files in a directory
#   outputs to a series of text files adjacent to the original ZIP files
# Example usage:
#   ./create_all_crawlmaps_from_zip.sh "$HOME/Downloads/InsightAppSec_Downloads/"
set -e

ZIP_LOGFILE_DIRECTORY="$1"

# call the separate script on each ZIP file found
find "$ZIP_LOGFILE_DIRECTORY" -type f -iname '*.zip' -exec ./create_crawl_maps.sh {} \;
