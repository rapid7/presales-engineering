#!/bin/bash
yum update -y
aws s3 sync --delete s3://ha-training-wordpress-code /var/www/html
