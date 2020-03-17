#!/bin/bash
#
#   runtime: ~4-9 minutes
#   configures an Ubuntu 16.04 system for a lab
#	doesn't 100% work for Ubuntu 18.04: no IP listed on login screen
#   works with local VMs and Amazon AMIs

# bomb out in case anything runs an error. Shouldn't happen but can disable if needed
# OPTIONAL: add more flags: https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash
set -e

# define globals, customizable by user
NEW_USERNAME="r7lab"
NEW_USER_PASSWORD="password"
NEW_HOSTNAME="UbuntuLab"
NEW_DOMAIN="dundermifflin.local"
NEW_TIMEZONE="America/New_York"
LOGFILE="/root/bootstrap.log"

# redirect all output to a logfile
rm -f "$LOGFILE"	# clear the log if it already exists
exec >> "$LOGFILE"
exec 2>&1

# bail if not root or sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# remove the CD-Rom in apt-get sources list
#	needed for local VMs created with ISO
sed -i '/cdrom/d' /etc/apt/sources.list


################################################################################
#		FUNCTION DEFINITIONS
################################################################################

log () {
	# formatted log output including timestamp
	echo -e "[bootstrap] $(date)\t $@"
}


silent_apt_install () {
	# installs a supplied set of APT packages
	# makes sure that no output is put to the screen
	# really made to avoid the pink interactive screen like Grub prompts that 
	#	screw up programatic input.
	set -e
	apt-get -qq -y update
	apt-get install -o Dpkg::Options::="--force-confold" --force-yes -qq -yy $@
}

get_host_type () {
	# Gathers the host type: like virtual machine, container, AWS EC2 instance
	# used by other functions to determine which packages to install or settings
	# to set
	# can't do anything that will output to screen: echo "Getting host type..."
	set -e
	#https://www.ostechnix.com/check-linux-system-physical-virtual-machine/
	#https://stackoverflow.com/questions/20010199/how-to-determine-if-a-process-runs-inside-lxc-docker
	
	#returns the host type as text
	if grep -q docker /proc/1/cgroup ; then
		echo "container"
	elif curl -sSf http://169.254.169.254 -o /dev/null ; then
		echo "ec2"
	elif [ $(facter is_virtual) == "true" ]; then
		echo "vm"
	else
		echo "baremetal"
	fi	
}

disable_and_stop_apt_updates () {
	# Disables automatic updates via APT. 
	#	Done for lab environments to make sure no unauthorized changes are made
	log "Disabling automatic updates..."
	set -e

	# stop any in-progress updates, required for EC2 instances	
	apt-get remove -y unattended-upgrades ubuntu-release-upgrader-core > /root/updates-have-been-disabled.log
	
	# fix any updates that were in progress when stopped, 
	#	required for EC2 instances
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true
	export UCF_FORCE_CONFFNEW=YES
	# gotta remove this file to avoid a later conflict that forces an 
	#	interactive prompt that I can't get around
	rm -f /etc/default/grub		#no error code even if file doesn't exist
	
	# fix any updates that were in progress when I killed them
	#	Must be done before I can run another apt-get install or upgrade
	dpkg --configure -a	
}

install_apt_tools () {
	# Installs all the most common APT packages for Rapid7 lab environments.
	# Packages are independent of host type
	log "Installing standard tools via apt-get..."
	set -e
	silent_apt_install apt-file apt-transport-https arping autoconf automake \
		ca-certificates curl dnsutils gcc gnupg-agent grep libtool lsof make \
		mlocate net-tools netcat nmap npm ntpdate openssh-server openssl \
		python3-pip screen software-properties-common sysstat tar tcpdump \
		tcpflow telnet traceroute unzip vim wget
	log "Finished installing standard tools via apt-get..."
}

install_aws_cli () {
	# installs the Amazon Web Service Command Line Interface v2
	log "Starting installing AWS CLI..."
	set -e

	# install dependencies
	silent_apt_install curl unzip gnupg
	# download the installer
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
	log "Finished installing AWS CLI..."
}

