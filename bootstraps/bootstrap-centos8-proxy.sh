#!/bin/bash
# Tim H 2020
# bootstrap for CentOS 8
# installs Squid proxy
#
#	References:
#		https://www.tecmint.com/install-squid-http-proxy-on-centos-7/
#		https://linuxize.com/post/how-to-install-and-configure-squid-proxy-on-debian-10/
#		https://www.ibm.com/support/knowledgecenter/SS42VS_DSM/com.ibm.dsm.doc/t_DSM_guide_Squid_syslog.html
#		http://www.squid-cache.org/Doc/config/access_log/
#		https://elatov.github.io/2019/01/using-squid-to-proxy-ssl-sites/
#		https://wiki.squid-cache.org/Features/DynamicSslCert
yum -y update
yum -y install squid
systemctl start squid
systemctl enable squid
systemctl status squid

#    Squid configuration file: /etc/squid/squid.conf
#    Squid Access log: /var/log/squid/access.log
#    Squid Cache log: /var/log/squid/cache.log

cp /etc/squid/squid.conf /etc/squid/squid.conf.backup

vim /etc/squid/squid.conf 
# make changes in here to allow certain hosts on your network

systemctl restart squid

# it's blocked on the firewall by default
systemctl status firewalld
service firewalld stop
systemctl disable firewalld

tail -f /var/log/squid/access.log
#access_log udp://192.168.4.63:514
#vim /etc/httpd/conf.d/squid.conf
#    Allow from 10.0.0.1/24

# example:
# access_log udp://10.0.1.33:6677 squid

# SSL setup
cp /etc/squid/squid.conf /etc/squid/squid.conf.working_http
openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout squid-ca-key.pem -out squid-ca-cert.pem

cat squid-ca-cert.pem squid-ca-key.pem > squid-ca-cert-key.pem

mkdir /etc/squid/certs
mv squid-ca-cert-key.pem /etc/squid/certs/.
chown squid:squid -R /etc/squid/certs

# make the SSL changes
vim /etc/squid/squid.conf 

# verify before restarting service
squid -k parse

/usr/lib64/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 4MB
chown squid:squid -R /var/spool/squid/ssl_db

grep -n "ssl_db" /etc/squid/squid.conf
# line 79 needs to be changed to support proper directory
vim /etc/squid/squid.conf 

# check for errors and warnings, have to redirect stderr too
squid -k parse 2> >(grep -i -e "warning\|error")
systemctl restart squid
systemctl status squid

# test SSL from a different system
# this should give an error first time
curl --proxy http://10.0.1.36:3128 https://google.com

# you should see your SSL proxy cert, not Rapid7
openssl s_client -proxy 10.0.1.36:3128 -connect endpoint.ingress.rapid7.com:443
