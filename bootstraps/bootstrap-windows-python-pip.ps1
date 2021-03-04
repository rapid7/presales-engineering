cd $HOME
Set-ExecutionPolicy -Scope CurrentUser
RemoteSigned
Get-ExecutionPolicy -List

$script = New-Object Net.WebClient
$script.DownloadString("https://chocolatey.org/install.ps1")

iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
refreshenv
choco upgrade chocolatey

choco install -y python3
refreshenv
# have to exit and reopen Powershell, don't need admin though
python -V
python -m pip install --upgrade pip --user
