#!/bin/bash
# Tim H 2019
# TODO: migrate to private repo
yum update -y
aws s3 sync --delete s3://ha-training-wordpress-code /var/www/html