create_lab_user () {
	log "Adding lab user..."
	set -e

	# add the lab user and password
	if id -u "$NEW_USERNAME" ; then
	    log "$NEW_USERNAME user already exists"
	else
	   log "need to create $NEW_USERNAME user"
	    # create the user and specify home directory, but no password
	    useradd $NEW_USERNAME -s /bin/bash -m --home-dir /home/$NEW_USERNAME
	    # set their password
		echo -e "$NEW_USER_PASSWORD\n$NEW_USER_PASSWORD" | passwd $NEW_USERNAME
		# make them a sudoer
	    usermod -aG sudo $NEW_USERNAME
	fi

	# drop a public key in .ssh/authorized_keys to enable key based SSH access
	# set perms on .ssh directory, touch any files that need to be created and set their perms
	# make sure ownership of files in $NEW_USERNAME's directory are their own
	#TODO: add check to see if .ssh dir exists before creating it
	mkdir /home/$NEW_USERNAME/.ssh    # throws error if directory already exists
	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZaZuGDSVg0qPyltIEk/oLSx0cfWiM5WUONksxHx2TNokuO7cPqRvtMosHQ4/BdtZ81SVb5tAJUOIyIOfWMKzgd0uv7c/IOvQw4lUg7rbMVcAu7xmabTu+TUpIT3Cmt8N87dxQS3PA5sCm/2Uqe+9czA684wPkjBxR7KeIzOiTInasGZ2mZF9zPfm46+K9Q0/p+25m7UQs46kP3Hyil7l0NbLZ9DZG9ckOfEwldezqugsiFxda65W51+z8AM8czqcXphN4jLOby7rQau0R7u1k3upWa9IjhzLQHmjgYulb2/N1wqTgsTKGlsIXQUCNUvYjkMoLxwkYloPN7XnfdjS7dFX7qwsPo/vLSCy2wiZaK7jDtLtUGkL2sjuE3s9cOi/79ENS9FXKRfAiWM6175g3TM423LS49j6snyFNaBUbT49IYrvfo3fUgUkUkAClDJtBgZaL1ozeZD1YBCn6yXEnkFX93MzDpYtps++f6bL2d44OcRRahuUwIbPs0y0YPtGiKzg0KyjMtvSsYFvyYnTqtS7EOjRXWzefjRuTRsBtluX3fbHnWbnJ/8Y6qVy2q3w/dP0V437DQAHFdBIxVN7PxuAq2Nu3WlR4uY4hJUZoK5OEbX2KOGYnB8x9RW+dx4lS6fF6k/IkIoqMekoA1h2rbIlaTWb2vG3eTvht0Nv+DQ== testkey@laptop.local" >> /home/$NEW_USERNAME/.ssh/authorized_keys
	touch /home/$NEW_USERNAME/.ssh/config
	chown -R $NEW_USERNAME:$NEW_USERNAME /home/$NEW_USERNAME
	chmod -R 700 /home/$NEW_USERNAME/.ssh
	log "Finished configuring additional user..."

}

setup_time_and_sync () {
	# set time zone and sync time
	log "Setting time zone and syncing time..."
	set -e

	timedatectl set-timezone "$NEW_TIMEZONE"

	# install ntpdate so we can time sync
	silent_apt_install ntpdate

	# time sync, can only be done after installing ntpdate package
	ntpdate pool.ntp.org
}

install_docker () {
	# Install docker, configure user
	log "Installing docker..."
	set -e

	# Installs docker in a way to prep for DHowe's script
	#W: GPG error: https://download.docker.com/linux/ubuntu xenial InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 7EA0A9C3F273FCD8
	silent_apt_install docker docker-compose
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt -qq -y update
	apt -qq -y install docker-ce
	curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	
	# in AWS ubuntu $USER does not exist when running in bootstrap mode
	usermod -a -G docker "$NEW_USERNAME"
	
	chmod +x /usr/local/bin/docker-compose
	log "Docker installation complete..."
}

