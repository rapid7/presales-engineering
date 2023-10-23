#!/bin/bash
# Tim H 2022
# migrates an existing Ubuntu Linux system to a new IPIMS customer/org
# uninstalls existing R7 agent and then installs new one
# https://docs.rapid7.com/insight-agent/agent-controls#linux

# bail if any issues
set -e

# URL was made on Oct 3 2022
# You should get the latest URL otherwise it'll install an old version of the
# agent.
rapid7_agent_installer_url="https://s3.amazonaws.com/com.rapid7.razor.public/endpoint/agent/1663181909/linux/x86_64/agent_control_1663181909_x64.sh"

# the token for the NEW Org
rapid7_agent_token="us:e11b79d9-1111-1111-1111-54526a1775f7"

# Org ID for the NEW Org that you want systems to belong to:
rapid7_org_id="cda11779-2222-2222-2222-769be4bde392"

# delete any previous config files to avoid problems during next install.
cd "$HOME" || exit 1
rm -Rf token_handler cafile.pem client.crt client.key config.json \
    agent_installer.sh logging.json agent-*.tar.gz

# download the installer
wget -O agent_installer.sh "$rapid7_agent_installer_url"
chmod u+x agent_installer.sh

# automated uninstall, don't need to stop the service first; uninstaller 
# stops it
sudo ./agent_installer.sh uninstall

# delete the old directory to avoid reusing the same GUID and reporting to 
# the old org
sudo rm -Rf /opt/rapid7/ir_agent

# install the new version
sudo ./agent_installer.sh install_start --token "$rapid7_agent_token"

# list version number and Client GUID:
sudo cat /opt/rapid7/ir_agent/components/insight_agent/common/agent.log | \
    grep "Agent Info" | tail -1l

# list agent GUID:
# sudo find /opt/rapid7/ir_agent -type f -exec grep --with-filename --colour=yes -I Client-ID {} \; | sort --unique

# wait for a bit for the agent to initialize, some files won't exist for a few minutes
# it really does take 2 minutes to get that org ID into the config file
sleep 120

if [[ ! -f "/opt/rapid7/ir_agent/components/insight_agent/common/config/agent.jobs.tem_realtime.json" ]]; then
    echo "config file doesn't exist. exiting."
    exit 1
fi

registered_orgid=$(jq --raw-output \
    '."file_upload_complete_msgs"."agent.jobs.linux.remote_execution".msg.key' \
    /opt/rapid7/ir_agent/components/insight_agent/common/config/agent.jobs.tem_realtime.json | \
    cut -d '/' -f1)

if [[ "$registered_orgid" == "$rapid7_org_id" ]]; then
    echo "org IDs match. no problems."
else
    echo "ORG IDs do NOT match. Exiting"
    exit 2
fi

# check for errors
sudo zgrep -i error \
    /opt/rapid7/ir_agent/components/insight_agent/common/agent.log*

