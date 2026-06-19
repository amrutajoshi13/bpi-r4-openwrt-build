
#!/bin/sh

filename="/etc/snmp/modem1_sim2_info.txt"

# Check if the file exists
if [ ! -f "$filename" ]; then
    echo "Error: File '$filename' not found."
    exit 1
fi

# Prompt the user for input
keyword="$1"

# Use grep to search for lines containing the keyword in the file
result=$(grep "$keyword" "$filename")

# Check if any matching lines were found
if [ -n "$result" ]; then
    echo "$result"
else
    #echo "No matching lines found for '$keyword' in '$filename'."
    echo "$keyword=NA"
fi
