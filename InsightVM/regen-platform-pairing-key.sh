#!/bin/bash
# Tim H 2021
#
# Manually creating a new one time use GUID for pairing an InsightVM console to the Platform


# get a new GUID, good for one use only
curl https://exposure-analytics.insight.rapid7.com/ea/ipims/re-pairing/permission

#now login to InsightVM on the PLATFORM, then paste this new URL in to visit the pairing page. Can only do this one.
#https://exposure-analytics.insight.rapid7.com/ea/ipims/re-pairing/page?permission=NEW_GUID

# now visit the InsightVM console and pair it using this key
