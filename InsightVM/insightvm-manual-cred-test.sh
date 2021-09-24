#!/bin/bash
# Tim H 2021
# Testing Rapid7's InsightVM authenticated scanning to a CentOS Linux 7 virtual machine that is joined to a Windows domain
# Tests password and key based authentication
#
# References:
#   https://www.freebsd.org/cgi/man.cgi?sshd_config(5)
#   https://www.digitalocean.com/community/tutorials/how-to-configure-custom-connection-options-for-your-ssh-client

##############################################################################
# On the CentOS target server you're trying to authenticate to
##############################################################################

# check to see if system is joined to an Active Directory domain
realm list

# check to see if user is recognizable and system is on the domain
id svc-insightvm@int.butters.me

# has this service account ever logged in to the local system?
ls /home/svc-insightvm@int.butters.me

# check the sudoers file
sudo grep -i svc-insightvm /etc/sudoers
# if they aren't in there, add them:
#sudo echo "svc-insightvm@INT.BUTTERS.ME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# test the escalation
sudo su - svc-insightvm@int.butters.me
cat ~/.ssh/authorized_keys
sudo su

## SSH Testing and debugging:
# enable enhanced logging
echo "LogLevel DEBUG3" >> /etc/ssh/sshd_config
# restart the service
/bin/systemctl restart sshd.service 

# watch the logs for new lines
tail -f /var/log/secure* 
# other options for grepping historical failures:
# grep --context=5 "svc-insightvm" /var/log/secure* 

##############################################################################
# from a laptop:
##############################################################################
# test password based authentication:
ssh -vvvv -o "User=svc-insightvm@INT.BUTTERS.ME" -o "PreferredAuthentications=password" -o "PubkeyAuthentication=no" insightvm-console.int.butters.me

# test key based authentication:
ssh -vvvv -o "User=svc-insightvm@INT.BUTTERS.ME" -o "PubkeyAuthentication=yes" -i ~/.ssh/svc-insightvm insightvm-console.int.butters.me

# also try tty1 console connection using the username/password and bypass SSH all together, or use su - 
