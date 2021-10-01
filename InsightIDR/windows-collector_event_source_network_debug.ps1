# Tim H 2021

# Designed to be run on Windows servers running the Rapid7 InsightIDR collector

# in this example the collector should be listening on TCP port 6514

#https://docs.microsoft.com/en-us/powershell/module/nettcpip/get-nettcpconnection?view=windowsserver2019-ps
# Show list of connections to this TCP port
Get-NetTCPConnection -LocalPort 6514

# Check the local firewall rules list to see if there are any rules about the port in question
# https://docs.microsoft.com/en-us/powershell/module/netsecurity/get-netfirewallportfilter?view=windowsserver2019-ps
Get-NetFirewallPortFilter | Where-Object -Property LocalPort -EQ 6514

# view ALL network connections
netstat -f -o -p TCP -q 
