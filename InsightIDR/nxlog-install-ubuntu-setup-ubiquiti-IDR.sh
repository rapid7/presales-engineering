#!/bin/bash
# Tim H 2022
# MOVE_TO_PRESALES_REPO
# install and configure NXLog for Ubuntu 20.04
# add an adapter to recieve incoming Ubiquiti UniFi syslogs
# and convert them to JSON and forward them to a Rapid7 InsightIDR
# collector
# References:
#   https://docs.nxlog.co/userguide/integrate/unifi.html
#   https://docs.nxlog.co/userguide/deploy/debian.html
#   https://docs.nxlog.co/userguide/deploy/signature-verification.html#deb
#   https://nxlog.co/products/all/download?field_pf_product_nid=348

# define the UDP port where the NX Log system should be listening
# this is the port where UniFi is sending the logs to.
# Unfortunately, UniFi syslog only supports sending UDP, not TCP
INCOMING_UDP_PORT_FROM_UNIFI_SYSLOG="7878"
IDR_COLLECTOR_IP="10.0.1.40"
IDR_COLLECTOR_LISTENING_PORT="7879"

# go run the install-nxlog-ubuntu.sh script to install it.
# next steps configure it.

cat << EOF > /etc/nxlog/nxlog.conf
LogFile /var/log/nxlog/nxlog.log
LogLevel INFO

<Extension _syslog>
    Module  xm_syslog
</Extension>

<Extension _json>
    Module  xm_json
</Extension>

<Input incoming_unifi_syslog_over_udp>
    Module  im_udp
    Host    0.0.0.0
    Port    $INCOMING_UDP_PORT_FROM_UNIFI_SYSLOG
    Exec    parse_syslog();
</Input>

<Output outgoing_idr_collector_as_json_over_udp>
    Module  om_udp
    Host    $IDR_COLLECTOR_IP
    Port    $IDR_COLLECTOR_LISTENING_PORT
    Exec    to_json();
</Output>

<Route r>
    Path    incoming_unifi_syslog_over_udp => outgoing_idr_collector_as_json_over_udp
</Route>
EOF

sudo mkdir /var/run/nxlog
sudo chown root:$(whoami) /etc/nxlog

# check config file syntax
sudo /usr/bin/nxlog -v

# stop and disable the firewall to simplify testing
service firewalld stop

# restart service to apply changes to config file
service nxlog restart

service nxlog status
cat /var/log/nxlog/nxlog.log

# see if server is listening on UDP port where traffic from UniFi should be
# coming:
# gotta wait a sec for service to finish starting up, otherwise
# it won't be listed
sleep 1
ss -tulwn  | grep "$INCOMING_UDP_PORT_FROM_UNIFI_SYSLOG"

# watch incoming traffic on the port to verify incoming syslog
tcpdump -i ens160 udp port "$IDR_COLLECTOR_LISTENING_PORT" -X

# now you have to BE PATIENT AND WAIT
# it could take 5-10 min before you see the first logs in the Log Search
# in IDR
