# Uninstalls existing R7 agent on Windows, deletes directories, installs new
# agent
# 64 bit only

# stop the R7 agent service:
sc ir_agent stop

# uninstall it:
# https://redmondmag.com/articles/2019/08/27/powershell-to-uninstall-an-application.aspx
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Rapid7 Insight Agent"}
$MyApp.Uninstall()

# mark the directory as writeable in case NTFS ACLs prevent deletion
# required since sometimes it doesn't delete these directories
$sharepath =  "C:\Program Files\Rapid7\Insight Agent\"
$Acl = Get-ACL $SharePath
$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("everyone","FullControl","ContainerInherit,Objectinherit","none","Allow")
$Acl.AddAccessRule($AccessRule)
Set-Acl $SharePath $Acl

# delete the directory if it remains
# this works fine for Windows Server, but not on Win10 for some reason
Remove-Item -Recurse -Force "C:\Program Files\Rapid7\Insight Agent\"

# define the agent download URL for Windows 64bit
Set-Variable -Name "URL" -Value "https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/1663181909/windows/x86_64/PyForensicsAgent-x64.msi"

# Download the agent
cd $HOME\Downloads
rm .\agentInstaller-x86_64.msi .\ir_agent .\insight_agent_install_log.log
Invoke-WebRequest -URI $URL -OutFile agentInstaller-x86_64.msi

# Install it quietly
msiexec /i agentInstaller-x86_64.msi /l*v insight_agent_install_log.log /quiet CUSTOMTOKEN=us:e11b79d9-1111-1111-1111-54526a1775f7

# verify it is installed:
Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Rapid7 Insight Agent"}

# list the agent version
cd "C:\Program Files\Rapid7\Insight Agent\"
.\ir_agent.exe --version

# verify the agent service is running
Get-Service "ir_agent"
