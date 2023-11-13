#!/bin/bash
# Install script for Rapid7 agent via JAMF
# Steps to follow:
#  1) Create a JAMF Configuration profile (.mobileconfig) for Full Disk Access
#     see "JAMF_Rapid7_agent_Full_Disk_Access_Configuration_Profile.mobileconfig"
#     for an example.
#     Log into JAMF, Click Computers → Configuration Profiles → Upload
#     Upload the following configuration profile.
#     You can rename the profile to suit your needs. 
#     Scope to all macOS Devices.
#
#  2) Rapid7 Agent Deployment
#     Someone with Platform Admin should login to the Rapid7 Insight Platform 
#     and visit the Data Collection > Agents page
#     Download *both* the ARM and Intel Rapid7 Agent installers
#     https://insight.rapid7.com/platform#/datacollection/
#
#  3) Create a folder in /private/var/tmp and name it r7agent 
#     (can be named to your standards). 
#       Drag both installers into this directory
#       Open Jamf Composer and drag the r7agent folder into composer
#       Select tmp folder and click on the 3 dots icons and select 
#       Apply Permissions tmp and All Enclosed Items
#       Select Build as PKG and save to the directory of your choice
#
#   4)  Create Deployment Script - Creating Install Script
#       Inside JAMF - Click Settings → Computer Management→ Scripts
#       Select New from the right hand corner
#       Copy and Paste the following code below into the script contents 
#       (remember to change any install paths) and click Save
#
#   5)  Create Jamf Policy
            # Display Name	        R7 Agent Universal (can be whatever)
            # Category	            Security (can be whatever)
            # Package	            Rapid7 Agent - Universal
            # Trigger	            can be set to whatever workflow you need.
            # Execution Frequency	Once Per Computer
            # Script	            Rapid7 Agent Universal Installer
            # Maintenance	        Update Inventory
            # Scope	                Specific Computer & Specific Users + Deploy to macOS Devices

# set the $TERM variable to determine the current terminal
export TERM=xterm-256color
 
# Path to where the installers live
cd /private/var/tmp/r7agent
 
# Determine if device is Intel or Apple Silicon
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    chmod u+x agent_installer-arm64.sh
    ./agent_installer-arm64.sh reinstall_start --token REPLACEME
 elif [ "$arch" == "i386" ]; then
    chmod u+x agent_installer-x86_64.sh
    ./agent_installer-x86_64.sh reinstall_start --token REPLACEME
 else
    echo "Unknown Architecture"
fi
