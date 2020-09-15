#!/bin/bash
# crontab for Sunday nights at 11pm, run as root
#0 23 * * 7 /root/upgrade-divvy.sh

# bomb out if any errors occur
set -e

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd /divvycloud/
docker-compose down
docker-compose pull
docker-compose up -d
