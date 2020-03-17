#!/bin/bash
#	
#	Finds all my bash scripts and scans them for syntax errors and problems
#
set -e
#SOURCE_CODE_PATH=$(pwd)

find ".." -type f -iname '*.sh' -not -path "*Lab_Builder*"  -exec shellcheck {} \;
