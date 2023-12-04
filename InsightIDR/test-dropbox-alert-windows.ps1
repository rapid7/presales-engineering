# Dropbox test on Windows

# view if Rapid7 agent is running - must be run in Powershell:
Get-Service -Name ir_agent

# view the current timestamp on the Workstation/server:
# date

# this DNS lookup should trigger an Alert in InsightIDR
# visit the Alerts tab in InsightIDR
nslookup content.dropboxapi.com
