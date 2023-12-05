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
