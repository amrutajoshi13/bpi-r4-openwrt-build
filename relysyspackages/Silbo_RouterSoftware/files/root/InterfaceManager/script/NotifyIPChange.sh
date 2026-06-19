#!/bin/sh

. /lib/functions.sh

#
# PKG_RELEASE: 1.01
#

#
# Verify input parameters
#
InterfaceStatus="$1"
InterfaceSection="$2"
IPChangeEvent="$3"
InterfaceIP="$4"
ModemConfigFile="modem"

if [ "x$InterfaceStatus" = "x" ] || [ "x$InterfaceSection" = "x" ] 
then
        logger -t "NotifyIPChange" "Empty Parameters - InterfaceStatus=$InterfaceStatus InterfaceSection=$InterfaceSection"
        exit 1
fi

if [ "$InterfaceStatus" = "up" ] && ( [ "x$InterfaceIP" = "x" ] || [ "x$IPChangeEvent" = "x" ] )
then
        logger -t "NotifyIPChange" "Empty Parameters - InterfaceIP=$InterfaceIP IPChangeEvent=$IPChangeEvent"
        exit 1
fi

#
# Read Configurations
#
OutgoingSMSDir="/root/sms/outgoing/"
InterfaceManagerTmpDir="/tmp/InterfaceManager/"
InterfaceManagerTmpConfigDir="$InterfaceManagerTmpDir""config/"
InterfaceConfigFile="$InterfaceManagerTmpConfigDir""$InterfaceSection"".cfg"
. "$InterfaceConfigFile"

config_load "$ModemConfigFile"
config_get PhoneNumber "$InterfaceSection" phonenumber
config_get ServerLoginUser "$InterfaceSection" serverloginuser
config_get ServerLoginPass "$InterfaceSection" serverloginpass
config_get ServerURL "$InterfaceSection" serverurl
config_get SMSDeviceID "WAN1" smsdeviceid


PortConfigFile="/tmp/InterfaceManager/status/""$InterfaceSection"".smsport"
if [ -f "$PortConfigFile" ]
then
    SMSPort=$(sed -n "/^\<SMSPort\>/p" "$PortConfigFile" 2>&1 | cut -d "=" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//' 2>&1)
    if [ "x$SMSPort" = "x" ]
    then
        logger -t "NotifyIPChange" "SMSPort not found"
        exit 1
    fi
else
    logger -t "NotifyIPChange" "port file '$PortConfigFile' file not found"
    exit 1
fi

if echo  "$InterfaceStatus" | grep -qi "up" 
then
        if [ "$SMSEnable" = "1" ] && [ "$IfaceUpSMSNotify" = "1" ]
        then
                logger -t "NotifyIPChange" "Sending IP $InterfaceIP to PhoneNumber $PhoneNumber"
                # Create SMS and place it in outgoing directory of smsd
                SysTime=$(date +"%F %T")
                IPmsg="{\"deviceid\":\"$SMSDeviceID\",\"$InterfaceSection\":[\"$InterfaceIP\",\"$IPChangeEvent\",\"$SysTime\"]}"
                currentDate=$(date +"%g%m%d_%H%M%S")
                OutgoingSMSFile=$(mktemp "$OutgoingSMSDir""$currentDate""_"XXXXXX)
                rm -f "$OutgoingSMSFile"
                {
                        echo "To: $PhoneNumber"
                        echo "" 
                        echo "$IPmsg"
                } > "$OutgoingSMSFile"".sms"
        fi
        
        if [ "$IfaceUpHTTPNotify" = "1" ]
        then
                logger -t "NotifyIPChange" "Posting IP $InterfaceIP to URL $ServerURL"
                # Create Post Data and send to Back-end server (Need to be changed)
                SysTime=$(date +"%F %T")
                IPmsg="{\"code\":0,\"deviceid\":\"$SMSDeviceID\",\"$InterfaceSection\":[\"$InterfaceIP\",\"$IPChangeEvent\",\"$SysTime\"]}"
                if [ "x$ServerLoginUser" != "x" ] && [ "x$ServerLoginPass" != "x" ]
                then
                        curl -d "$IPmsg" -u "$ServerLoginUser:$ServerLoginPass" "$ServerURL"
                else
                        curl -d "$IPmsg" "$ServerURL"
                fi
        fi

elif echo  "$InterfaceStatus" | grep -qi "down" 
then
        if [ "$SMSEnable" =  "1" ] && [ "$IfaceDownSMSNotify" = "1" ]
        then
                logger -t "NotifyIPChange" "Sending IP Down status to PhoneNumber $PhoneNumber"
                # Create SMS and place it in outgoing directory of smsd
                SysTime=$(date +"%F %T")
                IPmsg="{\"deviceid\":\"$SMSDeviceID\",\"$InterfaceSection\":[\"down\",\"$IPChangeEvent\",\"$SysTime\"]}"
                currentDate=$(date +"%g%m%d_%H%M%S")
                OutgoingSMSFile=$(mktemp "$OutgoingSMSDir""$currentDate""_"XXXXXX)
                rm -f "$OutgoingSMSFile"
                {
                        echo "To: $PhoneNumber"
                        echo "" 
                        echo "$IPmsg"
                } > "$OutgoingSMSFile"".sms"
        fi
fi


exit 0
