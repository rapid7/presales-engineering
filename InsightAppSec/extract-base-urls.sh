#!/bin/bash
#   Tim H 2021
# extracts HTTP and HTTPS URLs from text and binary files, sorts and deduplicates them
# outputs to screen
#
# example usage:
#   ./extract-urls.sh file.html
#   ./extract-urls.sh installer.sh file.bin *.html output.xml

# bomb out if any errors occur
set -e

# prereqs
yum install -qy binutils

# extracts strings from binaries first, in case it is a binary file
# greps for HTTP and HTTPs strings
# sorts alphabetically and deduplicates things
strings "$@" | grep --text -Eo '(http|https)://[^/"]+' | sort --unique
