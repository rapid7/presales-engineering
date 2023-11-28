# Test network connections from scan engine to console from Windows server
# Powershell

# Test layer 4 connectivity
Test-NetConnection -ComputerName "34.209.33.127" -port 40815

# a good result looks like this:
# ComputerName     : 34.209.33.127
# RemoteAddress    : 34.209.33.127
# RemotePort       : 40815
# InterfaceAlias   : Ethernet0
# SourceAddress    : 10.0.1.11
# TcpTestSucceeded : True

# Check for SSL proxy:
# try visiting this page in a web browser: http://whatismyip.network/detect-isp-proxy-tool/
# click Start Proxy Check to begin the test

# checking using command line: 
# install dependencies:
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name OpenSSL -AllowClobber


# Install Chocolatey - the Windows package manager:
# Open a Administrator Powershell window:
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


choco install openssl
