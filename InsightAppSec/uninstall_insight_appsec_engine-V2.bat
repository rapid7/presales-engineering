echo off
color F0
cls
REM #!# This is version 2 and adds a deletion of the Sheriff license key from the registry
REM #!# TODO: add check to see if running with admin permissions, bail if not
echo.
echo ##################################################################
echo # We are going to delete the existing Insight AppSec Scan Engine!
echo ##################################################################
set inst_dir=C:\Program Files\Rapid7\InsightAppSec\
echo.
set /p inst_dir=Enter the install directory if not [%inst_dir%]:
set _ok=
set /p _ok=Do you really want to DELETE these files? (Y/N) :
if /I NOT "%_ok%" == "Y" EXIT
set _nop=
set _ok=
set /p _ok=Remove prompt to delete folders? (Y/N) :
if /I "%_ok%" == "Y" set _nop=/Q
echo Stopping related services
sc stop "AppSpider REST Server"
sc stop "AppSpider REST Service"
sc stop "InsightAppSec-Broker"
sc stop "ScanEngSvc"
timeout /t 10 /nobreak
copy "%inst_dir%\broker\conf\restclient-platform.cfg" %HOMEDRIVE%%HOMEPATH%\desktop\
RMDIR /S %_nop% "%inst_dir%"
RMDIR /S %_nop% "C:\ProgramData\InsightAppSec"
RMDIR /S %_nop% "C:\AppSpiderRestService"
for /d %%c in (%tmp%\*) do rmdir /s /q "%%c"
for %%c in (%tmp%\*) do del /q "%%c"
sc delete "AppSpider REST Server"
sc delete "AppSpider REST Service"
sc delete "InsightAppSec-Broker"
sc delete "ScanEngSvc"
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Rapid 7\AppSpider" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Rapid 7\AppSpider 7" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Rapid 7\InsightAppSec" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Acudata" /f
echo Insight AppSec has been removed......
echo.
echo ##################################################################
echo #  The file restclient-platform.cfg was copied to the desktop.
echo #  Find the previous AppSec engine API key in this file and use that value when installing the Insight AppSec engine.
echo #  Then, go scan and discover.  So Say We All.
echo ##################################################################
echo .
echo ##################################################################
echo # REBOOT THIS SYSTEM BEFORE INSTALLING THE INSIGHTAPPSEC SCAN ENGINE
echo ##################################################################



pause
