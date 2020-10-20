#!/bin/bash
##############################################################################
# Tim H 2020
# Description: creates a compressed file containing all InsightVM related logs
#   It also sets the ownership and permissions so it is easier to SCP off to
#   another system.
#   This ZIP file may be too large to email, depending on log size.
#
# References:
#   InsightVM log file explanations: https://docs.rapid7.com/insightvm/troubleshooting/#locating-each-log-file-and-understanding-its-purpose
##############################################################################

ZIP_PATH="$HOME/rapid7-insightvm-console-ALL_logs-$(date +%F).tar.gz"
sudo tar -czf "$ZIP_PATH" /opt/rapid7/nexpose/nsc/logs
sudo chmod +r "$ZIP_PATH"
sudo chown "$USER" "$ZIP_PATH"
ls -lah "$ZIP_PATH"
echo "ZIP file is located at: $ZIP_PATH"
