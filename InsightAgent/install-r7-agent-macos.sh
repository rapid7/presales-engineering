#!/bin/bash
# Tim H 2023

# R7 agent installer for Mac OS
# References:
#   https://docs.rapid7.com/insight-agent/using-a-token#install-on-mac-and-linux

# Agent URL last updated Nov 10, 2023
# Intel 
INSTALLER_URL="https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/1697643903/darwin/x86_64/agent_control_1697643903_x64.sh"

# Apple M1/M2 chip (ARM)
INSTALLER_URL="https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/1697643903/darwin/arm64/agent_control_1697643903_arm64.sh"

# Agent token for personal homelab
R7_AGENT_TOKEN="us:e11b79d9-1111-1111-1111-54526a1775f7"

INSTALLER_FILENAME="agent_control_x64.sh"

# download the Rapid7 agent installer for OSX (.sh)
curl --output "$INSTALLER_FILENAME" "$INSTALLER_URL"

# mark it as executable
chmod u+x "$INSTALLER_FILENAME"

# run the installer, pair it to the proper org using the token
sudo "./$INSTALLER_FILENAME" install_start --token "$R7_AGENT_TOKEN"
