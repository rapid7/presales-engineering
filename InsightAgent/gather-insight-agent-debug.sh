#!/bin/bash
##############################################################################
# Tim H 2020
# Description: creates a compressed file containing all Insight agent related logs and settings
#   It also sets the ownership and permissions so it is easier to SCP off to
#   another system.
#   This ZIP file may be too large to email, depending on log size.
#
##############################################################################

# define location for output file:
ZIP_PATH="$HOME/rapid7-insight-agent_logs-$(date +%F).tar.gz"

# compress all the agent files
sudo tar -czf "$ZIP_PATH" /opt/rapid7/ir_agent/components/insight_agent/common/

# set permissions
sudo chmod +r "$ZIP_PATH"
sudo chown "$USER" "$ZIP_PATH"

ls -lah "$ZIP_PATH"
echo "ZIP file is located at: $ZIP_PATH"
