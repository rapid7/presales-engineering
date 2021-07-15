#!/bin/bash
# Tim H 2021
#
# Linux command line speed tests
# References:
#   https://linuxhint.com/linux_internet_speed_test_apps/

# Ubuntu using Fast.com (more reliable)
sudo apt install npm
sudo npm install --global fast-cli
fast

# Ubuntu using SpeedTest.net (not super reliable)
sudo apt-get install speedtest-cli
speedtest


#