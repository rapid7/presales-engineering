# Powershell
# Tim H 2021

# References:
#   https://docs.rapid7.com/insight-agent/agent-connection-diagnostics
#   https://docs.rapid7.com/insight-agent/agent-controls#windows

# see if the services is running first
Get-Service ir_agent

# could be different path for 32 bit systems, this is default for 64 bit systems:
cd "C:\Program Files\Rapid7\Insight Agent\components\insight_agent"
ls -lah

# change directories into the latest one. At the time of this writing it is 3.1.1.9:
cd 3.1.1.9

# run the diagnosis, tests connection DIRECTLY to Rapid7 Insight Platform, does not connect via Collectors
# adjust the region as needed
.\ir_agent.exe  -diagnose -region us-east-1

#run diagnostics, test connection via Rapid7 collector (as a proxy). Collector hosts a proxy on TCP 8037
.\ir_agent.exe  -diagnose -region us-east-1 -proxy https://COLLECTOR_HOSTNAME_OR_IP:8037
