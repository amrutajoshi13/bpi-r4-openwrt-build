#!/bin/sh

. /lib/functions.sh

if [ "$#" != "2" ]
then
    echo "Usage: $0 <Interface Name> <PayLoad>"
    exit 1
fi

ReadSystemGpioFile()
{
   	config_load "$SystemGpioConfig"
	config_get SimSelectGpio gpio simselectgpio
	config_get Sim1SelectValue gpio sim1selectvalue
	config_get Sim2SelectValue gpio sim2selectvalue
}

SystemGpioConfig="/etc/config/systemgpio"


ReadSystemGpioFile

Interface="$1"
PayLoad="$2"

ReAPMqttHost="localhost"
ReAPMqttPort="1883"
ReAPMqttQos="1"
ReAPMqttActionsFailurePubTopic="IOCard1/AI2DI4DO4_SG200/W/${Interface}/ActionsFailure"
ReAPMqttAmPingStatusPubTopic="IOCard1/AI2DI4DO4_SG200/W/${Interface}/AmPingTest"

ModemConfigFile="/etc/config/modem"

WaitSleepInterval="60"
SleepAfterIfDown="5"

InterfaceManagerTmpDir="/tmp/InterfaceManager/"

InterfaceManagerTmpStatusDir="${InterfaceManagerTmpDir}status/"
InterfaceStatusFile="${InterfaceManagerTmpStatusDir}${Interface}.StatusManagerstatus"

InterfaceManagerTmpConfigDir="${InterfaceManagerTmpDir}config/"
InterfaceConfigFile="${InterfaceManagerTmpConfigDir}${Interface}.cfg"

InterfaceManagerAnalyticsDir="/tmp/InterfaceManager/analytics/"
AmAnalyticsFile="${InterfaceManagerAnalyticsDir}${Interface}AmAnalytics"

LogrotateConfigFile="/etc/logrotate.d/${Interface}LogrotateConfig"

NotifyIPChangeArgsFile="${InterfaceManagerTmpDir}${Interface}.NotifyIPChangeArgsFile"

. "$InterfaceConfigFile"

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
                if echo "$ActionPerformed" | grep -qE "^ModemRecycle$|^SimSwitch$|^BoardRecycle$|^actionsfailure$"
                then
                    ActionPerformedTime="$2"
                else
                    ActionPerformedTime="-"
                fi

                local CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")

echo "{\"LT\":\"$CurrentDate\",\"IF\":\"$InterfaceName\",\"AP\":\"$ActionPerformed\",\
\"APT\":\"$ActionPerformedTime\"}"  > "$AmAnalyticsFile"

                logrotate "$LogrotateConfigFile"
        fi
}


########################################################################
#       name:
#               ExecuteCommand
#
#       Description:
#               executes the utility mentioned in configuration
#
#       Global:
#
#       Arguments: Action command number to be executed
#
#       Returns:
#               none
#
########################################################################
ExecuteCommand()
{
    local Action=$1
    case $Action in

        "ModemRecycle")
            ifdownOut=$(ifdown "$Interface" 2>&1)
            sleep $SleepAfterIfDown
            ActionExecuteTime=$(date +"%Y-%m-%d %H:%M:%S")
            CmdOut=$(ubus call interfacemanager recycle {\"interface\":\"$Interface\"} 2>&1)
            CmdRetVal=$?
            
            if [ "x$FirstCmdExecutionTime" = "x" ]
            then
                FirstCmdExecutionTime=$ActionExecuteTime
            fi
            ;;

        "SimSwitch")
            ifdownOut=$(ifdown "$Interface" 2>&1)
            sleep $SleepAfterIfDown
            ActionExecuteTime=$(date +"%Y-%m-%d %H:%M:%S")
            if [ ! -f "$SimNumFile" ]
            then
                touch "$SimNumFile"
                echo 2 > "$SimNumFile"
                echo "$Sim2SelectValue" > "$SimSwitchingGpio"
            else
                sim=`cat "$SimNumFile"` 
		if [ "$sim" = "1" ]
		then
	           echo "2" > "$SimNumFile"
		   echo "$Sim2SelectValue" > "$SimSwitchingGpio"
		else
	        echo "1" > "$SimNumFile"
	        echo "$Sim1SelectValue" > "$SimSwitchingGpio"
	     fi
             fi        
            CmdOut=$(ubus call interfacemanager recycle {\"interface\":\"$Interface\"} 2>&1)
            CmdRetVal=$?
            
            if [ "x$FirstCmdExecutionTime" = "x" ]
            then
                FirstCmdExecutionTime=$ActionExecuteTime
            fi
            ;;

        "BoardRecycle")
            #ActionExecuteTime=$(date +"%Y-%m-%d %H:%M:%S")
            ##write status log before executing the recycle command
            #StatusLog "BoardRecycle" "$ActionExecuteTime"
            #CmdOut=$(ubus call command execute {\"command\":\"reboot\",\"arguments\":\"hardware\"} 2>&1)
            #CmdRetVal=$?

            if [ "x$FirstCmdExecutionTime" = "x" ]
            then
                FirstCmdExecutionTime=$ActionExecuteTime
            fi
            ;;
        *)
            ;;
    esac

}

