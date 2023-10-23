#!/bin/bash
# Tim H 2022
# The network sensor runs as a module within the agent (ir_agent)
# All of its directories come inside /opt/rapid7/ir_agent

# download the installer
# THIS LINK IS VERY SHORT LIVED, MUST BE NEW EVERY LIKE 15 MIN OR SO
cd "$HOME" || exit 1

# mark as executable
chmod u+x sensor_installer.sh

# uninstall the old network sensor AND agent
sudo ./sensor_installer.sh uninstall

# install the agent again and repair it to the console
sudo ./sensor_installer.sh install_start --token us:c9c8a6b3-1111-1111-1111-13d69716427a

# now login to web app and pick the SPAN port
