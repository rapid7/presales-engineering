#!/bin/bash
# Tim H 2022
# install and configure NXLog for CentOS 7
# add an adapter to recieve incoming Ubiquiti UniFi syslogs
# and convert them to JSON and forward them to a Rapid7 InsightIDR
# collector
#
# References:
#   https://docs.nxlog.co/userguide/integrate/unifi.html
#   https://docs.nxlog.co/userguide/deploy/rhel.html

# define the UDP port where the NX Log system should be listening
# this is the port where UniFi is sending the logs to.
# Unfortunately, UniFi syslog only supports sending UDP, not TCP
UDP_PORT_SYSLOG_UNIFI="7878"

# set the path to the latest version of the NX Log RPM file
# up to date as of 5/5/22
RPM_URL="https://nxlog.co/system/files/products/files/348/nxlog-ce-3.0.2272-1_rhel7.x86_64.rpm"

# install the PGP public key for NXLog
rpm --import https://gitlab.com/nxlog-public/contrib/-/raw/master/PGP-public-key/nxlog-pubkey.asc?inline=false

# install dependency
yum install -y epel-release

# download the RPM installer
wget --quiet --output-document=nxlog-ce.rpm "$RPM_URL"

# install NXLog community edition
yum install -y nxlog-ce.rpm

# verify service is running
service nxlog status

# check config file syntax
/usr/bin/nxlog -v

# stop and disable the firewall to simplify testing
service firewalld stop
chkconfig firewalld off

cp /etc/nxlog/nxlog.conf /etc/nxlog/nxlog.conf.original

cat << EOF > /etc/nxlog/nxlog.conf
<Extension _syslog>
    Module  xm_syslog
</Extension>

<Extension _json>
    Module  xm_json
</Extension>

<Input incoming_unifi_syslog_over_udp>
    Module  im_udp
    Host    0.0.0.0
    Port    $UDP_PORT_SYSLOG_UNIFI
    Exec    parse_syslog();
</Input>

<Output outgoing_idr_collector_as_json_over_udp>
    Module  om_udp
    Host    10.0.1.40
    Port    7879
    Exec    to_json();
</Output>

<Route r>
    Path    incoming_unifi_syslog_over_udp => outgoing_idr_collector_as_json_over_udp
</Route>
EOF

# display the file, make sure it's correct
cat "/etc/nxlog/nxlog.conf"

# check config file syntax
/usr/bin/nxlog -v

# restart service to apply changes to config file
service nxlog restart

# see if server is listening on UDP port where traffic from UniFi should be
# coming:
# gotta wait a sec for service to finish starting up, otherwise
# it won't be listed
sleep 1
ss -tulwn  | grep "$UDP_PORT_SYSLOG_UNIFI"

# watch incoming traffic on the port to verify incoming syslog
tcpdump -i ens192 udp port "$UDP_PORT_SYSLOG_UNIFI" -X

# now you have to BE PATIENT AND WAIT
# it could take 5-10 min before you see the first logs in the Log Search
# in IDR
