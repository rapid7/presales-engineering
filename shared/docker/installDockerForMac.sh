#!/bin/bash

DOWNLOAD_DIR=/tmp
DOCKER_MOUNT=/Volumes/Docker

curl -o $DOWNLOAD_DIR/Docker.dmg https://download.docker.com/mac/stable/Docker.dmg

printf "Mounting $DOCKER_MOUNT\n"
hdiutil attach $DOWNLOAD_DIR/docker.dmg &>/dev/null

printf "Installing Docker for Mac application\n"
cp -r $DOCKER_MOUNT/Docker.app $DOCKER_MOUNT/Applications/

printf "Detaching $DOCKER_MOUNT volume\n"
hdiutil detach $DOCKER_MOUNT &>/dev/null

rm $DOWNLOAD_DIR/Docker.dmg

printf "Starting Docker Application..."
open -a Docker
printf "Docker started!\n"
