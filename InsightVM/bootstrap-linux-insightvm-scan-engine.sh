#!/bin/bash
# Tim H 2020
# This script installs an InsightVM scan engine, but does not pair it. It waits for pairing but doesn't take action.
# Note that the installer for the InsightVM/Nexpose console is the same as the scan engine. The only difference is
#   the supplied inputs. Normally the installer uses interactive prompts, but this script bypasses those with 
#   command line parameters.
#
#  Requirements:
#       * running as sudo or root
#       * running on supported Linux distro for InsightVM: https://www.rapid7.com/products/insightvm/system-requirements/
#       * wget is installed. You could also rewrite this using Curl if needed.

# exit if anything fails, do not continue
set -e

LOGFILE="/root/bootstrap.log"

# redirect all output to a logfile
rm -f "$LOGFILE"	# clear the log if it already exists
exec >> "$LOGFILE"
exec 2>&1


################################################################################
#		FUNCTION DEFINITIONS
################################################################################

log () {
	# formatted log output including timestamp
	echo -e "[bootstrap] $(date)\t $@"
}

################################################################################
#		MAIN
################################################################################
log "Starting bootstrap script..."

if [ ! $(whoami) == "root" ]; then
    echo "This script must be run as root, aborting. Current user: $USER"
    exit 1
fi

# install dependencies for CentOS and Ubuntu/Debian
if test -f "/etc/centos-release" ; then
	yum install -y screen wget coreutils
else
	apt-get update
    apt-get install -y screen wget
fi

log "Dependencies test passed."

# disable the firewall
service iptables stop   && chkconfig iptables off

# Download the installer for both InsightVM and Nexpose (same) and hashsum file
# This makes sure you're getting the latest installer
wget --quiet https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin \
		http://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.sha512sum

log "Downloaded IVM installer."

# Check the integrity of the download
sha512sum --check Rapid7Setup-Linux64.bin.sha512sum

# Mark installer as executable
chmod u+x Rapid7Setup-Linux64.bin

log "Starting installation."

# Install and start engine, unpaired to anything
./Rapid7Setup-Linux64.bin -q -overwrite \
    -Vfirstname='FirstName' \
    -Vlastname='LastName' \
    -Vcompany='Rapid7' \
    -Vsys.component.typical\$Boolean=false \
    -Vsys.component.engine\$Boolean=true \
    -VinitService\$Boolean=true \
    -VcommunicationDirectionChoice\$Integer=1



# Install the InsightVM scan engine and specify the InsightVM console and shared secret to pair with:
# this will automatically start the service too
# define variables for deployment
#console="example.company.com"
#secret="A1A1-B2B2-C3C3-D4D4-E5E5-F6F6-G7G7-H8H8"
#./Rapid7Setup-Linux64.bin -q -overwrite -Vfirstname='FirstName' -Vlastname='LastName' \
#    -Vcompany='Rapid7' -Vusername='nxadmin' -Vpassword1='nxadmin' -Vpassword2='nxadmin' \
#    -Vsys.component.typical\$Boolean=false -Vsys.component.engine\$Boolean=true \
#    -VinitService\$Boolean=true \
#    -VcommunicationDirectionChoice\$Integer=0 \
#    -VconsoleAddress="$console" -VconsoleDetailPort='40815' -VsharedSecret="$secret"

log "Finished installation, waiting for service to start..."

# wait for service to start, can't immediately check the status of the service after install
sleep 15

# check the status
#service nexposeengine status

log "Service has started, waiting for it to finish starting"

#while grep -q "Scan Engine initialization completed" /opt/rapid7/nexpose/nse/logs/nse.log > /dev/null;
#do
#    log "Waiting on scan engine service to finish loading..."
#    sleep 15
#done

sleep 240

# check free RAM after service finishes loading
free -m

log "Scan engine service has finished loading"

#grep "Scan Engine initialization completed"  /opt/rapid7/nexpose/nse/logs/nse.log
#2020-09-29T02:59:25 [INFO] [Thread: main]       ---- FIRST LINE in log file
#2020-09-29T03:02:26 [INFO] [Thread: Scan Engine] Scan Engine initialization completed.
# it took 3 minutes for the m2.large to finsh starting the scan engine service

log "Waiting for console to initiate pairing..."

while grep "enabled" /opt/rapid7/nexpose/nse/conf/consoles.xml > /dev/null;
do
    log "Waiting on console to initate pairing..."
    sleep 5
done

log "Console has initiated pairing."

#TODO enable console

log "End of bootstrap script."
