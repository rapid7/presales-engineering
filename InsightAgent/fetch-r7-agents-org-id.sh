#!/bin/bash
# Tim H 2022

# fetches the ORG ID for a Rapid7 Insight Agent

jq --raw-output \
    '."file_upload_complete_msgs"."agent.jobs.linux.remote_execution".msg.key' \
    /opt/rapid7/ir_agent/components/insight_agent/common/config/agent.jobs.tem_realtime.json | \
    cut -d '/' -f1
