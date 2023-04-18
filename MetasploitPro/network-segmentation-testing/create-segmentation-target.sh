#!/bin/bash -e

#######################################################################
#
# Metasploit Segmentation and Firewall Testing Target
#
# The Segmentation and Firewall Testing MetaModule uses a server hosted
# by Rapid7 to determine what ports allow egress traffic out of a
# network.  In some scenarios, you may want to set up your own egress
# testing server.  This is useful when you want to test egress between
# different endpoints, or if you don't want to send data to a server on
# the internet.
#
# Creating your own egress testing server is easy.  All you need is a
# linux box loaded with your favorite distribution and configured with
# two IP addresses.  The first IP address will be an admin interface.
# This is usually found on the eth0 interface.  This IP will be used
# for controlling the egress testing server, usually via SSH.  The
# second IP address will host the egress testing server.  This is
# usually found on eth1, or a virtual interface such as eth0:1.  This
# is the IP you will scan from the Metasploit Segmentation and Firewall
# Testing MetaModule.
#
# Egress testing is done by opening all ports on the egress testing IP.
# Please keep in mind that opening all ports can be a security risk.
# To limit per-connection resources, we use the TARPIT functionality
# built in to iptables to open all ports.  Iptables tarpitting captures
# and holds incoming TCP connections using no local per-connection
# resources.  Connections are accepted, but immediately switched to the
# persist state (0 byte window).  This allows Metasploit to accurately
# determine open egress ports using SYN scans, while keeping others off
# your server.
#
# ---
#
# This script will set up an egress testing server.  It supports Ubuntu
# 12.04 LTS.  It should also work on later Ubuntu versions, your results
# may vary.
#
# To use this script:
#
# 1. Acquire an Ubuntu 12.04 server with at least two IP addresses.
# 2. Download and run the create-segmentation.sh script:
#
#    curl -sSL https://<metasploit ip address>:3790/create-segmentation-target.sh | sudo INTERFACE=eth1 bash
#
#    Where INTERFACE=eth1 points to the secondary network interface on
#    your server.  This is usually either eth1 or eth0:1.
# 3. From another host, perform an nmap scan of the egress IP:
#    sudo nmap <EGRESS TESTER IP>
#    Nmap should show several open ports.
#
#######################################################################

# ---------------------------
# Begin Configuration
# Please modify the variables in this section to match your environment

# The network interface to use for the egress testing server.
# This should be a secondary interface (not used for ssh, http, etc.)
# The configured target server will disable *all* incoming traffic on this interface.
# Examples:
#   INTERFACE=eth1
#   INTERFACE=eth0:1
INTERFACE=${INTERFACE:-eth1}
echo "INTERFACE=${INTERFACE}"

# End Configuration
# ---------------------------


# DO NOT MODIFY BELOW THIS LINE

if [[ $EUID -ne 0 ]]; then
   echo "[-] This script must be run as root" 1>&2
   exit 1
fi


if ls /etc/debian_version > /dev/null ; then
  echo "[*] Configuring segmentation testing server on Debian based system..."
  PLATFORM=debian
else
  echo "[-] Sorry, this distribution is not supported." 1>&2
  exit 2
fi


if ifconfig $INTERFACE >/dev/null 2>&1 ; then
  IPADDR=$(ifconfig $INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
fi
if [ -z "$IPADDR" ] ; then
  echo "[-] Cannot find IP address for $INTERFACE" 1>&2
  exit 3
fi

vergte() {
  [  "$1" = "$(echo -e "$2\n$1" | sort -V | head -n1)" ]
}

case $PLATFORM in
  debian)
    # xtables-addons < 2.0 does not support linux 3.7+ [1].
    # xtables-addons >= 2.0 does not support linux 3.6 and lower [1].
    # Ubuntu 12.04 usually ships with linux 3.2 and xtables-addons 1.40-1.
    # But in 12.04, the kernel can be upgraded.  In fact, Ubuntu Server 12.04 ships
    # with several different kernels depending on which release was installed (e.g.
    # 12.04.1, 12.04.2, 12.04.3, etc.)
    # To make things worse, Canonical does not ship an upgraded version of xtables-addons.
    # So if a user upgrades their kernel, or installs a later version, xtables will not work.
    #
    # We provide a PPA with a more recent xtables-addons version.  Try to use it if the kernel
    # makes sense.
    #
    # [1] - http://linux.softpedia.com/progChangelog/Xtables-addons-Changelog-38065.html
    if command -v lsb_release >/dev/null 2>&1 ; then
      codename=$(lsb_release --short --codename)
      if [ "$codename" == "precise" ] ; then
        if vergte 3.7 $(uname -r); then
          if [ ! -e /etc/apt/sources.list.d/blt04-xtables-addons.list ] ; then
            # Install from a PPA
            echo "[*] Adding xtables-addons ppa..."
            echo "deb http://ppa.launchpad.net/blt04/xtables-addons/ubuntu $codename main" > /etc/apt/sources.list.d/blt04-xtables-addons.list
            apt-key adv --quiet --no-tty --keyserver keyserver.ubuntu.com --recv-keys D4998A22 >/dev/null
          fi
        elif vergte 3.3 $(uname -r); then
          echo "[-] Unsupported kernel version: $(uname -r)!"
          echo "[-] The script will try to install xtables-addons, but it may fail!  Please upgrade your kernel to 3.7 or greater."
        fi
      fi
    fi

    if ! dpkg --get-selections | grep -q "^xtables-addons-common\s*install$" >/dev/null; then
      echo "[*] Installing xtables-addons-common..."
      apt-get update -qq
      apt-get install -qq -y xtables-addons-common >/dev/null
    fi

    echo -n "[*] Checking for tarpit module... "
    if [ -e "/lib/modules/$(uname --kernel-release)/updates/dkms/xt_TARPIT.ko" ] ; then
      echo "INSTALLED"
    else
      echo "MISSING"
      echo "[-] xtables-addons-common installation failed.  Tarpit module is missing." 1>&2
      exit 4
    fi
    ;;
esac


if ! iptables -L INPUT -n | grep "TARPIT.*${IPADDR}" >/dev/null 2>&1 ; then
  echo "[*] Adding IPTables tarpit rule..."
  iptables -A INPUT -d $IPADDR -p tcp -m tcp -j TARPIT --tarpit
else
  echo "[*] IPTables tarpit rule already exists.  Taking no action."
  exit 5
fi

echo "[*] Segmentation and Firewall Testing server successfully configured."
