#!/bin/sh
. /bin/gpsconfig.cfg

ReAPMqttGPSSubTopic="Securico/GPS/GPSPeriodicSub"
GPSperiocscript="/bin/GPSPeriodic.sh"

ReAPMqttHost="localhost"
ReAPMqttPort="1883"
ReAPMqttQos="1"

mosquitto_sub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttGPSSubTopic"  -q "$ReAPMqttQos" | while true
do
    read PayLoad
    echo "$PayLoad"
     "$GPSperiocscript" "$PayLoad"
done

