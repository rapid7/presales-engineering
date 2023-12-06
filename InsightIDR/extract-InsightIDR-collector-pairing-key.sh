#!/bin/bash
# Tim H 2022
# extract the InsightIDR collector pairing key as plain text with no formatting
# can be done after installing the InsightIDR collector and starting the service for the first time.

# install dependencies in CentOS / RHEL
# sudo yum install libxml2

# install dependencies in Ubuntu:
# sudo apt-get install libxml2-utils

# use XML lint utility to extract the key via XPATH reference
# use the text() method to remove formatting
xmllint --html --xpath '//html/body/p/b/text()' /opt/rapid7/collector/agent-key/Agent_Key.html

