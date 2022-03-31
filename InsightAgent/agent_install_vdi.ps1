# Creating a VDI golden image for Windows with the Rapid7 agent
# References:
#	https://insightagent.help.rapid7.com/docs/virtualization
#	https://insightagent.help.rapid7.com/docs/microsoft-system-center-configuration-manager-sccm
# 	https://insightagent.help.rapid7.com/docs/agent-controls

# If the VDI instances are non-persistent then you'll need go adjust the 
# Agent data retention settings to ensure your license count is more accurate:
# https://insightvm.help.rapid7.com/docs/database-backuprestore-and-data-retention#section-configure-data-retention-settings

# If you want different retention policies for different agents, then you'll 
# need to do some API work or have a separate services engagement. Usually our 
# customers who are building new security programs start with the basics in 
# year one and then move on to advanced configurations like scanning VDI or 
# OT environments in years two or three.

# If you're going to test it, make sure to start the shell 
# (cmd or Powershell) with admin priv

# Install the agent with no GUI and using the token
agentInstaller-x86_64.msi /l*v insight_agent_install_log.log CUSTOMTOKEN=us:tokenhere /quiet /qn

# The R7 agent service should automatically start after install. In the case
# of VDI environments, you do NOT want this to happen. When the agent runs
# for the first time it will generate a unique ID. Stop the service first:
sc stop ir_agent

# If the service autostarts then it may create the following directories. 
# Remove the files it created on first launch, so it will have a new 
# serial number on the next service start

# Power Shell version that's easy to remove directories:
# This will clear out all the config of the R7 agent
Remove-Item -path "C:\Program Files\Rapid7\Insight Agent\config" -recurse
Remove-Item -path "C:\Program Files\Rapid7\Insight Agent\snapshots" -recurse
Remove-Item -path "C:\Program Files\Rapid7\Insight Agent\cache" -recurse

# Shut down Windows and take a snapshot
# Each time this image is powered on it will create a NEW unique identifier
# of the agent, as if it was reporting in for the very first time.
