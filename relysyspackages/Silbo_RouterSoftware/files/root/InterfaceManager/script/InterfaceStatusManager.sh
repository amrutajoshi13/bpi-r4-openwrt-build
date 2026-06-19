#!/bin/sh

if [ "$#" != "2" ]
then
    echo "Usage: $0 <Interface Name> <PayLoad>"
    exit 1
fi

Interface="$1"
PayLoad="$2"

ReAPMqttHost="localhost"
ReAPMqttSrcId="CN01-AI2DI4DO4_SG200"
ReAPMqttEventType="NWK"
ReAPMqttEventName="3G"
ReAPMqttPort="1883"
ReAPMqttQos="1"
ReAPMqttNWKeventPubTopic="IOCard1/AI2DI4DO4_SG200/W/${Interface}/NWKevent"
ReAPMqttActionManagerPubTopic="IOCard1/AI2DI4DO4_SG200/W/${Interface}/ActionManager"

InterfaceManagerTmpDir="/tmp/InterfaceManager/"
InterfaceManagerTmpStatusDir="${InterfaceManagerTmpDir}status/"
InterfaceStatusFile="$InterfaceManagerTmpStatusDir${Interface}.StatusManagerstatus"
NotifyIPChangeInfoFile="${InterfaceManagerTmpStatusDir}${Interface}.NotifyIPChangeInfo"

NotifyIPChangeScript="/root/InterfaceManager/script/NotifyIPChange.sh"
IPDownSMSNotifyFile="${InterfaceManagerTmpDir}${Interface}.IPDown"

InterfaceManagerAnalyticsDir="/tmp/InterfaceManager/analytics/"
SmAnalyticsFile="${InterfaceManagerAnalyticsDir}${Interface}SmAnalytics"
LogrotateConfigFile="/etc/logrotate.d/${Interface}LogrotateConfig"

InterfaceManagerTmpConfigDir="${InterfaceManagerTmpDir}config/"
InterfaceConfigFile="${InterfaceManagerTmpConfigDir}${Interface}.cfg"

ActionManagerArgsFile="${InterfaceManagerTmpDir}${Interface}.NotifyIPChangeArgsFile"

. "$InterfaceConfigFile"

#start of script
if [ ! -d "$InterfaceManagerTmpStatusDir" ]
then
        mkdir -p "$InterfaceManagerTmpStatusDir"
fi