########################################################################
#       name:
#               PerformAction
#
#       Description:
#               performing action based on configurations and calls InterfaceTest() to
#               check action success/failure, if failure it retries again based on retry count
#
#       Global:
#
#
#       Arguments:
#
#       Returns:
#               0 - on success
#               1 - on failure
#
########################################################################
PerformAction()
{
    ActionRetryCount=1
    ActionSleepCount=0

    if [ "$Action1Enable" = "1" ]
    then
        Action1Sleep=$(($Action1WaitInterval / $IfaceQueryInterval))
        while [ "$ActionRetryCount" -le "$Action1Retry" ]
        do
            ExecuteCommand "$Action1Cmd"
            {
                echo "ActionExecuteTime=$ActionExecuteTime"
                echo "ActionCmd=$Action1Cmd"
            } > "$NotifyIPChangeArgsFile"
            while [ $ActionSleepCount -lt $Action1Sleep ]
            do
                sleep "$IfaceQueryInterval"
                ActionSleepCount=$((ActionSleepCount + 1))
                InterfaceStatus=$(cat $InterfaceStatusFile | grep "InterfaceStatus" | awk -F[=] '{ print $2 }')
                
                if [ "$InterfaceStatus" = "UP" ]
                then
                    StatusLog "$Action1Cmd" "$ActionExecuteTime"
                    return 0
                fi
            done
            ActionSleepCount=0
            ActionRetryCount=$((ActionRetryCount + 1))
        done
    fi
    
    ActionSleepCount=0

    if [ "$Action2Enable" = "1" ]
    then
      InterfaceManagerConfigFile="/etc/config/modem"
      config_load "$InterfaceManagerConfigFile"
      config_get NumSim "$Interface" numsim
      if [ "$NumSim" = "2" ]
      then
        Action2Sleep=$(($Action2WaitInterval / $IfaceQueryInterval))
            ExecuteCommand "$Action2Cmd"
            {
                echo "ActionExecuteTime=$ActionExecuteTime"
                echo "ActionCmd=$Action2Cmd"
            } > "$NotifyIPChangeArgsFile"
            while [ $ActionSleepCount -lt $Action2Sleep ]
            do
                sleep "$IfaceQueryInterval"
                ActionSleepCount=$((ActionSleepCount + 1))
                
                
                InterfaceStatus=$(cat $InterfaceStatusFile | grep "InterfaceStatus" | awk -F[=] '{ print $2 }')
                        
                if [ "$InterfaceStatus" = "UP" ]
                then
                    StatusLog "$Action2Cmd" "$ActionExecuteTime"
                    return 0
                fi
            done
            ActionSleepCount=0
    fi
    fi

    ActionRetryCount=1
    ActionSleepCount=0

    if [ "$Action3Enable" = "1" ]
    then
        Action3Sleep=$(($Action3WaitInterval / $IfaceQueryInterval))
        while [ "$ActionRetryCount" -le "$Action3Retry" ]
        do
            ExecuteCommand "$Action3Cmd"
            {
                echo "ActionExecuteTime=$ActionExecuteTime"
                echo "ActionCmd=$Action3Cmd"
            } > "$NotifyIPChangeArgsFile"
            while [ $ActionSleepCount -lt $Action3Sleep ]
            do
                sleep "$IfaceQueryInterval"
                ActionSleepCount=$((ActionSleepCount + 1))
                                
                InterfaceStatus=$(cat $InterfaceStatusFile | grep "InterfaceStatus" | awk -F[=] '{ print $2 }')
                                
                if [ "$InterfaceStatus" = "UP" ]
                then
                    StatusLog "$Action3Cmd" "$ActionExecuteTime"
                    return 0
                fi
            done
            ActionSleepCount=0
            ActionRetryCount=$((ActionRetryCount + 1))
        done
    fi
    if [ "$Action1Enable" = "0" ] && [ "$Action2Enable" = "0" ] && [ "$Action3Enable" = "0" ]
    then
        return 1
    else
        return 2
    fi
}

