#!/bin/bash
# Tim H 2021, 2023
# Designed to test authentication from Ubuntu (Debian) command line to
# a Windows workstation/server using SMB/CIFS. This script is often used when
# InsightVM is failing to authenticate to a Windows asset and you want to
# test if the credentials are valid.

# References:
#   https://derflounder.wordpress.com/2011/08/11/connecting-to-an-smb-server-from-the-command-line-in-os-x/
#   https://www.linuxtopia.org/online_books/network_administration_guides/using_samba_book/ch09_02_18.html
#   https://www.varonis.com/blog/cifs-vs-smb/

# fully qualified domain name of the target you're trying to authenticate to
TARGET_FQDN="winserver.acme.local"

# the IPv4 address of the target you're attempting to authenticate to
TARGET_IP="10.0.1.11"

# service account username, not including any domain
SMB_USERNAME="svc-insightvm"

# Active Directory Domain - I think this must be all caps. 
# Don't put the whole "int.company.local", just INT
SMB_DOMAIN="INT"

# SMB Share being accessed
# note the single quotes, not double quotes
SMB_SHARE='ADMIN$'

# view network configuration, check if there are more than 1 NICs
# displays all network adapters, even if they are down. You can ignore the 
# loopback (lo) adapter
# if there are multiple real NICs, then scan engines may get confused as to 
# which NIC to use to get to a target
ifconfig -a

# install dependencies for this troubleshooting script
sudo apt-get update && sudo apt-get install -y smbclient nmap dnsutils

# Mac OS X tools install using homebrew:
# brew install samba nmap 

###############################################################################
#   Checking DNS first
###############################################################################
# view the DNS server that this Linux system uses. The internal DNS server 
# should probably be an internal IP that can resolve internal DNS domains such as
# acme.local
cat /etc/resolv.conf

# test to see if this Ubuntu system can resolve the DNS for the target system
# (using the internal DNS server)
# nslookup doesn't always use the DNS servers specified in /etc/resolv.conf
# so dig is recommended instead of nslookup
dig "$TARGET_FQDN"

# test reverse DNS lookup. If InsightVM's sites are configured to scan IP
# ranges (like 10.6.1.0/24 or 10.0.1.1-254), then InsightVM will also attempt
# a reverse DNS lookup to determine the hostname from the IP. Your internal
# DNS server will need to be configured to allow reverse DNS lookups.
# If InsightVM runs an unauthenticated scan (or authentication fails) on an
# IP and the scan does not list the hostname, then it's likely that the
# reverse DNS is failing or not available.
# the -x flag indicates the reverse dns
dig -x "$TARGET_IP"


###############################################################################
#   Checking Layer 3 and Layer 4 network connectivity
###############################################################################
# Layer 3 - Can this Ubuntu system PING the target system
# the target system's firewall may not respond to ping messages

#
# EXAMPLE: of a successful ping:
#
# PING 10.0.1.1 (10.0.1.1): 56 data bytes
# 64 bytes from 10.0.1.1: icmp_seq=0 ttl=64 time=43.244 ms
# 64 bytes from 10.0.1.1: icmp_seq=1 ttl=64 time=1.443 ms
# 64 bytes from 10.0.1.1: icmp_seq=2 ttl=64 time=0.808 ms
# --- 10.0.1.1 ping statistics ---
# 3 packets transmitted, 3 packets received, 0.0% packet loss
# round-trip min/avg/max/stddev = 0.808/15.165/43.244/19.857 ms
ping -c 3 "$TARGET_IP"

# Layer 4 - basic TCP port scan of the target system
# the -Pn flag will force nmap to scan the target even if it does not
# respond to a ping.
# For Windows systems, you should see several ports open, including
# TCP 139 and 445.
nmap -Pn "$TARGET_IP"

