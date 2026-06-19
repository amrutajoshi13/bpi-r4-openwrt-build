#!/bin/sh

. /lib/functions.sh

res=$(/usr/bin/sendsms "$1" "$2" 2>&1)
echo "SMS Sent"

exit 0
