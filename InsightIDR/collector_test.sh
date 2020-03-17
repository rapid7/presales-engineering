#!/bin/bash
##
#	Script that sends both TCP and UDP traffic to a test collector
#	Example usage of send_collector_test_data.sh script
#
#	Listen command on the collector for TCP: tcpflow -c  -i ens33 port 6667
./send_collector_test_data.sh 172.16.1.137 TCP 6667 1000 &

#	Listen command on the collector for UDP: tcpdump -i ens33 udp port 6666 -X
./send_collector_test_data.sh 172.16.1.137 UDP 6666 1000

# sent 1000 messages over 10.7333 minutes = 93.1 events per minute
