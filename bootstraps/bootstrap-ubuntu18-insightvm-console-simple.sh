#!/bin/bash
# Tim H 2021

NEW_FQDN="cdawg.aws.butters.me"
NEW_TIMEZONE="America/New_York"

# set the new hostname
echo "$NEW_FQDN" > /etc/hostname
hostname "$NEW_FQDN"

# set the time zone
timedatectl set-timezone "$NEW_TIMEZONE"

# sync the time, make sure it is accurate
ntpdate pool.ntp.org

# disable the firewall
ufw disable

# install all potentially necessary software for troubleshooting
# not installing Java/JDK/JRE
apt-get update
apt-get install -y apt-file apt-transport-https arping autoconf automake ca-certificates curl dnsutils gcc gnupg-agent grep libtool lsof make mlocate net-tools netcat nmap npm ntpdate openssh-server openssl python3-pip screen software-properties-common sysstat tar tcpdump tcpflow telnet traceroute unzip vim wget
# install any outstanding updates
apt-get upgrade -y

# Download the InsightVM installer
wget https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin \
     http://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.sha512sum

# check the integrity of the IVM installer delete it if it doesn't match
sha512sum --check Rapid7Setup-Linux64.bin.sha512sum || rm -f Rapid7Setup-Linux64.bin

# mark it as executable
chmod 500 ./*.bin

# reboot to apply firewall, hostname changes and kernel updates
reboot now

# after rebooting:
./Rapid7Setup-Linux64.bin -q -overwrite  \
    -Vfirstname='NAME' \
    -Vlastname='NAME' \
    -Vcompany='COMPANY' \
    -Vusername='nxadmin' \
    -Vpassword1='nxpassword' \
    -Vpassword2='nxpassword'

# it didn't start on its own, have to start manually
service nexposeconsole start

# wait until the console has finished loading and then beep
( tail -f -n0 /opt/rapid7/nexpose/nsc/logs/nsc.log & ) | grep -q "Security Console started" && echo -en "\007"

# scan engine roughly finishes loading when this log line appears in  /opt/rapid7/nexpose/nse/logs/nse.log
#2021-03-16T21:16:28 [INFO] [Thread: Scan Engine] Starting NSEManager
#2021-03-16T21:16:39 [INFO] [Thread: Scan Engine] Scan Engine initialization completed.
#Security Console web interface ready
#nsc.log 2021-03-16T23:16:00 [INFO] [Thread: Security Console] [Started: 2021-03-16T23:06:52] [Duration: 0:09:08.631] Security Console started.

# login and disable your javascript blocker
# now go get a license file , don't forget to add extra engines!
# change the port to 443
# have to restart the service for port change to take effect

service nexposeconsole restart
( tail -f -n0 /opt/rapid7/nexpose/nsc/logs/nsc.log & ) | grep -q "Security Console started" && echo -en "\007"

# scan engine:
systemctl start nexposeengine.service
( tail -f -n0 /opt/rapid7/nexpose/nse/logs/nse.log & ) | grep -q "Scan Engine initialization completed" && echo -en "\007"
