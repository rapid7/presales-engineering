#!/bin/bash
# Tim H 2021
# Disable database consistency checks to speed up InsightVM console service start-up time
# This is a very bad idea for production systems and you should only do this if 
# instructed to by R7 support. Seriously.
# You shouldn't need to be rebooting the InsightVM console frequently.
#
# A single test on clean OVA with NO data, no updates, never activated - not super realistic production scenario:
#	* Host specs: ESXi 7 on HPE ProLiant DL380 Gen10 with 8 x 1TB drives in RAID10,  Intel(R) Xeon(R) Silver 4108 CPU @ 1.80GHz 
#	* VM specs: 2 vCPU with 16 GB RAM
#	* very first boot of IVM OVA: 31 minutes
#	* second boot, with no changes (no activation, no pairing): 26 min
#	* disabled database consistency on third boot: 17 minutes

echo "com.rapid7.nexpose.nsc.dbcc=0" | sudo tee --append /opt/rapid7/nexpose/nsc/CustomEnvironment.properties

# restart the service in CentOS 7:
sudo systemctl restart nexposeconsole
