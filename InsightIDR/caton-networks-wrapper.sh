#!/bin/bash
# Tim H 2021
#
# Wrapper for catonetworksSyslogClient.sh to forward to InsightIDR collector
# Encryption could be added, but is not supported at this time by this script

# Setup in catonetworksSyslogClient.sh
# 1) update the API_KEY on line 4 to the API key provided by Cato Networks, save the file
# 2) move the catonetworksSyslogClient.sh file to be in the same directory as this script

# Setup in InsightIDR
# 1) Click on Data Collection tab on left
# 2) Click on Custom Logs
# 3) Name the event source - something human friendly like "Caton Networks SD-WAN Logs 1"
# 4) Click on Listen on Network Port
# 5) Pick an unused high port, and a protocol: ex: port 2000 UDP
# 6) Save the event source and wait 1-2 min so the collector will start listening. If you have a firewall on the collector, make sure it is open on that port/protocol

# define the settings used above in InsightIDR setup
INSIGHT_IDR_COLLECTOR_IP="10.0.1.40"
INSIGHT_IDR_COLLECTOR_PORT="2000"
INSIGHT_IDR_COLLECTOR_PROTOCOL="udp"    # either tcp or udp, case sensitive

# mark the script as executable in case it isn't
chmod u+x ./catonetworksSyslogClient.sh

# call the script and redirect all of its output to the collector over the network.
# goes for infinite loop, no error watching in case it fails
./catonetworksSyslogClient.sh > "/dev/$INSIGHT_IDR_COLLECTOR_PROTOCOL/$INSIGHT_IDR_COLLECTOR_IP/$INSIGHT_IDR_COLLECTOR_PORT"
