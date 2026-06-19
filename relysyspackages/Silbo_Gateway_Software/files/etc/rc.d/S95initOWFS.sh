#!/bin/sh /etc/rc.common
#
# OWFS Temperature sensor

# shellcheck disable=SC2034
START=95
STOP=95
USE_PROCD=1
#PROG="/usr/sbin/openwisp-monitoring"
#PROG_NAME="OpenWISP monitoring daemon"

start_service() {
	# for openwisp-config
	echo "Starting OWFS App"
         if [ -d "/reap/1wire" ]
         then
             owfs --i2c=/dev/i2c-0 --allow_other /reap/1wire/ --timeout_volatile=0
         else
             mkdir /reap/1wire
             owfs --i2c=/dev/i2c-0 --allow_other /reap/1wire/ --timeout_volatile=0
         fi
}

stop_service() {
	echo "Stopping OWFS Apps"
	killall -9 owfs
}

