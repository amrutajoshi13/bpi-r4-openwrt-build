#!/bin/sh

#
# Mosquitto Configuration
#
host="localhost"
port="1883"
qos="1"

if [ $# -eq 0 ]
then
    echo "invalid arguments"
    exit 1
fi

RebootType=$1

if [ "$RebootType" = "Hardware" ]
then
    topic="IOCard1/AI2DI4DO4_SG200/IREQ/Command"
    message="<,SYS_REBOOT=1,1777,>"
elif [ "$RebootType" = "Software" ]
then
    topic="IOCard1/AI2DI4DO4_SG200/IREQ/Command"
    message="<,SYS_REBOOT=2,1777,>" 
else
    echo "invalid arguments"
    exit 1
fi

#
# Publish data
#
mosquitto_pub -t "$topic" -m "$message"  -q "$qos" -h "$host" -p "$port"
echo "published data \"$message\""
exit 0
