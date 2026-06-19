#!/bin/sh

. /lib/functions.sh


getconfigTopic="IOCard1/P530/E/AppDataAlarmRequest"
getconfigMqttMessage="<,12,1,1,1,>"            
ReAPMqttHost="localhost"             
ReAPMqttPort="1883"
ReAPMqttQos="1"


mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$getconfigTopic" -m "$getconfigMqttMessage" -q "$ReAPMqttQos"
