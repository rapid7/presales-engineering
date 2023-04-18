#!/bin/bash
# Tim H 2021
# Written just for James D
# Designed to test authentication from Ubuntu (Debian) command line to a Windows workstation/server using SMB

# References:
#   https://derflounder.wordpress.com/2011/08/11/connecting-to-an-smb-server-from-the-command-line-in-os-x/
#   https://www.linuxtopia.org/online_books/network_administration_guides/using_samba_book/ch09_02_18.html
#   https://www.varonis.com/blog/cifs-vs-smb/

TARGET_FQDN="dc02.int.company.local"            # fully qualified domain name of the target you're trying to authenticate to
SMB_USERNAME="insightvm-service-account-name"   # service account username, not including any domain
SMB_DOMAIN="INT"                                # Active Directory Domain - I think this must be all caps. Don't put the whole "int.company.local", just INT

SMB_SHARE="ADMIN\$"                             # SMB Share being accessed

# view network configuration, check if there are more than 1 NICs
# displays all network adapters, even if they are down. You can ignore the loopback (lo) adapter
ifconfig -a
# if there are multiple real NICs, then scan engines may get confused as to which NIC to use to get to a target

# install dependencies for this troubleshooting script
sudo apt-get update
sudo apt-get install -y smbclient nmap dnsutils

# make sure the DNS resolves
dig "$TARGET_FQDN"

# can you ping it?
ping -c 3 "$TARGET_FQDN"

# is the port open?
nmap -Pn "$TARGET_FQDN"

# enumerating SMB shares on system
# attempt AD authentication
# list the shares, requires authentication
smbclient --debuglevel=2 --user="$SMB_USERNAME" --workgroup="$SMB_DOMAIN"  -L "\\\\$TARGET_FQDN\\$SMB_SHARE"


#################################
# EXAMPLES
#################################

# example connection, this should work:
smbclient  --debuglevel=2 --user="$SMB_USERNAME" --workgroup="$SMB_DOMAIN" \\\\10.0.1.11\\ADMIN$
# can then type 'listconnect' or 'showconnect'

# unauthenticated example will fail:
smbclient  --debuglevel=3  \\\\10.0.1.11\\ADMIN$ -U guest%
