# Tim H 2020
# Powershell script for programatically downloading and installing the InsightAppSec scan engine
# requires an API key
# This is a NOT WORKING script at this time, need to determine the format of the varfile the installer is expecting.

#APIKEY="redacted"

# Change directory to the Downloads folder
cd ~/Downloads

# Download the latest version of the InsightAppSec scan engine
curl.exe -L -o R7-insightAppSecEngine-Setup-x64-US-latest.exe https://us.appsec.insight.rapid7.com/downloads/engine-installer
 
# create the answers/input file
New-Item ./InsightAppSec-Install-Answers.txt
Set-Content ./InsightAppSec-Install-Answers.txt 'format needs to be determined
APIKEY=123456
INSTALLPATH=C:\RAPID7\WHATEVER'
 
# run the install command with the supplied file
.\R7-insightAppSecEngine-Setup-x64-US-latest.exe -q -varfile "$answersfile"

# TODO: verify the service has started
