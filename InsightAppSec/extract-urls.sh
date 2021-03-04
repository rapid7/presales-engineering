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

## Other things I tried that didn't work as well:
#DIR="$HOME/Documents/no_backup/url_extraction"
#regex="https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)"
#regex="(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})"
#awk -F/ '{print $3}' "$DIR/*" | sort --unique
#cd "$DIR"
#egrep "$regex" "$1"
#grep --text -Eo '(http|https)://[^/"]+' *
#strings * | grep  --text -Eo '(http|https)://[^/"]+'

# best working expression:
strings "$@" | grep  --text -Eo '(http|https)://[^/"]+' | sort --unique
