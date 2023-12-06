#!/bin/bash
# Tim H 2020

# copy the logging.json file you created up to the target server
# that already has an Insight Agent installed and running on it
scp ~/logging.json server01.redacted.com:~

# copy the file to the place where the agent will look for it
sudo cp /home/username/logging.json \
    /opt/rapid7/ir_agent/components/insight_agent/common/config

# change the ownership of the file
sudo chown root:root /opt/rapid7/ir_agent/components/insight_agent/common/config

# restart the R7 agent service to apply the new config in logging.json
sudo service ir_agent restart

# launch an example R7 container and pair it
docker run -v /var/run/docker.sock:/var/run/docker.sock \
    --read-only --security-opt=no-new-privileges rapid7/r7insight_docker \
    -t ce4d8552-1111-1111-1111-53a281a789de -r us -j \
    -a host="$(uname -n)"

# change the permissions on the config file
sudo chown -R "$USER":$(id -gn "$USER") /root/.config