PublishNWKEvent()
{
    ReAPMqttEventValue="$InterfaceStatus"
    CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
    ReAPMqttMsg="<,$ReAPMqttSrcId,$ReAPMqttEventType,$ReAPMqttEventName,$ReAPMqttEventValue,$CurrentDate,>"
    output=$(mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttNWKeventPubTopic" -m "$ReAPMqttMsg" -q $ReAPMqttQos)
    retval=$?
}

PublishToActionManager()
{
    if [ "$InterfaceStatus" = "DN" ]
    then
        CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
        ReAPMqttMsg="<,$ReAPMqttSrcId,$PayLoadIPAddress,$PingTestRetVal,$CurrentDate,>"
        output=$(mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttActionManagerPubTopic" -m "$ReAPMqttMsg" -q $ReAPMqttQos)
        retval=$?      
    fi
}
           
########################################################################
#       name:
#               StatusLog
#
#       Description:
#               writing status log messages into particular file.
#
#       Global:
#
#       Arguments:
#
#       Returns:
########################################################################
StatusLog()
{
    if [ "$LogAnalytics" = "1" ]
    then
        ActionPerformed="$1"
        if echo "$ActionPerformed" | grep -qE "^ModemRecycle$|^BoardRecycle$|^actionsfailure$"
        then
            ActionPerformedTime="$ActionExecuteTime"
        else
            ActionPerformedTime="-"
        fi
                
        local CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")

echo "{\"LT\":\"$CurrentDate\",\"IF\":\"$Interface\",\"IP\":\"$PayLoadIPAddress\",
\"AP\":\"$ActionPerformed\",\"APT\":\"$ActionPerformedTime\"
}"  >> "$SmAnalyticsFile"

        logrotate "$LogrotateConfigFile"
    fi
}


GetActionCommand()
{
    IPAddress="$1"

    if [ -s "$ActionManagerArgsFile" ]
    then
        ActionExecuteTime=$(sed -n "/^\<ActionExecuteTime\>/p" "$ActionManagerArgsFile"  2>&1 | cut -d "=" -f 2 2>&1| sed 's/^[ \t]*//;s/[ \t]*$//' 2>&1)
        ActionCommand=$(sed -n "/^\<ActionCmd\>/p" "$ActionManagerArgsFile"  2>&1 | cut -d "=" -f 2 2>&1| sed 's/^[ \t]*//;s/[ \t]*$//' 2>&1)
        rm -f "$ActionManagerArgsFile"
    elif [ ! -s "$NotifyIPChangeInfoFile" ]
    then
        ActionCommand="auto"
    else
        IPAddressInNotifyIPChangeInfoFile=$(sed -n "/^\<IPAddress\>/p" "$NotifyIPChangeInfoFile"  2>&1 | cut -d "=" -f 2 2>&1| sed 's/^[ \t]*//;s/[ \t]*$//' 2>&1)
        if [ "$IPAddressInNotifyIPChangeInfoFile" = "$IPAddress" ]
        then
            ActionCommand="connected"
        else
            ActionCommand="auto"
        fi
    fi   
}
########################################################################
#       name:
#               NotifyIPChange
#
#       Description:
#               If ForceIPChangeFile exists then changes interface's ip
#               by making interface go down and up, else calls notifyipchange
#               script based ip available status.
#
#
#       Global:
#               None
#
#       Arguments:
#               ActionCommand     (The command which is responsible for
#                                 IP Change/UP)
#
#       Returns:
#               None
#
########################################################################
NotifyIPChange ()
{
    NotifyInterfaceStatus="$1" 
    if [ "$NotifyInterfaceStatus" = "up" ]
    then
        rm -f "$IPDownSMSNotifyFile"
        if [ "$ActionCommand" != "connected" ]
        then
            echo "IPAddress=$IPAddress" > "$NotifyIPChangeInfoFile"
            "$NotifyIPChangeScript" "up" "$Interface" "$ActionCommand" "$IPAddress" > /dev/null 2>&1 &
        fi
    elif [ "$NotifyInterfaceStatus" = "actionsfailure" ]
    then
        if [ ! -f "$IPDownSMSNotifyFile" ]
        then
            IPDownTime=$(date +"%F %T")
            echo "[$IPDownTime] $Interface-IP Down" > "$IPDownSMSNotifyFile"
            "$NotifyIPChangeScript" "down" "$Interface" "$actionsfailure" > /dev/null 2>&1 &
        fi
    fi
}

ReqToPublishSStoLCD()
{
    ReAPMqtttopic="IOCard1/AI2DI4DO4_SG200/W/${Interface}/IREQ/ss"
    CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")

    ReAPMqttHost="localhost"
    ReAPMqttPort="1883"
    ReAPMqttAppId="3"
    ReAPMqttMsg="<,$ReAPMqttAppId,ss,$CurrentDate,>"
    ReAPMqttQos=1

    output=$(mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqtttopic" -m "$ReAPMqttMsg" -q "$ReAPMqttQos")
    retval=$?
}

#start of script

PayLoadInterfaceStatus=$(echo "$PayLoad" | awk -F[,] '{ print $3 }')

if echo "$PayLoadInterfaceStatus" | grep -qE "^ifdown$|^DN$"
then
    if [ "$PayLoadInterfaceStatus" = "DN" ]
    then
        PayLoadIPAddress=$(echo "$PayLoad" | awk -F[,] '{ print $4 }')
        PingTestRetVal=$(echo "$PayLoad" | awk -F[,] '{ print $5 }')
    else
        PayLoadIPAddress="-"
        PingTestRetVal="-"
    fi
    InterfaceStatus="DN"
    StatusLog "down"
elif echo "$PayLoadInterfaceStatus" | grep -qE "^UP$"
then
    InterfaceStatus="UP"
    PayLoadIPAddress=$(echo "$PayLoad" | awk -F[,] '{ print $4 }')
    GetActionCommand "$PayLoadIPAddress"
    NotifyIPChange "up"
    StatusLog "$ActionCommand"
elif echo "$PayLoadInterfaceStatus" | grep -qE "^actionsfailure$"
then
    ActionExecuteTime=$(echo "$PayLoad" | awk -F[,] '{ print $4 }')
    NotifyIPChange "PayLoadInterfaceStatus" "$AFActionExecuteTime"
    StatusLog "$PayLoadInterfaceStatus" "$ActionExecuteTime"
else
    exit 0
fi
    
#writting nwk status
echo "InterfaceStatus=$InterfaceStatus" > "$InterfaceStatusFile"
echo "PayLoadIPAddress=$PayLoadIPAddress" >> "$InterfaceStatusFile"
echo "PingTestRetVal=$PingTestRetVal" >> "$InterfaceStatusFile"
   
#publishing nwkevent to Consolidator, DisplayClient
PublishNWKEvent

#publishing to ActionManager
PublishToActionManager

#publishing signal strength to lcd
if [ "$PayLoadInterfaceStatus" != "UP" ]
then
    ReqToPublishSStoLCD
fi
exit 0
