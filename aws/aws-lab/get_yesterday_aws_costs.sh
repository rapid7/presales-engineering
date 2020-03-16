#!/bin/bash
# requires: https://github.com/hjacobs/aws-cost-and-usage-report


~/g_drive/AWS/aws-cost-and-usage-report/aws-cost-and-usage-report.py --days=1
# | grep -v "0.\s*.USD"		# doesn't work, but I was getting close
