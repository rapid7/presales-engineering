#!/bin/bash
# Tim H 2022
# SENSITIVE
# R7 agent installer for OS X/Mac OS
# Designed to be run as a Shell Script in Microsoft InTune/MDM
# Intentionally does not use the $HOME env variable since it isn't defined
# when run as MDM script.
# https://endpoint.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMacOsMenu/~/shellScripts
# Uses cURL, doesn't require any special dependencies or pre-reqs to be 
# installed.
#
# References:
#   https://docs.rapid7.com/insight-agent/using-a-token#install-on-mac-and-linux

# bail immediately on any errors
set -e

# Agent URL last updated Oct 8 2022, for Intel processors, not M1
INSTALLER_URL="https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/1663181909/darwin/x86_64/agent_control_1663181909_x64.sh"

# Agent token for personal homelab
R7_AGENT_TOKEN="us:e11b79d9-1111-1111-1111-54526a1775f7"

# root user's home directory path in OS X
ROOT_USER_HOME="/var/root"
FULL_LOG_FILE_PATH="$ROOT_USER_HOME/r7-agent-install.log"
AGENT_INSTALL_PROOF="$ROOT_USER_HOME/r7-agent-upgraded"
INSTALLER_FILENAME="agent_control_x64.sh"

if [[ -f "$AGENT_INSTALL_PROOF" ]]; then
    echo "[$(date)] This script has already run, no need to run again." >> "$FULL_LOG_FILE_PATH"
    exit 0
fi

# using /var/root manually since this script requires sudo or root powers
# and will not have $HOME defined in some circumstances
cd "$ROOT_USER_HOME" || exit 2

# delete any previous config files to avoid problems during next install.
rm -Rf token_handler cafile.pem client.crt client.key config.json \
    "$INSTALLER_FILENAME" logging.json agent-*.tar.gz

# download the Rapid7 agent installer for OSX (.sh)
curl --output "$INSTALLER_FILENAME" "$INSTALLER_URL"

# mark it as executable
chmod u+x "$INSTALLER_FILENAME"

# check if the agent is already installed
if [ -d "/opt/rapid7/ir_agent" ]; then
    echo "[$(date)] Agent already installed, uninstalling..." >> "$FULL_LOG_FILE_PATH"
    # automated uninstall, don't need to stop the service first; 
    # uninstaller stops it
    sudo ./"$INSTALLER_FILENAME" uninstall

    # delete the old directory to avoid reusing the same GUID and 
    # reporting to the old org
    sudo rm -Rf /opt/rapid7/ir_agent
fi

# run the installer, pair it to the proper org using the token
sudo "./$INSTALLER_FILENAME" install_start --token "$R7_AGENT_TOKEN"

echo "$R7_AGENT_TOKEN" > "$AGENT_INSTALL_PROOF" 

# log some debug info
echo "[$(date)] R7 agent installed successfully." >> "$FULL_LOG_FILE_PATH"

echo "[$(date)] R7 agent install script finished successfully." >> "$FULL_LOG_FILE_PATH"
