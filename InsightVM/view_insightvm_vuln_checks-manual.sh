#!/bin/bash
#   Tim H 2019
# Viewing the vuln checks on InsightVM scan engines or consoles:

echo "this script is an example for copying and pasting, do not run this script directly"
exit 1

# install a tool that will give you the jar command to interact with JAR files
sudo apt-get update
sudo apt-get install -y fastjar

# list all the checks for a particular service scanner - in this case Palo Alto:
jar tf /opt/rapid7/nexpose/plugins/java/1/PaloAltoScanner/1/checks.jar

# find all checks for Palo Alto Security Advisory 2016-0020: "PAN-SA-2016-0020"
find /opt/rapid7/nexpose/plugins -type f -iname '*checks.jar' -exec  sh -c 'jar tf {} | grep pan-sa-2016-0020' \; -print

# find all checks for Shellshock: CVE-2014-6271
# note that the grep is case insensitive
find /opt/rapid7/nexpose/plugins -type f -iname '*checks.jar' -exec  sh -c 'jar tf {} | grep -i CVE-2014-6271' \; -print

# Let's say you'd like to see exactly how InsightVM performs the vuln checks
# for ShellShock on CentOS 7.0
# You use the above commands to locate the vuln check is inside this JAR file:
#	/opt/rapid7/nexpose/plugins/java/1/CentOSRPMScanner/1/checks.jar
# and the file is named:
# centos_linux-cve-2014-6271-linuxrpm-cesa-2014-1293-bash-centos70-x86_64.vck

cd /root/ || exit 1
jar xf /opt/rapid7/nexpose/plugins/java/1/CentOSRPMScanner/1/checks.jar centos_linux-cve-2014-6271-linuxrpm-cesa-2014-1293-bash-centos70-x86_64.vck

# the above commands will extract that one VCK file (the vuln check) into the
# root user's home directory:

# root@insightvm-console:~# cat centos_linux-cve-2014-6271-linuxrpm-cesa-2014-1293-bash-centos70-x86_64.vck 
# <?xml version="1.0" encoding="UTF-8"?>
# <VulnerabilityCheck id="centos_linux-cve-2014-6271" adv_id="CESA-2014:1293" scope="node">
#   <System>
#     <OS name="Linux" vendor="CentOS" arch="x86_64">
#       <version>
#         <stream>7</stream>
#       </version>
#     </OS>
#   </System>
#   <RPMCheck>
#     <rpm name="bash">
#       <version>
#         <range helper="rhRPM">
#           <high inclusive="0">4.2.45-5.el7_0.2</high>
#         </range>
#       </version>
#     </rpm>
#     <rpm name="bash-doc">
#       <version>
#         <range helper="rhRPM">
#           <high inclusive="0">4.2.45-5.el7_0.2</high>
#         </range>
#       </version>
#     </rpm>
#   </RPMCheck>
# </VulnerabilityCheck>
