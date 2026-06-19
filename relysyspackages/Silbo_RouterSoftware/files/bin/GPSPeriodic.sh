#!/bin/sh
. /lib/functions.sh
. /bin/gpsconfig.cfg

Payload="$1"

ReAPMqttGPSResponse="Securico/GPS/GPSPeriodicPublish"
ReAPMqttHost="localhost"
ReAPMqttPort="1883"
ReAPMqttQos="1"
gcomGPSScript="/etc/gcom/readgps.gcom"
PingTestScript="/bin/pingTest.sh"

#maxnoofretries=10
#sleepinterval=1
iretries=0

GPSRequestinfo=$(echo "$Payload" | awk -F[,] '{ print $1 }')

EnmComPort=1
ReadModemConfigFile()
{
	modemconfigUCIPath=/etc/config/modemconfig
	modemconfigsection="modemconfig"


	config_load "$modemconfigUCIPath"
	config_get QuectelEC20comport1 "$modemconfigsection" QuectelEC20comport1
	ComPort="/dev/ttyUSB$QuectelEC20comport1"
	echo "ComPort=$ComPort"
}


ReadModemConfigFile

if [ "$GPSRequestinfo" = "$GPSPerRequestMsg" ]
then

	while [ $iretries -le $maxnoofretries ]
	do
        pingtest=$($PingTestScript)
        pingres=$(cat /bin/pingTest.txt)

		if [ "$pingres" = "0" ]
		then
		   gpsdata=$(/usr/bin/gcom -d "$ComPort" -s "$gcomGPSScript")
		    echo "$gpsdata" > "/bin/gpsdata.txt"
		    gpsdata1=$(cat /bin/gpsdata.txt | grep -i "+QGPSLOC:")
		    latitude=$(cat /bin/gpsdata.txt | grep -i "+QGPSLOC:" | awk -F',' '{print $2}')
		    longitude=$(cat /bin/gpsdata.txt | grep -i "+QGPSLOC:" | awk -F',' '{print $3}')
		    altitude=$(cat /bin/gpsdata.txt | grep -i "+QGPSLOC:" | awk -F',' '{print $5}')
		    echo 'latitude="$latitude"'
		    echo 'longitude="$longitude"'
			echo 'altitude="$altitude"'
		    echo 'gpsdata1="$gpsdata1"'
		    mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttGPSResponse" -m "$latitude,$longitude,$altitude" -q "1"
		    break
		else
		   echo "WAN is down"
           sleep $sleepinterval

		fi 
		iretries=$(( $iretries + 1 ))
   done	    

fi
exit 0 
