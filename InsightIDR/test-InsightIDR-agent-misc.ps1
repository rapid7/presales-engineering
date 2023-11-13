# Script works best if Run As Administrator
# This script is designed to trigger some alerts in InsightIDR on Windows

# List installed PowerShell repositories: https://docs.microsoft.com/en-us/powershell/module/powershellget/get-psrepository?view=powershell-7.2
Get-PSRepository

# See current versions of PowerShell installed
Get-Module -Name PowerShellGet -ListAvailable | Select-Object -Property Name,Version,Path

# Install some dependencies
# the -Scope CurrentUser can prevent admin permissions
Install-Module -Name PowerShellGet -RequiredVersion 1.6.5 -Force -Scope CurrentUser -AllowClobber
Install-Module -Name PowerShellGet -MinimumVersion  2.2.5 -Force -Scope CurrentUser -AllowClobber

# Install the Active Directory module, dependency for other stuff:
# https://www.varonis.com/blog/powershell-active-directory-module
Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online
Install-WindowsFeature -Name "RSAT-AD-PowerShell" -IncludeAllSubFeature
Get-Module -Name ActiveDirectory -ListAvailable
Import-Module -Name ActiveDirectory

# Test to make sure dependencies are installed, should list domain controllers
Get-ADDomainController

Get-ADDomainController -Discover -Service "GlobalCatalog"

# get some info about local system for debugging
net localgroup
net user
whoami /priv

# must be admin:
# try dumping some sections of the Windows Registry, some more sensitive and should trigger alerts
reg save HKLM\Software\Google reg-save-test1-google.hiv
reg save HKLM\SAM reg-save-test2-SAM.hiv

# TODO: add more things that should trigger detections:
# Dump userlist from AD via LDAP query
# Get list of DCs via LDAP query
# Computer object enum via LDAP query (desktop)

# Other tools:
#   https://github.com/SecureAuthCorp/impacket/blob/master/examples/ntlmrelayx.py
#   https://github.com/fox-it/BloodHound.py
