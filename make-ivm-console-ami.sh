#!/bin/bash
# Tim H 2020-2021
# Bootstrap script for installing InsightVM/Nexpose on Ubuntu 20.04 64-bit
#   sets default UI creds as nxadmin/nxpassword
#   Disk size absolute minimum for QA is 15 GB, don't use this for POCs/trials
#   Total used disk space after install is about 11.2 GB including OS
#
# Common mistakes:
# 1) Forgetting to add additional engines to the license count - trial licenses are often just 1 scan engine
# 2) Forgetting to open firewall to allow incoming connections on TCP 3780 and 40815
# 3) Not meeting the bare minimum system requirements (2 cores, 16 GB RAM, 80 GB HDD)

# exit if anything fails, do not continue
set -e

# move into root user's home directory
cd "$HOME" || cd /root

sudo timedatectl set-timezone "America/New_York"

# Automatically resize the disk if not using the whole thing:
resize2fs $(mount | grep "/ " | cut -f1 -d" " )

# OPTIONAL - update the package list
sudo apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" upgrade


sudo apt-get install -o Dpkg::Options::="--force-confold" --force-yes -qq -yy apt-file apt-transport-https arping autoconf automake \
        ca-certificates curl dnsutils gnupg-agent grep libtool lsof make \
        net-tools netcat nmap ntpdate openssh-server openssl \
        python3-pip screen software-properties-common sysstat tar tcpdump \
        tcpflow telnet traceroute unzip vim wget gnupg

cd /home/ubuntu/ || exit 1
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod +x ec2-metadata
./ec2-metadata --help

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o "awscliv2.zip"
    # save the public key for integrity check
    echo "-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF2Cr7UBEADJZHcgusOJl7ENSyumXh85z0TRV0xJorM2B/JL0kHOyigQluUG
ZMLhENaG0bYatdrKP+3H91lvK050pXwnO/R7fB/FSTouki4ciIx5OuLlnJZIxSzx
PqGl0mkxImLNbGWoi6Lto0LYxqHN2iQtzlwTVmq9733zd3XfcXrZ3+LblHAgEt5G
TfNxEKJ8soPLyWmwDH6HWCnjZ/aIQRBTIQ05uVeEoYxSh6wOai7ss/KveoSNBbYz
gbdzoqI2Y8cgH2nbfgp3DSasaLZEdCSsIsK1u05CinE7k2qZ7KgKAUIcT/cR/grk
C6VwsnDU0OUCideXcQ8WeHutqvgZH1JgKDbznoIzeQHJD238GEu+eKhRHcz8/jeG
94zkcgJOz3KbZGYMiTh277Fvj9zzvZsbMBCedV1BTg3TqgvdX4bdkhf5cH+7NtWO
lrFj6UwAsGukBTAOxC0l/dnSmZhJ7Z1KmEWilro/gOrjtOxqRQutlIqG22TaqoPG
fYVN+en3Zwbt97kcgZDwqbuykNt64oZWc4XKCa3mprEGC3IbJTBFqglXmZ7l9ywG
EEUJYOlb2XrSuPWml39beWdKM8kzr1OjnlOm6+lpTRCBfo0wa9F8YZRhHPAkwKkX
XDeOGpWRj4ohOx0d2GWkyV5xyN14p2tQOCdOODmz80yUTgRpPVQUtOEhXQARAQAB
tCFBV1MgQ0xJIFRlYW0gPGF3cy1jbGlAYW1hem9uLmNvbT6JAlQEEwEIAD4WIQT7
Xbd/1cEYuAURraimMQrMRnJHXAUCXYKvtQIbAwUJB4TOAAULCQgHAgYVCgkICwIE
FgIDAQIeAQIXgAAKCRCmMQrMRnJHXJIXEAChLUIkg80uPUkGjE3jejvQSA1aWuAM
yzy6fdpdlRUz6M6nmsUhOExjVIvibEJpzK5mhuSZ4lb0vJ2ZUPgCv4zs2nBd7BGJ
MxKiWgBReGvTdqZ0SzyYH4PYCJSE732x/Fw9hfnh1dMTXNcrQXzwOmmFNNegG0Ox
au+VnpcR5Kz3smiTrIwZbRudo1ijhCYPQ7t5CMp9kjC6bObvy1hSIg2xNbMAN/Do
ikebAl36uA6Y/Uczjj3GxZW4ZWeFirMidKbtqvUz2y0UFszobjiBSqZZHCreC34B
hw9bFNpuWC/0SrXgohdsc6vK50pDGdV5kM2qo9tMQ/izsAwTh/d/GzZv8H4lV9eO
tEis+EpR497PaxKKh9tJf0N6Q1YLRHof5xePZtOIlS3gfvsH5hXA3HJ9yIxb8T0H
QYmVr3aIUes20i6meI3fuV36VFupwfrTKaL7VXnsrK2fq5cRvyJLNzXucg0WAjPF
RrAGLzY7nP1xeg1a0aeP+pdsqjqlPJom8OCWc1+6DWbg0jsC74WoesAqgBItODMB
rsal1y/q+bPzpsnWjzHV8+1/EtZmSc8ZUGSJOPkfC7hObnfkl18h+1QtKTjZme4d
H17gsBJr+opwJw/Zio2LMjQBOqlm3K1A4zFTh7wBC7He6KPQea1p2XAMgtvATtNe
YLZATHZKTJyiqA==
=vYOk
-----END PGP PUBLIC KEY BLOCK-----" > aws_pgp.pub
    # import Amazon's public PGP key
