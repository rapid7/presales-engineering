#!/bin/bash
# Tim H 2020
# Installing InsightCloudSec on Ubuntu 20.04
# Most relevant: https://docs.divvycloud.com/docs/linux-test-drive-deployment

# 16 GB RAM, 4 cores, 40 GB storage

curl -s https://s3.amazonaws.com/divvypreflight/preflight.sh | sudo bash

curl -s https://s3.amazonaws.com/get.divvycloud.com/testdrive/testdrive.sh | sudo bash

docker ps