download_r7_installers () {
	# Downloads all the common R7 Linux installers and preps them for install
	#TODO: make this step optional w/ flag/parameter to speed up testing
	log "Downloading Rapid7 installers..."
	set -e

	# need to cd into target directory before calling this function
	# Download InsightVM installer and MD5 checksum file
	wget --quiet https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin \
		https://download2.rapid7.com/download/InsightVM/Rapid7Setup-Linux64.bin.md5sum
	# check the integrity of the IVM installer delete it if it doesn't match
	md5sum --check Rapid7Setup-Linux64.bin.md5sum || rm -f Rapid7Setup-Linux64.bin
	mv Rapid7Setup-Linux64.bin InsightVM_installer.bin

	# No MD5 files for other installers
	wget --quiet --output-document=Collector_installer.sh             https://s3.amazonaws.com/com.rapid7.razor.public/InsightSetup-Linux64.sh
	wget --quiet https://us.downloads.connect.insight.rapid7.com/orchestrator/installers/r7-orchestrator-installer.sh
	wget --quiet --output-document=Metasploit_Pro_installer.run       https://downloads.metasploit.com/data/releases/metasploit-latest-linux-x64-installer.run
	wget --quiet --output-document=Metasploit_Framework_installer.run https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb
	chmod 500 ./*.bin ./*.sh ./*.run
	log "Finished downloading Rapid7 installers..."
}

configure_friendly_login_prompt () {
	# sets a more user friendly login screen in Ubuntu
	# now includes default username/password and the IP of the system
	# makes lab environments a lot easier.
	log "Configuring local login prompt..."
	set -e

	# changes the local console login prompt to include username/password and IP
	cat << EOF > /etc/rc.local
#!/bin/sh -e
/bin/echo "This is \n (\s \m \r) \t \l">/etc/issue
/bin/echo "Default user/password: $NEW_USERNAME/$NEW_USER_PASSWORD" >> /etc/issue
/sbin/ip a| /bin/grep inet| /bin/grep -v -E "inet6|127.0.0.1"| /bin/sed "s/\s*//"|/bin/sed "s/\/24.*//" >>/etc/issue
EOF
	chmod +x /etc/rc.local
	log "Finished configuring local login prompt..."
}

