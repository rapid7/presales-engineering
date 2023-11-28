#!/bin/bash
# Tim H 2022

# forked Howe's IAS migration script

cd ~/source_code || exit 1
git clone https://github.com/THE-MOLECULAR-MAN/IAS_Migration_Tool.git

cd IAS_Migration_Tool || exit 2

vim migration_tool.py 
# original: be85c065-1111-1111-1111-609e517193d3
# destination: c2efcb6a-2222-2222-2222-9b92f3ff2578

# sudo apt-get -y install pylint
# HOMEBREW_NO_AUTO_UPDATE=1 brew install pylint

pylint *.py

# take care of dependencies
/Library/Developer/CommandLineTools/usr/bin/python3 -m pip install --upgrade pip
/usr/bin/python3 -m pip install --upgrade pip
/usr/bin/python3 -m pip install requests
/usr/bin/python3 -m pip install autopep8

autopep8 --in-place --aggressive --aggressive migration_tool.py
autopep8 --in-place --aggressive --aggressive customer.py

/usr/bin/python3 migration_tool.py
