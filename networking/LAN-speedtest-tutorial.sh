#!/bin/bash
# Tim H 2020
# LAN Speed Test
# iperf3 needs to be installed on TWO systems on the network
# This guide assumes RHEL or CentOS, but is mostly the same for other distros.
# Install on OS X with brew: "brew install iperf3"
# References:
#   https://www.tecmint.com/test-network-throughput-in-linux/

echo "This script is a tutorial and not intended to be executed directly. Exiting"
exit 1

##############################################################################
# Server side:
##############################################################################
# apt-get install iperf3 # Ubuntu/Debian
yum install -y iperf3

iperf3 -s -f m -p 5201      # listen on TCP 5201 (the default port) and report in megabits per second


##############################################################################
# Client side:
##############################################################################
# Install in CentOS/RHEL
yum install -y iperf3

# basic test
iperf3 -c 10.0.1.37 -f m    # report in megabits per second

# bi-directional test, full duplex
iperf3 -c 10.0.1.37 -f m -d

# multiple streams (2), less efficent
iperf3 -c 10.0.1.37 -f m -w 500K -P 2
