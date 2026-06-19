#!/bin/sh
. /lib/functions.sh

Server="$1"

speedtest-netperf.sh -H "$Server" -t 10 -n 5 

exit 0
