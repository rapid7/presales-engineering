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