#
# EXAMPLE: successful nmap scan of a Windows 2019 server:
#
# Starting Nmap 7.93 ( https://nmap.org ) at 2023-04-20 13:27 EDT
# Nmap scan report for 10.0.1.1
# Host is up (0.40s latency).
# Not shown: 992 closed tcp ports (conn-refused)
# PORT     STATE SERVICE
# 22/tcp   open  ssh
# 53/tcp   open  domain
# 80/tcp   open  http
# 443/tcp  open  https
# 6789/tcp open  ibm-db2-admin
# 7443/tcp open  oracleas-https
# 8080/tcp open  http-proxy
# 8443/tcp open  https-alt


###############################################################################
#   Testing SMB authentication to a Windows asset
###############################################################################
# smbclient is a Linux command line tool for enumerating SMB shares on system
# It will attempt to authenticate using active directory credentials
# This command will prompt for the password to be entered, but will not display
# the password on the screen.

smbclient --debuglevel=3 --user="$SMB_USERNAME" --workgroup="$SMB_DOMAIN" -L "\\\\$TARGET_IP\\$SMB_SHARE"

#
# EXAMPLE: of successful authentication
#
# Password for [INT\jdoe.adm]:
# Cannot do GSE to an IP address
# 	Sharename       Type      Comment
# 	---------       ----      -------
# 	ADMIN$          Disk      Remote Admin
# 	C$              Disk      Default share
# 	dhcplogs        Disk
# 	dnslogs         Disk
# 	E$              Disk      Default share
# 	honeyfile_test  Disk
# 	IPC$            IPC       Remote IPC
# 	NETLOGON        Disk      Logon server share
# 	SYSVOL          Disk      Logon server share
# SMB1 disabled -- no workgroup available



#
# EXAMPLE: of wrong password or wrong password:
#
# lp_load_ex: refreshing parameters
# Initialising global parameters
# rlimit_max: increasing rlimit_max (256) to minimum Windows limit (16384)
# Can't load /opt/homebrew/etc/smb.conf - run testparm to debug it
# added interface en11 ip=10.0.1.36 bcast=10.0.1.255 netmask=255.255.255.0
# added interface en0 ip=10.0.1.47 bcast=10.0.1.255 netmask=255.255.255.0
# Client started (version 4.18.2).
# Connecting to 10.0.1.11 at port 445
# Password for [INT\jdoe.adm]:
# GENSEC backend 'gssapi_spnego' registered
# GENSEC backend 'gssapi_krb5' registered
# GENSEC backend 'gssapi_krb5_sasl' registered
# GENSEC backend 'spnego' registered
# GENSEC backend 'schannel' registered
# GENSEC backend 'ncalrpc_as_system' registered
# GENSEC backend 'sasl-EXTERNAL' registered
# GENSEC backend 'ntlmssp' registered
# GENSEC backend 'ntlmssp_resume_ccache' registered
# GENSEC backend 'http_basic' registered
# GENSEC backend 'http_ntlm' registered
# GENSEC backend 'http_negotiate' registered
# Cannot do GSE to an IP address
# Got challenge flags:
# Got NTLMSSP neg_flags=0x62898215
# NTLMSSP: Set final flags:
# Got NTLMSSP neg_flags=0x62088215
# NTLMSSP Sign/Seal - Initialising with flags:
# Got NTLMSSP neg_flags=0x62088215
# SPNEGO login failed: The attempted logon is invalid. This is either due to a bad username or authentication information.
# session setup failed: NT_STATUS_LOGON_FAILURE



#
# EXAMPLE: what shares are visible with ANONYMOUS access
#
# smbclient --debuglevel=2 --no-pass --user="" -L \\\\10.0.1.11\\ADMIN$
# rlimit_max: increasing rlimit_max (256) to minimum Windows limit (16384)
# Can't load /opt/homebrew/etc/smb.conf - run testparm to debug it
# added interface en11 ip=10.0.1.36 bcast=10.0.1.255 netmask=255.255.255.0
# added interface en0 ip=10.0.1.47 bcast=10.0.1.255 netmask=255.255.255.0
# Cannot do GSE to an IP address
# 	Sharename       Type      Comment
# 	---------       ----      -------
# SMB1 disabled -- no workgroup available


