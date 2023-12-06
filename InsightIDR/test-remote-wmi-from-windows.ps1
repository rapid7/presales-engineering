# Testing WMI connections from Windows using Powershell
# This *cannot* be done from Linux, even with Powershell for Linux.

# Check this site first for GUI solutions:
# https://docs.rapid7.com/insightidr/active-directory-ad-domain-controller-event-source/

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential?view=powershell-7.2
# https://docs.microsoft.com/en-us/windows/win32/wmisdk/connecting-to-wmi-on-a-remote-computer-by-using-powershell
# https://blogs.msdn.microsoft.com/powershell/2012/08/24/introduction-to-cim-cmdlets/

# see what version of Powershell is installed:
$PSVersionTable

# check the path:
$env:PSModulePath

# List available modules:
Get-module -ListAvailable

# Import module:
Import-Module CimCmdlets

# list WMI namespaces, no auth required:
Get-CimInstance -ComputerName "dc02.int.butters.me" -Namespace root -ClassName __Namespace

$remote_creds=$host.ui.PromptForCredential("Enter credentials", "Please enter your user name and password. Include the DOMAIN\username", "", "NetBiosUserName")

# Get-WmiObject is deprecated but still works:
# this will scroll for a LONG time. Can Ctrl+C to break out of it.
# scrolling a lot means it is working
Get-WmiObject -Namespace "root\cimv2" -Class Win32_Process -Impersonation 3 -Credential $remote_creds -ComputerName "dc02.int.butters.me"

# more basic test of connection using Cim instead of Wmi command
New-CimSession -ComputerName "dc02.int.butters.me" -Credential $remote_creds
