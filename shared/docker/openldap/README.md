# OpenLDAP Docker Container
### About
This `README.md` will help assist with the configuration and deployment of an OpenLDAP Docker container.  This container will be prepopulated with data to allow for immediate use with the Nexpose console.  Once the container is started, it can be used for the LDAP/AD Autentication Source of Nexpose.  In addition, this container can be leverage when testing, enhancing, or creating new Nexpose/LDAP integrations.

### Prerequisites
Prior to building or running any Docker container, you must first install a virtualized environment to replicate the linux kernel - unless you are on a linux based OS (MacOS doesn't count).  To easily get going, run the following script to install Docker for Mac:
https://github.com/rapid7/pso/blob/master/projects/docker/installDockerForMac.sh

NOTE: if the docker-compose.yml and ldif directory are located outside of /Users, /Volumes, /tmp, or /private on your machine, you will need to add an additional "File Sharing" directory within Docker for Mac.  This can be done by opening Docker for Mac preferences --> File Sharing --> Add an additional directory --> Restart Docker for Mac.

NOTE: if using Ubuntu 16.4 default docker-compose version is to old, install a newer version:
curl -L https://github.com/docker/compose/releases/download/1.8.0/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

### Getting Started
Once Docker for Mac is started, navigate to the pso/projects/docker/openldap/ directory (where this README exists) and run the following command:
```
docker-compose up
```

Docker Compose will then execute the following steps:


1. Pull and start the public Docker container being used (Documentation located at https://hub.docker.com/r/dinkel/openldap/)
2. Expose ports 389 and 636
3. Set the LDAP base for the tree to "dc=rapid7,dc=com"
4. Create the admin user with a DN of "cn=admin,dc=rapid7,dc=com" and password of "password"
5. Mount and run the prepopulated ldifs (ldif/prepopulate/1-users.ldif and ldif/prepopulate/2-groups.ldif) to generate users, groups, and group memberships

### Connecting from Nexpose Console
With Docker for Mac, the OpenLDAP container will be running locally on ports 389 and 636 which makes console configuration very simple.  While creating a new LDAP/AD Authenticaiton Source, the following configurations can be used.

###### SOURCE CONFIGURATION
| Setting                | Value |
| ---------------------- | ----- |
| Name                   | OpenLDAP  |
| Server name            | 127.0.0.1 |
| Port                   | 389       |
| Authentication Methods | SIMPLE |
| LDAP search base       | ou=users,dc=rapid7,dc=com |

###### ATTRIBUTE MAPPINGS
| Setting       | Value |
| ------------- | ----- |
| Login ID      | uid   |
| Full name     | cn    |
| Email address | mail  |

### Prepopulated Data
All users as part of the prepopulated data have the password set to "password".  A list of the provided users can be found below:


| Username       | Password |
| -------------- | -------- |
| nxuser1        | password |
| nxuser2        | password |
| nxuser3        | password |
| sprefontaine   | password |
| swilliams      | password |
| djeter         | password |
| hsolo          | password |
| bpapi          | password |
