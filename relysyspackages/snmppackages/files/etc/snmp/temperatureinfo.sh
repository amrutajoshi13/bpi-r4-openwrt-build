#!/bin/sh

file="/etc/snmp/temperatureinfo.txt"  # Input file name
search_string="$1"  # String to search for

# Check if the file exists
if [ ! -e "$file" ]; then
    echo "File does not exist."
    exit 1
fi

# Check if the search string is provided
if [ -z "$search_string" ]; then
    echo "No search string provided."
    exit 1
fi

# Search for the string in the file and output the corresponding value
value=$(awk -F '=' -v key="$search_string" '$1 == key { print $2 }' "$file")

if [ -z "$value" ]; then
    #echo "Search string '$search_string' not found."
    echo "$search_string=NA"
else
    echo "$search_string=$value"
fi
exit 0
