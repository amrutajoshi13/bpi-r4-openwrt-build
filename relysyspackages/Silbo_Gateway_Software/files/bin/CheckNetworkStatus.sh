#!/bin/bash

# Check if an IP address is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <IP_ADDRESS>"
  exit 1
fi

IP_ADDRESS=$1

# Ping the IP address 5 times
ping_result=$(ping -c 5 "$IP_ADDRESS")

# Check how many pings were successful
success_count=$(echo "$ping_result" | grep -c 'time=')

# Calculate success rate (70% of 5 pings = 3.5, rounded to 4)
if [ "$success_count" -ge 4 ]; then
  echo "1" > /tmp/networkstatus
else
  echo "Ping was not successful enough"
  echo "0" > /tmp/networkstatus
fi

exit 0
