#!/bin/bash
# Tim H 2022
# beeps on local system (even over SSH) when Rapid7 InsightVM/nexpose scan 
# engine finishes installing content updates

tail -n0  -f /opt/rapid7/nexpose/nse/logs/update.log | \
    grep --line-buffered "Overall update status" | echo -en "\007"
