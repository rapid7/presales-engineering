#!/bin/bash
set -e

ZIP_LOGFILE_DIRECTORY="$1"

find "$ZIP_LOGFILE_DIRECTORY" -type f -iname '*.zip' -exec ./create_crawl_maps.sh {} \;