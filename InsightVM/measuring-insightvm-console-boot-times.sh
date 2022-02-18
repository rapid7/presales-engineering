#!/bin/bash
# Tim H 2020

# this is a series of notes, not to be run directly
# This script lists a variety of commands for measuring the start-up time for the InsightVM
# console.




grep  -i "Console initialization completed" /opt/rapid7/nexpose/nsc/logs/*

grep  -i "initialization completed" /opt/rapid7/nexpose/nsc/logs/*

grep  -i "initializ" /opt/rapid7/nexpose/nsc/logs/*


# /opt/rapid7/nexpose/nsc/logs/nsc.log:2021-07-15T13:15:13 [INFO] [Thread: Security Console] Initializing console...

grep  -i "finish\|complete" /opt/rapid7/nexpose/nsc/logs/*

grep  -i "Recovery complete" /opt/rapid7/nexpose/nsc/logs/*


grep -a40 -i "System scheduler started." /opt/rapid7/nexpose/nsc/logs/*

# Best way, although it may show multiple "JVM Started" on a single boot.
zgrep "JVM started\|Security Console web interface ready." /opt/rapid7/nexpose/nsc/logs/nsc*

# looking for timestamps for start/finish of Database consistency checks
grep  -i "consistency" /opt/rapid7/nexpose/nsc/logs/*

grep   "] Logging initialized. " /opt/rapid7/nexpose/nsc/logs/*

# waiting for it to be ready:
tail -f /opt/rapid7/nexpose/nsc/logs/nsc.log | grep "Security Console web interface ready"


# Measuring scan engine startup time, not console
# while grep -q "Scan Engine initialization completed" /opt/rapid7/nexpose/nse/logs/nse.log > /dev/null;
# grep "Scan Engine initialization completed"  /opt/rapid7/nexpose/nse/logs/nse.log
# 2020-09-29T02:59:25 [INFO] [Thread: main]       ---- FIRST LINE in log file
# 2020-09-29T03:02:26 [INFO] [Thread: Scan Engine] Scan Engine initialization completed.
# it took 3 minutes for the m2.large to finish starting the scan engine service