gpg --import aws_pgp.pub
# Download Amazon's signature on the file
curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig
# verify the installer's integrity
gpg --verify awscliv2.sig awscliv2.zip
unzip awscliv2.zip
# run the installer
./aws/install
# output the version and verify it installed properly
aws --version



# Download the installer for both InsightVM and Nexpose (same) 
# and MD5 hashsum file
# This makes sure you're getting the latest installer
curl -o Rapid7Setup-Linux64.bin             https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin
curl -o Rapid7Setup-Linux64.bin.sha512sum   https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.sha512sum

# Check the integrity of the download, makes sure IPSes or 
# SSL proxies didn't mess with the installer.
sha512sum --check Rapid7Setup-Linux64.bin.sha512sum

# Mark installer as executable
chmod u+x Rapid7Setup-Linux64.bin

# install InsightVM console, but don't start the service yet
# unfortunately these command line arguments aren't publicly documented
# the Vfirstname, Vlastname and Vcompany are only used for the self-signed SSL certificate
# this is the non-interactive version that will automatically install InsightVM console
# if you want to do the interactive install, just do:
#   sudo ./Rapid7Setup-Linux64.bin
#
# WARNING: do not use this first account as a personal account
#   do not attempt to use Platform Login with it.

sudo ./Rapid7Setup-Linux64.bin -q -overwrite  \
    -Djava.net.useSystemProxies=false \
    -Vfirstname='Rapid7 InsightVM Console' \
    -Vlastname='POC' \
    -Vcompany='Rapid7' \
    -Vusername='nxadmin' \
    -Vpassword1='nxpassword' \
    -Vpassword2='nxpassword'

# If you're going to enable FIPS mode, you must do it before starting
# the service for the first time. See more here:
# https://docs.rapid7.com/insightvm/enabling-fips-mode/#enabling-fips-mode

# Now is a good time to add remote mount points for the backups location
# make sure those backup files are not on the same virtual machine
# the backups directory does not exist until the first backup is created, so
# you'll need to create it first.
# sudo mkdir /opt/rapid7/nexpose/nsc/backups
# here is an example of an NFS mount point
# echo "10.0.1.35:/volume1/nfs_insightvm /opt/rapid7/nexpose/nsc/backups      nfs auto,nofail,noexec,noatime,nolock,intr,tcp,actimeo=1800 0 0" | sudo tee -a /etc/fstab
# sudo mount /opt/rapid7/nexpose/nsc/backups


echo "com.rapid7.nexpose.nsc.dbcc=0" | sudo tee --append /opt/rapid7/nexpose/nsc/CustomEnvironment.properties


# start it up, not started by default
sudo systemctl start nexposeconsole.service

###########################
# Additional notes for firewalls and more
# wait until the service finishes starting
# usually 30 minutes on very first boot after install, depending on hardware specs

# Can activate the license via RESTful API using the activateLicense method, which also supports offline file activation
# https://help.rapid7.com/insightvm/en-us/api/index.html#operation/activateLicense

# TODO: optionally disable database integrity checks before first launch to speed it up

# Enable automatic security updates:
apt-get -y install unattended-upgrades 
unattended-upgrade -d