#
# EXAMPLE: of accessing an INVALID share name with valid username and password
#
# smbclient  --debuglevel=3 --user="$SMB_USERNAME" --workgroup="$SMB_DOMAIN" \\\\10.0.1.11\\invalidsharename
# lp_load_ex: refreshing parameters
# Initialising global parameters
# rlimit_max: increasing rlimit_max (256) to minimum Windows limit (16384)
# Can't load /opt/homebrew/etc/smb.conf - run testparm to debug it
# added interface en11 ip=10.0.1.36 bcast=10.0.1.255 netmask=255.255.255.0
# added interface en0 ip=10.0.1.47 bcast=10.0.1.255 netmask=255.255.255.0
# Password for [INT\thonker.adm]:
# Client started (version 4.18.2).
# Connecting to 10.0.1.11 at port 445
# Connecting to 10.0.1.11 at port 139
# GENSEC backend 'gssapi_spnego' registered
# GENSEC backend 'gssapi_krb5' registered
# GENSEC backend 'gssapi_krb5_sasl' registered
# GENSEC backend 'spnego' registered
# GENSEC backend 'schannel' registered
# GENSEC backend 'ncalrpc_as_system' registered
# GENSEC backend 'sasl-EXTERNAL' registered
# GENSEC backend 'ntlmssp' registered
# GENSEC backend 'ntlmssp_resume_ccache' registered
# GENSEC backend 'http_basic' registered
# GENSEC backend 'http_ntlm' registered
# GENSEC backend 'http_negotiate' registered
# Cannot do GSE to an IP address
# Got challenge flags:
# Got NTLMSSP neg_flags=0x62898215
# NTLMSSP: Set final flags:
# Got NTLMSSP neg_flags=0x62088215
# NTLMSSP Sign/Seal - Initialising with flags:
# Got NTLMSSP neg_flags=0x62088215
# NTLMSSP Sign/Seal - Initialising with flags:
# Got NTLMSSP neg_flags=0x62088215
# tree connect failed: NT_STATUS_BAD_NETWORK_NAME

#################################
# MORE EXAMPLES
#################################

#
# EXAMPLE: interactive connection, can then type 'listconnect' or 'showconnect'
#
smbclient  --debuglevel=2 --user="$SMB_USERNAME" --workgroup="$SMB_DOMAIN" \\\\10.0.1.11\\ADMIN$


#
# Example: trying to login using the domain GUEST account and failure
#
# smbclient  --debuglevel=3  \\\\10.0.1.11\\ADMIN$ -U guest%
# lp_load_ex: refreshing parameters
# Initialising global parameters
# rlimit_max: increasing rlimit_max (256) to minimum Windows limit (16384)
# Can't load /opt/homebrew/etc/smb.conf - run testparm to debug it
# added interface en11 ip=10.0.1.36 bcast=10.0.1.255 netmask=255.255.255.0
# added interface en0 ip=10.0.1.47 bcast=10.0.1.255 netmask=255.255.255.0
# Client started (version 4.18.2).
# Connecting to 10.0.1.11 at port 445
# GENSEC backend 'gssapi_spnego' registered
# GENSEC backend 'gssapi_krb5' registered
# GENSEC backend 'gssapi_krb5_sasl' registered
# GENSEC backend 'spnego' registered
# GENSEC backend 'schannel' registered
# GENSEC backend 'ncalrpc_as_system' registered
# GENSEC backend 'sasl-EXTERNAL' registered
# GENSEC backend 'ntlmssp' registered
# GENSEC backend 'ntlmssp_resume_ccache' registered
# GENSEC backend 'http_basic' registered
# GENSEC backend 'http_ntlm' registered
# GENSEC backend 'http_negotiate' registered
# Cannot do GSE to an IP address
# Got challenge flags:
# Got NTLMSSP neg_flags=0x62898215
# NTLMSSP: Set final flags:
# Got NTLMSSP neg_flags=0x62088215
# NTLMSSP Sign/Seal - Initialising with flags:
# Got NTLMSSP neg_flags=0x62088215
# SPNEGO login failed: The referenced account is currently disabled and cannot be logged on to.
# session setup failed: NT_STATUS_ACCOUNT_DISABLED

