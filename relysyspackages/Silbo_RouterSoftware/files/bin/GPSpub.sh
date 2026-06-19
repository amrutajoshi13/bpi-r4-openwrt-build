#!/bin/sh

. /lib/functions.sh

mosquitto_pub -d -t "Securico/GPS/GPSPeriodicSub" -m "GPSPeriodicReq"
#echo "Hello" >> /root/test.txt
exit 0
