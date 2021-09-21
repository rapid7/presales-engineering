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

##############################################################################
# Misc Notes:
##############################################################################

# seen in the logs on the target server:
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: receive packet: type 50 [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug1: userauth-request for user svc-insightvm@INT.BUTTERS.ME service ssh-connection method password [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug1: attempt 1 failures 0 [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug2: input_userauth_request: try method password [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: mm_auth_password entering [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: mm_request_send entering: type 12 [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: mm_auth_password: waiting for MONITOR_ANS_AUTHPASSWORD [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: mm_request_receive_expect entering: type 13 [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: mm_request_receive entering [preauth]
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: mm_request_receive entering
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: monitor_read: checking request 12
# Sep 21 11:33:32 insightvm-console sshd[4476]: debug3: PAM: sshpam_passwd_conv called with 1 messages
# Sep 21 11:33:32 insightvm-console sshd[4476]: pam_sss(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=10.0.1.138 user=svc-insightvm@INT.BUTTERS.ME
# Sep 21 11:33:32 insightvm-console sshd[4476]: pam_sss(sshd:auth): received for user svc-insightvm@INT.BUTTERS.ME: 6 (Permission denied)
# Sep 21 11:33:34 insightvm-console sshd[4476]: debug1: PAM: password authentication failed for svc-insightvm@INT.BUTTERS.ME: Authentication failure
# Sep 21 11:33:34 insightvm-console sshd[4476]: debug3: mm_answer_authpassword: sending result 0
# Sep 21 11:33:34 insightvm-console sshd[4476]: debug3: mm_request_send entering: type 13
# Sep 21 11:33:34 insightvm-console sshd[4476]: Failed password for svc-insightvm@INT.BUTTERS.ME from 10.0.1.138 port 52964 ssh2
# Sep 21 11:33:34 insightvm-console sshd[4476]: debug3: mm_auth_password: user not authenticated [preauth]
# Sep 21 11:33:34 insightvm-console sshd[4476]: debug3: userauth_finish: failure partial=0 next methods="publickey,gssapi-keyex,gssapi-with-mic,password" [preauth]
# Sep 21 11:33:34 insightvm-console sshd[4476]: debug3: send packet: type 51 [preauth]

#https://serverfault.com/questions/703743/cannot-login-via-ssh
#cat /etc/pam.d/sshd

# checking failures but doesn't return anything
#faillock --user svc-insightvm@INT.BUTTERS.ME
