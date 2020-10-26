#!/bin/bash
#   Tim H 2020
#
# configures the Ubuntu system (local user) to use an HTTP proxy like Squid
#	References:
#		https://www.serverlab.ca/tutorials/linux/administration-linux/how-to-configure-proxy-on-ubuntu-18-04/
#		https://askubuntu.com/questions/11274/setting-up-proxy-to-ignore-all-local-addresses

# single user test

# test if proxy server accepts connection first
curl -v --proxy http://proxy.domain.local:3128  http://hackazon.webscantest.com
date	# timestamp to see when request was done to compare in logs

echo "

# Added by script
export HTTP_PROXY=\"proxy.domain.local:3128\" 
export no_proxy=\"localhost,127.0.0.1,::1,*.domain.local,10.0.1.0/24\"
" >> ~/.bash_profile

# verify changes to file
tail ~/.bash_profile

# force immediate changes
# TODO: make the ~ compatible where the variable isn't defined.
source ~/.bash_profile

# test it to generate an easy to find event in InsightIDR event log
curl http://hackazon.webscantest.com
env | grep -i proxy

# TODO: add system level changes
#sudo vi /etc/environment
#http_proxy="http://<username>:<password>@<hostname>:<port>/"
#http_proxy="http://my.proxyserver.net:8080/"
