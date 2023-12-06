# Tim H 2020
# Windows Powershell script to clean up old logs on DNS server
# Often designed to be used with Rapid7 InsightIDR with Microsoft DNS event source
# MS DNS does not automatically clean up old logs, so that's why this script is necessary.
#
# Verified working on PowerShell in Windows Server 2019
# Don't use this in a directory with binaries, just to be safe; use it in a dedicated
# directory for only logs, not in the default logging directory that may have other binaries
#
# Best practice instuctions:
#   1) Add a NEW virtual hard disk to the DNS server virtual machine. Size: at least 60 GB, Format it as NTFS, mount as a new drive letter (in this examle it is E:\)
#   2) Create a new folder on the disk, ex: E:\dnslogs
#   3) follow the InsightIDR documentation about configuring logging and point it to this location. Set Log File Path & Filename to E:\dnslogs\dns.log
#   4) Set this script to run as a Scheduled Task weekly.

# References: 
#   https://techcommunity.microsoft.com/t5/itops-talk-blog/powershell-basics-how-to-delete-files-older-than-x-days/ba-p/1255317
#   https://docs.rapid7.com/insightidr/microsoft-dns#step-1-collect-dns-server-logs

# Assumes that Log File Path & Filename is set to E:\dnslogs\dns.log
#   If yours differs then you'll need to update those. You can change line 28 to adjust the number of days it will save.
# Script will also store a log of the filenames it has deleted over time as E:\deletedlog.txt
# This would have been one line in Linux bash: find $Folder -type f -iname '*.log' -mtime +7 -delete

$Folder = "E:\dnslogs"

#Delete files older than 6 days
Get-ChildItem $Folder -Force -Filter 'dns*.log' -ea 0 |
Where-Object {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-6)} |
ForEach-Object {
   $_ | Remove-Item -Force
   $_.FullName | Out-File E:\deletedlog.txt -Append
}
