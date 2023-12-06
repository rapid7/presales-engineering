# NEEDS_WORK_BEFORE_PUBLIC_RELEASE
# Powershell to download and install the Rapid7 insight agent on Windows

# must change directory first, since an admin window will be in system32
cd $HOME

# This link was grabbed on 1/26/2022 (v3.1.3.78), you should get the latest one from your browser
# This is for the 64-bit version
curl.exe -L -o agentInstaller-x86_64.msi https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/1642528482/windows/x86_64/PyForensicsAgent-x64.msi

curl.exe -L -o Sigcheck.zip https://download.sysinternals.com/files/Sigcheck.zip

msiexec /i agentInstaller-x86_64.msi /l*v insight_agent_install_log.log /quiet CUSTOMTOKEN=us:REDACTED

# sleep here for a bit to allow the service to start
Start-Sleep -Seconds 30

# display the status, verify it installed
Get-Service ir_agent
