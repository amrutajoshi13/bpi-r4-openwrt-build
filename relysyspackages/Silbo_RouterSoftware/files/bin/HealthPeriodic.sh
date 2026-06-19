#!/bin/sh
. /lib/functions.sh
. /bin/health.cfg
#Payload="$1"
#echo "Health" >> health.txt
ReAPMqttHealthResponse="Securico/Health/HealthPeriodicPublish"
ReAPMqttHost="localhost"
ReAPMqttPort="1883"
ReAPMqttQos="1"
PingTestScript="/bin/pingTest.sh"

#maxnoofretries=10
#sleepinterval=1
iretries=0

/bin/PeriodicityofHealth.sh

#HealthRequestinfo=$(echo "$Payload" | awk -F[,] '{ print $1 }')

#if [ "$HealthRequestinfo" = "HealthPeriodicReq" ]
#then
    while [ $iretries -le $maxnoofretries ]
	do
        pingtest=$($PingTestScript)
        pingres=$(cat /bin/pingTest.txt)

		if [ "$pingres" = "0" ]
		then
               mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttHealthResponse" -m "$pingres" -q "1"
               break
            else
               #echo "WAN is down" >> health.txt
               sleep $sleepinterval
            fi
            iretries=$(( $iretries + 1 ))

        done        
#fi
exit 0 
