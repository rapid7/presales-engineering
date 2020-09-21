#!/bin/bash
# Tim H 2020
# This script installs and configures an InsightVM scan engine and pairs it to an existing InsightVM console.
#
#  Requirements:
#       * running as sudo or root
#       * running on supported Linux distro for InsightVM: https://www.rapid7.com/products/insightvm/system-requirements/
#       * wget is installed. You could also rewrite this using Curl if needed.

# exit if anything fails, do not continue
set -e

# define variables for deployment
console="example.company.com"
secret="A1A1-B2B2-C3C3-D4D4-E5E5-F6F6-G7G7-H8H8"


if [ ! "$USER" == "root" ]; then
    echo "This script must be run as root, aborting."
    exit 1
fi

# Download the installer for both InsightVM and Nexpose (same) and hashsum file
# This makes sure you're getting the latest installer
wget --quiet https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin \
		http://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.sha512sum

# Check the integrity of the download
sha512sum --check Rapid7Setup-Linux64.bin.sha512sum

# Mark installer as executable
chmod u+x Rapid7Setup-Linux64.bin

# Install the InsightVM scan engine and specify the InsightVM console and shared secret to pair with:
./InsightVM/Rapid7Setup-Linux64.bin -q -overwrite -Vfirstname='FirstName' -Vlastname='LastName' \
    -Vcompany='Rapid7' -Vusername='nxadmin' -Vpassword1='nxadmin' -Vpassword2='nxadmin' \
    -Vsys.component.typical\$Boolean=false -Vsys.component.engine\$Boolean=true \
    -VinitService\$Boolean=true \
    -VcommunicationDirectionChoice\$Integer=0 \
    -VconsoleAddress="$console" -VconsoleDetailPort='40815' -VsharedSecret="$secret"
