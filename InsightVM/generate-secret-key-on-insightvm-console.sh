#!/bin/bash
#	Tim H 2022
# Contacts an InsightVM console and generates a shared secret for pairing
# from engine-to-console. short lived secret key is returned in JSON format.
#
# Once you've got the secret key you can use it to pair engine-to-console:
#   https://docs.rapid7.com/insightvm/post-installation-engine-to-console-pairing/
#
# create a new global admin user in InsightVM's web interface and record
# the username and password. Pass these creds to the InsightVM API to 
# authenticate. You'll still need to provide the nexposeCCSessionID and cookie
# headers, but they can be blank like below.
# Reference: 
# https://help.rapid7.com/insightvm/en-us/api/index.html#section/Overview/Authentication
#
# few potential gotchas:
#   * don't forget the --insecure flag if you're using a self-signed cert
#   * InsightVM console defaults to 3780, not 443. Make all API calls to the same port where the web interface is
#   * the InsightVM API uses basic auth, not an API-Key for authentication.
#   * the two cookie headers are required, even if blanked out like in the first example
#   * this is an undocumented private API method and may change in time.

curl --insecure --verbose \
	--user ivm-username-here:passwordhere \
	'https://consoleip:3780/data/admin/global/shared-secret?time-to-live=3600' \
	-X PUT \
	-H 'Accept: application/json' \
	-H 'nexposeCCSessionID: 0000000000000000000000000000000000000000' \
	-H 'Cookie: i18next=en; time-zone-offset=240; nexposeCCSessionID=0000000000000000000000000000000000000000'

# Other option, using real browser cookie:
# You'll need to generate a SessionID in the UI first.

curl --insecure \
	'https://consoleip:3780/data/admin/global/shared-secret?time-to-live=3600' \
	-X PUT \
	-H 'Accept: application/json' \
	-H 'nexposeCCSessionID: D00FF100253548EB9A9EC0A8A13BDC1937C0521B' \
	-H 'Cookie: i18next=en; time-zone-offset=240; nexposeCCSessionID=D00FF100253548EB9A9EC0A8A13BDC1937C0521B'

# example curl call and response.
# curl --insecure --verbose \
# > 'https://REDACTED/data/admin/global/shared-secret?time-to-live=3600' \
# > -X PUT \
# > -H 'Accept: application/json' \
# > -H 'nexposeCCSessionID: D00FF100253548EB9A9EC0A8A13BDC1937C0521B' \
# > -H 'Cookie: i18next=en; time-zone-offset=240; nexposeCCSessionID=D00FF100253548EB9A9EC0A8A13BDC1937C0521B'
# * About to connect() to REDACTED port 443 (#0)
# *   Trying 127.0.0.1...
# * Connected to REDACTED (127.0.0.1) port 443 (#0)
# * Initializing NSS with certpath: sql:/etc/pki/nssdb
# * skipping SSL peer certificate verification
# * SSL connection using TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
# * Server certificate:
# * 	subject: C=US,ST=MA,CN=REDACTED
# * 	start date: Sep 14 00:00:00 2021 GMT
# * 	expire date: Sep 14 12:56:24 2023 GMT
# * 	common name: REDACTED
# * 	issuer: C=US,ST=MA,CN=REDACTED
# > PUT /data/admin/global/shared-secret?time-to-live=3600 HTTP/1.1
# > User-Agent: curl/7.29.0
# > Host: REDACTED
# > Accept: application/json
# > nexposeCCSessionID: D00FF100253548EB9A9EC0A8A13BDC1937C0521B
# > Cookie: i18next=en; time-zone-offset=240; nexposeCCSessionID=D00FF100253548EB9A9EC0A8A13BDC1937C0521B
# > 
# < HTTP/1.1 200 OK
# < X-Frame-Options: SAMEORIGIN
# < X-UA-Compatible: IE=edge,chrome=1
# < X-Content-Type-Options: nosniff
# < X-XSS-Protection: 1; mode=block
# < Cache-Control: no-store, must-revalidate
# < Content-Type: application/json;charset=UTF-8
# < Transfer-Encoding: chunked
# < Vary: Accept-Encoding
# < Date: Thu, 07 Jul 2022 19:49:20 GMT
# < Server: Security Console
# < 
# {
#   "timeToLiveInSeconds" : 3270,
#   "keyString" : "2942-F7FB-7D42-16FA-35E3-1359-DE88-0520"
# }


