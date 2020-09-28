#!/bin/bash
# Tim H 2018
# Can't remember exact details of use case, this was for a very old POC

export find_string="Asserting MAC address"
export missing_IP_list="missing_Ips.txt"

if [ ! -f "$missing_IP_list" ]; then 
	echo "$missing_IP_list cannot be found"
	exit 1
fi

while IFS= read -r -d '' current_file; do
  #echo "$current_file"
  
  if [ ! -f "$current_file" ]; then 
	echo "ERROR $current_file cannot be found"
	exit 1
  fi
  
  cat "$missing_IP_list" | while read missing_IP
	do
		if grep -q -E "$missing_IP".*DEAD "$current_file"; then
			echo "$current_file,$missing_IP,DEAD"
		else
			if 	grep -q -E "$missing_IP".*"$find_string" "$current_file" ; then
				echo "$current_file,$missing_IP,Live - MAC Found"
			else
				echo "$current_file,$missing_IP,MAC NOT found but not dead either"
			fi
		fi
	done
  
done < <(find . -type f -name "*.log" -print0)
