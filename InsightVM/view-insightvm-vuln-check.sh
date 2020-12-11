#!/bin/bash
#   Tim H 2019-2020
# Viewing the vuln checks on InsightVM scan engines or consoles
#   useful for finding exactly how vuln checks are run provided the name.
#   for example "CVE-2014-6271"
#   Designed for Ubuntu 16.04 and CentOS 7, to be run as the root user
#   See "view_insightvm_vuln_checks-manual.sh" for the manual way to do this

# bail if any errors
set -e

VULN_NAME_SUBSTRING=$1
#VULN_OS=$2     #TODO: This variable isn't being used yet

echo "starting script..."

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# verify that user provided the public IP of the engine
if [ -z "${VULN_NAME_SUBSTRING}" ]; then 
	echo "You must provide a CVE name or identifier not defined. Exiting"
	exit 2
fi

#TODO: verify that JAR utility is installed, install it if not
#   yum install java-devel # must be this package, not the other jre ones
#export JAVA_HOME=/usr/java/jdk1.8.0_161/jre

# manual definitions for testing
VULN_NAME_SUBSTRING="CVE-2014-6271"
VULN_NAME_SUBSTRING="ms08-067"

# define some output files for storage
JAR_FILE_LIST="jar_file_list.txt"                  # independent of CVE/check
OUTPUT_FILENAME="output-$VULN_NAME_SUBSTRING.csv"
# clear any existing file
rm -f "$OUTPUT_FILENAME"

# find the list of all the checks.jar files and store them in a text file for parsing
# compress the checks JAR files to a volume: 
#find /opt/rapid7/nexpose/plugins -type f -iname '*checks.jar' -print0 | tar -czf ~/plugins.tar.gz  --null -T -

#PLUGINS_DIR="/opt/rapid7/nexpose/plugins"
PLUGINS_DIR="$HOME/Downloads/scanner_plugins"

# only have to do once
find "$PLUGINS_DIR" -type f -iname '*checks.jar' > "$JAR_FILE_LIST"

echo "Searching JAR files for $VULN_NAME_SUBSTRING..."

# iterate through each JAR file
while IFS= read -r JAR_FILENAME
do
   # locate the list of VCK (vuln check) files within a Check.jar file that support the listed CVE
   VCK_FILELIST=$(jar tf "$JAR_FILENAME" | grep -i "$VULN_NAME_SUBSTRING")

   # if it actually found some checks that match:
   if [ -n "${VCK_FILELIST}" ]; then
      # store the scanner name
      # TODO: hardcoded 8 might not work on local file system
      #SCANNER_NAME=$(dirname "$JAR_FILENAME" | cut -d "/" -f8)   #default
      SCANNER_NAME=$(dirname "$JAR_FILENAME" | cut -d "/" -f6)    #Tim's laptop testing

      # iterate through the list of VCK files in the list that support the CVE
      for VCK_FILENAME_ITERATOR in $VCK_FILELIST; do
         # warning: case sensitivity is inconsistent in VCK filenames! Ex: sometimes it is "Windows" othertimes it is "windows"
         #     OS_VULN=${VCK_FILENAME_ITERATOR%$VULN_NAME_SUBSTRING*}   # this doesn't work due to case insensitivity
         # TODO: Extract the OS name and version out of the VCK filename and store as other columns the CSV

         OS_NAME="<TBD>"
         OS_VERSION="<TBD>"

         # dump the relevant information into a CSV output for later processing
         echo "$JAR_FILENAME,$VCK_FILENAME_ITERATOR,$SCANNER_NAME,$OS_NAME,$OS_VERSION" >> "$OUTPUT_FILENAME"
      done
   fi
done < "$JAR_FILE_LIST"

echo "finished searching JAR files."

#TODO: offer up the list of supported OSes for a given vuln, let the user pick which one based on a number

#TODO: offer up a list of particular checks for an OS (usually OS version/SP level) and let the user pick which one

#TODO: output the contents of the single VCK file that was selected:
# extract a particular check:
#jar xf /opt/rapid7/nexpose/plugins/java/1/CentOSRPMScanner/1/checks.jar centos_linux-cve-2014-6271-linuxrpm-cesa-2014-1293-bash-centos70-x86_64.vck

echo "script finished successfully."
