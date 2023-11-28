#!/bin/bash
#  Tim H 2020
#
# Description:
#   Script to upgrade DivvyCloud consoles since they can't do it on their own yet
#
# example crontab for Sunday nights at 11pm, run as root
#0 23 * * 7 /root/upgrade-divvy.sh

# bomb out if any errors occur
set -e

echo "Starting to upgrade Divvy containers. Divvy will be restarted."

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd "/divvycloud/" || exit 1
# stop the docker service
docker-compose down

# download the latest version of the containers
docker-compose pull

# restart the docker service
docker-compose up -d

echo "finished updating Divvy containers and restated them."