# How to revoke a shared secret key:
# Change the URL and method.
curl --insecure --verbose \
	--user ivm-username-here:passwordhere \
	'https://CONSOLE_FQDN_OR_IP_HERE:3780/data/admin/global/remove-shared-secret?key-string=9BB1-0855-6B4D-8754-A213-4703-92A4-49EA' \
	-X DELETE \
	-H 'Accept: application/json' \
	-H 'nexposeCCSessionID: 0000000000000000000000000000000000000000' \
	-H 'Cookie: i18next=en; time-zone-offset=240; nexposeCCSessionID=0000000000000000000000000000000000000000'


# Working example of revoking a shared key:
# curl --insecure --verbose \
# > --user svc-autoengine-api:REDACTED \
# > 'https://REDACTED/data/admin/global/remove-shared-secret?key-string=9BB1-0855-6B4D-8754-A213-4703-92A4-49EA' \
# > -X DELETE \
# > -H 'Accept: application/json' \
# > -H 'nexposeCCSessionID: 0000000000000000000000000000000000000000' \
# > -H 'Cookie: i18next=en; time-zone-offset=240; nexposeCCSessionID=0000000000000000000000000000000000000000'
# *   Trying 10.0.1.37:443...
# * Connected to REDACTED (10.0.1.37) port 443 (#0)
# * ALPN, offering h2
# * ALPN, offering http/1.1
# * successfully set certificate verify locations:
# *  CAfile: /etc/ssl/cert.pem
# *  CApath: none
# * (304) (OUT), TLS handshake, Client hello (1):
# * (304) (IN), TLS handshake, Server hello (2):
# * TLSv1.2 (IN), TLS handshake, Certificate (11):
# * TLSv1.2 (IN), TLS handshake, Server key exchange (12):
# * TLSv1.2 (IN), TLS handshake, Server finished (14):
# * TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
# * TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
# * TLSv1.2 (OUT), TLS handshake, Finished (20):
# * TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
# * TLSv1.2 (IN), TLS handshake, Finished (20):
# * SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
# * ALPN, server did not agree to a protocol
# * Server certificate:
# *  subject: CN=REDACTED; ST=MA; C=US
# *  start date: Sep 14 00:00:00 2021 GMT
# *  expire date: Sep 14 12:56:24 2023 GMT
# *  issuer: CN=REDACTED; ST=MA; C=US
# *  SSL certificate verify result: self signed certificate (18), continuing anyway.
# * Server auth using Basic with user 'svc-autoengine-api'
# > DELETE /data/admin/global/remove-shared-secret?key-string=9BB1-0855-6B4D-8754-A213-4703-92A4-49EA HTTP/1.1
# > Host: REDACTED
# > Authorization: Basic REDACTED==
# > User-Agent: curl/7.79.1
# > Accept: application/json
# > nexposeCCSessionID: 0000000000000000000000000000000000000000
# > Cookie: i18next=en; time-zone-offset=240; nexposeCCSessionID=0000000000000000000000000000000000000000
# > 
# * Mark bundle as not supporting multiuse
# < HTTP/1.1 200 OK
# < X-Frame-Options: SAMEORIGIN
# < X-UA-Compatible: IE=edge,chrome=1
# < X-Content-Type-Options: nosniff
# < X-XSS-Protection: 1; mode=block
# < Set-Cookie: nexposeCCSessionID=7E1D4E1684CE7CCE9618B8608C0B9B929312F406; Path=/; Secure; HttpOnly
# < Cache-Control: no-store, must-revalidate
# < Content-Length: 0
# < Date: Thu, 07 Jul 2022 20:14:10 GMT
# < Server: Security Console