########################################################################
#       name:
#               PingTest
#
#       Description:
#               ping configured IpAddress and parse PacketsTransmitted, PacketsReceived and PacketLoss.
#
#       Global:
#
#       Arguments:
#               none
#
#       Returns:
#               0 - on success
#               2 - on failure(if PacketLoss is not found or greater than MinPacketLoss )
#
########################################################################
PingTest()
{
        PingOutput=$(ping -c 1 -w 6 -I "$InterfaceName" "$PingIP" 2>&1)
        PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')

        PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/transmitted/' | awk '{ print $1 }')
        PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/received/' | awk '{ print $1 }')
        PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }')

        if [ "x$PacketLoss" = "x" ] || [ "$PacketLoss" -eq "100" ]
        then
            PingOutput=$(ping -c "$PacketCount" -w "$PingDeadline" -I "$InterfaceName" "$PingIP" 2>&1)
            PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')

            PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/transmitted/' | awk '{ print $1 }')
            PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/received/' | awk '{ print $1 }')
            PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }')
        fi
        
        if [ "x$PacketLoss" = "x" ] || [ "$PacketLoss" -ge "$MinPacketLoss" ]
        then
            return 2
        fi

        return 0
}

PublishNwkStatusToISM()
{
    ReAPMqttIFStatus="$1"
    ReAPMqttAppId="3"
    CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
    ReAPMqttMsg="<,$ReAPMqttAppId,$ReAPMqttIFStatus,$IpAddress,$PingTestRetVal,$CurrentDate,>"
    
    output=$(mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttAmPingStatusPubTopic" -m "$ReAPMqttMsg" -q $ReAPMqttQos 2>&1)
    retval=$?
}


########################################################################
#       name:
#               WaitForAutoRecover
#
#       Description:
#               wait for 5 minutes by sleeping for every minute
#               return 0 in b/w nwk status is up
#
#       Global:
#
#       Arguments:
#
#       Returns: 0 - if InterfaceStatus is UP
#                1 - if InterfaceStatus is DN
########################################################################
WaitForAutoRecover()
{
    i=1
    StatusLog "Waiting"
    while [ $i -le 5 ]
    do
        InterfaceStatus=$(cat $InterfaceStatusFile | grep "InterfaceStatus" | awk -F[=] '{ print $2 }')
        if [ "$InterfaceStatus" = "DN" ]
        then
            sleep "$WaitSleepInterval"
            i=$(( i + 1 ))
            if [ "$PingTestEnable" = "1" ]
                then
                if [ "$PingTestRetVal" = "2" ] && [ "$IpAddress" != "-" ] && [ "x$IpAddress" != "x" ]
                then
                    PingTest
                    PingTestRetVal=$?
                    if [ "$PingTestRetVal" = "0" ]
                    then
                        InterfaceStatusAfterPingtest="UP"
                        PublishNwkStatusToISM "UP"
                        return 0
                    fi
                fi
            fi
        elif [ "$InterfaceStatus" = "UP" ] || [ "$InterfaceStatusAfterPingtest" = "UP" ]
        then
            InterfaceStatusAfterPingtest="-"
            return 0
        fi
    done
    
    return 1
}

PublishActionsFailureToNotifyIpChange()
{
    CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
    ReAPMqttAppId="3"

    ReAPMqttMsg="<,$ReAPMqttAppId,actionsfailure,$FirstCmdExecutionTime,$CurrentDate,>"
    output=$(mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttActionsFailurePubTopic" -m "$ReAPMqttMsg" -q $ReAPMqttQos)
    retval=$?        
}


#start of script
if [ ! -d "$InterfaceManagerTmpDir" ]
then
    mkdir -p "$InterfaceManagerTmpDir"
fi

if [ ! -d "$InterfaceManagerTmpStatusDir" ]
then
    mkdir -p "$InterfaceManagerTmpStatusDir"
fi

if [ ! -d "$InterfaceManagerAnalyticsDir" ]
then
    mkdir -p "$InterfaceManagerAnalyticsDir"
fi


IpAddress=$(echo "$PayLoad" | awk -F[,] '{ print $3 }')
PingTestRetVal=$(echo "$PayLoad" | awk -F[,] '{ print $4 }')

WaitForAutoRecover
WaitForAutoRecoverRetVal=$?

SimNumFile="/tmp/simnumfile"
SimSwitchingGpio="/sys/class/gpio/gpio$SimSelectGpio/value"


if [ "$WaitForAutoRecoverRetVal" = "1" ]
then
    PerformAction
    PerformActionRetVal=$?

    if [ "$PerformActionRetVal" = "1" ]
    then
        StatusLog "actionsdisabled"
    elif [ "$PerformActionRetVal" = "2" ]
    then
        PublishActionsFailureToNotifyIpChange
        StatusLog "actionsfailure" "$FirstCmdExecutionTime"
    fi
fi    

exit 0
