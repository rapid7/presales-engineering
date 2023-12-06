#!/bin/bash
# Tim H 2022
# Find the Rapid7 Insight agent guid on Linux and OS X

find /opt/rapid7/ir_agent -type f -exec grep --with-filename --colour=yes -I Client-ID {} \; | sort --unique
