#!/bin/bash
# Tim H 2020
# For InsightVM consoles experiencing rare database issues
#   will reboot the InsightVM console

# bomb out if any errors occur
set -e

THIS_SCRIPT_NAME=$(basename "$0")

echo "Starting $THIS_SCRIPT_NAME..."

# change the auth so we can su to the user
sed -i -e 's/md5/trust/g' /opt/rapid7/nexpose/nsc/nxpgsql/nxpdata/pg_hba.conf

# restart the postgres db
sudo -u nxpgsql /opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/pg_ctl -D /opt/rapid7/nexpose/nsc/nxpgsql/nxpdata reload

# verify that the service restarted
sudo -u nxpgsql /opt/rapid7/nexpose/nsc/nxpgsql/pgsql/bin/pg_ctl -D /opt/rapid7/nexpose/nsc/nxpgsql/nxpdata status

# restore the auth to the original method
sed -i -e 's/trust/md5/g' /opt/rapid7/nexpose/nsc/nxpgsql/nxpdata/pg_hba.conf

read -n 1 -s -r -p "$THIS_SCRIPT_NAME finished successfully, rebooting... Press any key to reboot"

# reboot the whole server, or just restart the nexpose console service
reboot
