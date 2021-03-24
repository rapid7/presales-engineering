#!/bin/bash
# Tim H 2021
#
# CentOS 7 64-bit - configure audit compatability mode
# auditd and Rapid7 Insight Agent must already be installed before running this script
# This is a general guide for copy and pasting, not intended to be run directly
# !NON-EXECUTABLE!
#
# References:
#   https://docs.rapid7.com/insight-agent/auditd-compatibility-mode-for-linux-assets/#auditd-compatibility-mode-for-linux-assets

# stopping the relevant services before making changes.
service ir_agent stop
service auditd stop

# seeing if these files exist before outputting.
ls -lah /etc/audit/audit.rules
ls -lah /etc/audisp/audispd.conf
ls -lah /etc/audisp/plugins.d/af_unix.conf

# this is the main config file, yours may be different
echo "
# This file contains the auditctl rules that are loaded
# whenever the audit daemon is started via the initscripts.
# The rules are simply the parameters that would be passed
# to auditctl.
 
# First rule - delete all
-D
 
# Increase the buffers to survive stress events.
# Make this bigger for busy systems
-b 8192
 
# DO NOT BLOCK THE FOLLOWING EVENTS
# USER_AUTH
# USER_START
# USER_END
# USER_LOGIN
# USER_LOGOUT
# ADD_USER
# DEL_USER
# ADD_GROUP
# DEL_GROUP
# SERVICE_START
# SERVICE_STOP
# SYSCALL
# EXECVE

# REQUIRED (for Insight Agent): watch for execve syscalls, change to arch=b32 for 32 bit systems
-a always,exit -F arch=b64 -S execve -F key=execve

# Feel free to add additional rules below this line. See auditctl man page
" > /etc/audit/audit.rules

##############################################################################
# THIS IS THE LINE THAT FIXED IT FOR CentOS 7
cp /etc/audit/audit.rules /etc/audit/rules.d/audit.rules
##############################################################################

# another output file
echo "
#
# This file controls the configuration of the audit event
# dispatcher daemon, audispd.
#
 
q_depth = 8192
overflow_action = SYSLOG
priority_boost = 4
max_restarts = 10
name_format = HOSTNAME" > /etc/audisp/audispd.conf

# another output file
echo "
# This file controls the configuration of the
# af_unix socket plugin. It simply takes events
# and writes them to a unix domain socket. This
# plugin can take 2 arguments, the path for the
# socket and the socket permissions in octal.
 
active = yes
direction = out
path = builtin_af_unix
type = builtin
args = 0600 /var/run/audispd_events
format = binary" > /etc/audisp/plugins.d/af_unix.conf

# marking files as readable just in case
chmod +r /etc/audisp/plugins.d/af_unix.conf /etc/audisp/audispd.conf /etc/audit/audit.rules

# modifying R7 agent's settings
echo "{\"auditd-compatibility-mode\":true}" > /opt/rapid7/ir_agent/components/insight_agent/common/audit.conf

# restarting services, it's okay to see a "fail" since I'm issuing a restart, not a start.
service auditd restart
service ir_agent restart

# setting auditd to start on boot
chkconfig auditd on

# checking status of services, make sure they're both running
service auditd status
service ir_agent status

# the most important command to check if auditd is configured correctly
auditctl -l

#the last command must return  something that looks like this:
# -a always,exit -F arch=b64 -S execve -F key=execve
# if you see "No rules" then it has failed