configure_networking () {
	# sets the hostname
	# sets a static IP if a VM (non-EC2)
	log "Configuring network..."
	set -e
	
	if [[ $HOST_TYPE == 'vm' ]] ; then
		log "VM (non-EC2, non-container), assigning static IP"
		# updates hostname, configures static IP if not AWS EC2 instance
		# install necessary tools
		silent_apt_install curl sed
		NEW_FQDN="$NEW_HOSTNAME.$NEW_DOMAIN"
		CURRENT_HOSTNAME=$(hostname)
		# update the current hostname on next boot
		echo "$NEW_FQDN" > /etc/hostname
		# change the hostname in the hosts file too to include both versions
		sed -i "s/$CURRENT_HOSTNAME/$NEW_FQDN $NEW_HOSTNAME/g" /etc/hosts

		# get the current ethernet adapter name
		ETHERNET_ADAPTER=$(ifconfig | grep "Ethernet" | grep -v "docker" | cut --delimiter=" " -f1)

		# get current IP address
		# static name not working
		STARTING_LOCAL_IP=$(ifconfig "$ETHERNET_ADAPTER" | grep "inet addr" | cut --delimiter=":" -f2 | cut --delimiter=" " -f1)

		# get current IP subnet assuming a /24
		IP_PREFIX=$(echo "$STARTING_LOCAL_IP" | cut --delimiter="." -f1-3)

		# Define a static IP for this system
		# TODO: possible replace this with automatic detection of available IP
		STATIC_LOCAL_IP="$IP_PREFIX.9"
		#TODO: output the new IP to the screen so SSH users will know what it is
		# Get current gateway to internet
		GATEWAY_IP=$(route -n | grep 'UG[ \t]' | awk '{print $2}')

		# Get current DNS server, limit 1
		DNS_GATEWAY=$(grep nameserver /etc/resolv.conf | cut --delimiter=" " -f2 | head -n 1)

		# enable static IP, won't set until next boot
		# when this grep is run AFTER docker is installed it's all broken
		echo "
	source /etc/network/interfaces.d/*

	auto lo
	iface l0 inet loopback

	# The primary network interface
	auto $ETHERNET_ADAPTER
	iface $ETHERNET_ADAPTER inet static
	address $STATIC_LOCAL_IP
	netmask 255.255.255.0
	network $IP_PREFIX.0
	broadcast $IP_PREFIX.255
	gateway $GATEWAY_IP
	dns-nameservers $DNS_GATEWAY
	dns-search $NEW_DOMAIN
	" > /etc/network/interfaces

		cat /etc/network/interfaces

	else
		log "EC2 or bare metal, skipping static IP assignment."
		#TODO: set hostname based on tag if permissions allow to see FQDN tag
		# add AWS packages to ensure commands work
	fi
	log "Finished configuring network."

}

install_hostbased_packages () {
	# determines HOST TYPE and installs the right set of packages based on
	# what type of host it is
	log "Installing special packages based on host type: $HOST_TYPE"
	set -e
	
	case $HOST_TYPE in

	  vm)
	    log "Installing VMware virtual machine specific software..."
	    silent_apt_install open-vm-tools
	    ;;

	  ec2)
	    log "Installing AWS EC2 Instance specific software..."
	    silent_apt_install wget
	    wget http://s3.amazonaws.com/ec2metadata/ec2-metadata
		chmod u+x ec2-metadata
		./ec2-metadata --help
	    ;;

	  barebetal)
	   log "Installing Bare Metal/Physical specific software..."
	   #silent_apt_install iostat
	    ;;

	  *)
	    log "Unknown Host Type: $HOST_TYPE"
	    exit 1
	    ;;
	esac
	log "Finished installing special packages based on host type"
}

################################################################################
#		MAIN PROGRAM
################################################################################
log "Starting bootstrap script"

# has to be outside function since it has a lot of output, 
# do not separate the next 2 lines
# TODO: migrate to helper function
log "Starting determine host type"

silent_apt_install curl facter
HOST_TYPE=$(get_host_type)
export HOST_TYPE
log "Host type: $HOST_TYPE"
if [[ "$HOST_TYPE" == "container" ]]; then
	log "This script is not designed for containers. Containers are immutable" 
	exit 1
elif [[ "$HOST_TYPE" =~ ^(ec2|vm|baremetal)$ ]]; then
    log "Host type supported"
else
	log "Host type not supported: $HOST_TYPE"
	exit 1
fi

setup_time_and_sync
log "Date and time updated"

disable_and_stop_apt_updates

# NETWORK SETTINGS
configure_networking

# update and upgrade anything missing right now.
# TODO: migrate to separate function
log "Updating local software from APT repo..."
apt-get -qq -y update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" \
	-o Dpkg::Options::="--force-confold" upgrade
log "Finished upgrading local software from APT repo..."

create_lab_user

# disable firewall
#TODO: check if UFW is installed and disable if so
# TODO: migrate to separate function
ufw disable

# install a bunch of packages
install_apt_tools
install_hostbased_packages

# start and auto-start SSH
# TODO: determine if installed before restarting it
log "Restarting SSH..."
systemctl restart ssh
# it's automatically set to auto-start on boot in Ubuntu after install

# Install AWS Command Line Interface (doesn't have to be in EC2 instance)
install_aws_cli

# install docker
install_docker

# clean up
log "Cleaning up unused packages..."
# can trigger interactive prompts about grub stuff
apt autoremove -y
apt-get clean

# put the IP and default login on the login screen
configure_friendly_login_prompt

cd /home/$NEW_USERNAME || exit
# pull down installers for InsightVM, Collector
download_r7_installers

# NPM installations
# TODO: migrate to separate function

log "Installing NodeJS tools..."
# maybe run this npm install as the lab user, cd ~ first then && 
npm install -y jsonlint swagger-codegen swagger-cli -g
# maybe run this git as the lab user using su -c
# TODO: migrate to separate function
log "Initializing Git..."
git init
chown -R $NEW_USERNAME:$NEW_USERNAME /home/$NEW_USERNAME

# populate the locate database
log "Updating local file system search index..."
updatedb

log "Successfully finished"
log "Issuing reboot to force all changes" 

# reboot, apply any remaining changes, like kernel updates and static IP
reboot now

# TODO: build function to autoresize disk
# resizing EC2 instance's EBS volumes after resizing
#https://stackoverflow.com/questions/11014584/ec2-cant-resize-volume-after-increasing-size
#apt-get install cloud-guest-utils
#growpart /dev/xvda 1
#resize2fs /dev/xvda1