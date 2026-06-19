#!/bin/sh

. /lib/functions.sh

#
# PKG_RELEASE: 1.01
#

InterfaceManagerConfigFile="/etc/config/modem"
InterfaceStatusManagerScript="/root/InterfaceManager/script/InterfaceStatusManager.sh"
InterfaceActionManagerScript="/root/InterfaceManager/script/InterfaceActionManager.sh"
InterfaceAnalyticsManagerScript="/root/InterfaceManager/script/InterfaceAnalyticsManager.sh"
SimSwitchScript="/root/InterfaceManager/script/cellular/SimSwitch.sh"
MqttInterfaceStatusManagerScript="/root/InterfaceManager/script/MqttInterfaceStatusManager.sh"
MqttInterfaceActionManagerScript="/root/InterfaceManager/script/MqttInterfaceActionManager.sh"
MqttInterfaceAnalyticsManagerScript="/root/InterfaceManager/script/MqttInterfaceAnalyticsManager.sh"
MqttSimSwitchScript="/root/InterfaceManager/script/MqttSimSwitch.sh"
InterfaceManagerTmpDir="/tmp/InterfaceManager/"
InterfaceManagerLogFileDir="/tmp/InterfaceManager/log/"
InterfaceManagerInitLogFile="${InterfaceManagerLogFileDir}InterfaceInitializerLog.txt"
InterfaceManagerTmpConfigDir="${InterfaceManagerTmpDir}config/"

#
# Parse each section 
# Create a new temporary configuration file for each section.
# And call InterfaceMonitor Script
#
ReadAndUpdateIfaceManagerConfig()
{
    config=$1
        
    TmpConfigFile="${InterfaceManagerTmpConfigDir}${config}.cfg"
    
    if [ ! -d "$InterfaceManagerTmpConfigDir" ]
    then
        mkdir -p "$InterfaceManagerTmpConfigDir"
        echo "Created TmpConfigDir: $InterfaceManagerTmpConfigDir" >> $InterfaceManagerInitLogFile
    fi

    #modem configuration
    config_get DualSimSingleModule "cellularmodule" dualsimsinglemodule
    config_get ModemEnable "$config" modemenable
    config_get PortType "$config" porttype
    config_get DataPort "$config" device
    config_get ComPort  "$config" comport
    config_get SMSPort  "$config" smsport

    #monitor configuration
    config_get MonitorEnable  "$config"  monitorenable
    config_get ModemManufacturer  "$config"  manufacturer
    config_get ModemModel  "$config"  model
    config_get LogAnalytics  "$config"  loganalytics
    config_get InterfaceName  "$config"  interfacename
    config_get MaxIfaceDownInterval  "$config"  maxifacedowninterval
    config_get IfaceQueryInterval  "$config"  ifacequeryinterval
    config_get QueryModemATAnalytics  "$config"  querymodematanalytics
    config_get DataTestEnable  "$config"  datatestenable
    config_get PingTestEnable  "$config"  pingtestenable
    config_get PingIP  "$config"  pingip
    config_get PacketCount  "$config"  packetcount
    config_get PingDeadline  "$config"  pingdeadline
    config_get MinPacketLoss  "$config"  minpacketloss
    config_get Action1Enable  "$config"  action1enable
    config_get Action1Cmd  "$config"  action1cmd
    config_get Action1Retry  "$config"  action1retry
    config_get Action1WaitInterval  "$config"  action1waitinterval
    config_get Action2Enable  "$config"  action2enable
    config_get Action2Cmd  "$config"  action2cmd
    config_get Action2Retry  "$config"  action2retry
    config_get Action2WaitInterval  "$config"  action2waitinterval
    config_get Action3Enable  "$config"  action3enable
    config_get Action3Cmd  "$config"  action3cmd
    config_get Action3Retry  "$config"  action3retry
    config_get Action3WaitInterval  "$config"  action3waitinterval
    config_get DataEnable "$config" dataenable
    config_get SMSEnable "$config" smsenable
    config_get IfaceUpSMSNotify "$config" ifaceupsmsnotify
    config_get IfaceDownSMSNotify "$config" ifacedownsmsnotify
    config_get IfaceUpHTTPNotify "$config" ifaceuphttpnotify
    config_get StatusManagerEnable "$config" statusmanagerenable
    config_get ActionManagerEnable "$config" actionmanagerenable
    config_get AnalyticsManagerEnable "$config" analyticsmanagerenable
        
    # Change interfacemonitor configuration values based on modem configuration
    if [ "$ModemEnable" = "0" ]
    then
        MonitorEnable=0
    fi
        
    if [ "$DataEnable" = "1" ]
    then
        if [ "$DataPort" = "$ComPort" ] 
        then
            QueryModemATAnalytics=0
        fi
            
        if [ "$DataPort" = "$SMSPort" ] 
        then
            SMSEnable=0
        fi
    else
        DataTestEnable=0
        PingTestEnable=0
    fi
            
    if [ "$SMSEnable" = "1" ]
    then
        if [ "$SMSPort" = "$ComPort" ] 
        then
            QueryModemATAnalytics=0
        fi
    fi
                
    # write to temporary config file
    {
        echo "MonitorEnable=$MonitorEnable"
        echo "ModemEnable=$ModemEnable"
        echo "DualSimSingleModule=$DualSimSingleModule"
        echo "ModemManufacturer=$ModemManufacturer"
        echo "ModemModel=$ModemModel"
        echo "LogAnalytics=$LogAnalytics"
        echo "InterfaceName=$InterfaceName"
        echo "MaxIfaceDownInterval=$MaxIfaceDownInterval"
        echo "IfaceQueryInterval=$IfaceQueryInterval"
        echo "QueryModemATAnalytics=$QueryModemATAnalytics"
        echo "DataTestEnable=$DataTestEnable"
        echo "PingTestEnable=$PingTestEnable"
        echo "PingIP=$PingIP"
        echo "PacketCount=$PacketCount"
        echo "PingDeadline=$PingDeadline"
        echo "MinPacketLoss=$MinPacketLoss"
        echo "Action1Enable=$Action1Enable"
        echo "Action1Cmd=$Action1Cmd"
        echo "Action1Retry=$Action1Retry"
        echo "Action1WaitInterval=$Action1WaitInterval"
        echo "Action2Enable=$Action2Enable"
        echo "Action2Cmd=$Action2Cmd"
        echo "Action2Retry=$Action2Retry"
        echo "Action2WaitInterval=$Action2WaitInterval"
        echo "Action3Enable=$Action3Enable"
        echo "Action3Cmd=$Action3Cmd"
        echo "Action3Retry=$Action3Retry"
        echo "Action3WaitInterval=$Action3WaitInterval"
        echo "SMSEnable=$SMSEnable"
        echo "IfaceUpSMSNotify=$IfaceUpSMSNotify"
        echo "IfaceDownSMSNotify=$IfaceDownSMSNotify"
        echo "IfaceUpHTTPNotify=$IfaceUpHTTPNotify"
        echo "StatusManagerEnable=$StatusManagerEnable"
        echo "ActionManagerEnable=$ActionManagerEnable"
        echo "AnalyticsManagerEnable=$AnalyticsManagerEnable"
        echo "PortType=$PortType"
        echo "DataPort=$DataPort"
        echo "ComPort=$ComPort"
        echo "SMSPort=$SMSPort"
        echo "DataEnable=$DataEnable"
    } > "$TmpConfigFile"
                
    echo "Created Tmpconfigfile : $TmpConfigFile" >> "$InterfaceManagerInitLogFile"
        
    # Remove starting and trailing whitespaces from temp config file
    sed -i 's/[[:space:]]*=[[:space:]]*/=/g' "$TmpConfigFile" > /dev/null 2>&1
}

StartInterfaceManager()
{
    local Interface="$1"
    if ! echo "$Interface" | grep -qE "^CWAN1$|^CWAN1_0$|^CWAN1_1$|^CWAN2$|^CWAN3$|^cellularmodule$"
    then
        echo "invalid interface to StartInterfaceManager" >> "$InterfaceManagerInitLogFile"       
        exit 0
    fi
                 
    ReadAndUpdateIfaceManagerConfig "$Interface"
    
    if [ "$ModemEnable" = 1 ] && [ "$MonitorEnable" = "1" ]
    then   
        local PSOutput=$(ps x)
        if [ "$StatusManagerEnable" = 1 ]
        then   
            if echo "$PSOutput" | grep -q "$MqttInterfaceStatusManagerScript $Interface"
            then
                echo "Process \"$MqttInterfaceStatusManagerScript $Interface\" is already Running" >> "$InterfaceManagerInitLogFile"
            else     
                echo "Invoking $MqttInterfaceStatusManagerScript" >> "$InterfaceManagerInitLogFile"       
                "$MqttInterfaceStatusManagerScript" "$Interface" &
            fi
        fi
        
        if [ "$ActionManagerEnable" = 1 ]
        then 
            if echo "$PSOutput" | grep -q "$MqttInterfaceActionManagerScript $Interface"
            then
                echo "Process \"$MqttInterfaceActionManagerScript $Interface\" is already Running" >> "$InterfaceManagerInitLogFile"
            else            
                echo "Invoking $MqttInterfaceActionManagerScript" >> "$InterfaceManagerInitLogFile"       
                "$MqttInterfaceActionManagerScript" "$Interface" &
            fi
        fi
        
        if [ "$AnalyticsManagerEnable" = 1 ]
        then 
            if echo "$PSOutput" | grep -q "$MqttInterfaceAnalyticsManagerScript $Interface"
            then
                echo "Process \"$MqttInterfaceAnalyticsManagerScript $Interface\" is already Running" >> "$InterfaceManagerInitLogFile"
            else            
                echo "Invoking $MqttInterfaceAnalyticsManagerScript" >> "$InterfaceManagerInitLogFile"       
                "$MqttInterfaceAnalyticsManagerScript" "$Interface" &
            fi
        fi
        
    else
        echo "$config: not enabled" >> "$InterfaceManagerInitLogFile"
    fi
}

StopInterfaceManager()
{
    
    if ! echo "$Interface" | grep -qE "^CWAN1$|^CWAN1_0$|^CWAN1_1$|^CWAN2$|^CWAN3$|^cellularmodule$"
    then
        echo "invalid interface to StopInterfaceManager" >> "$InterfaceManagerInitLogFile"       
        exit 0
    fi

    local PSOutput=$(ps x)
    
    if echo "$PSOutput" | grep -q "$MqttInterfaceStatusManagerScript $Interface"
    then
        ppid1=$(echo "$PSOutput" | grep "$MqttInterfaceStatusManagerScript $Interface" | \
        awk -F' ' '{ print $1 }' | awk '{ if(NR==1) print $1 }')

        cpids1=$(pgrep -P $ppid1 | tr '\n' ' ')

        kill -TERM $ppid1 > /dev/null 2>&1
        kill -TERM $cpids1 > /dev/null 2>&1

        echo "stopping $MqttInterfaceStatusManagerScript, ppid=$ppid1" >> "$InterfaceManagerInitLogFile"
        echo "stopping $MqttInterfaceStatusManagerScript, cpids=$cpids1" >> "$InterfaceManagerInitLogFile"
    else
        echo "Process \"$MqttInterfaceStatusManagerScript $Interface\" is not Running" >> "$InterfaceManagerInitLogFile"
    fi
    
    PSOutput=$(ps x)
    if echo "$PSOutput" | grep -q "$InterfaceStatusManagerScript $Interface"
    then
        ppid1=$(echo "$PSOutput" | grep "$InterfaceStatusManagerScript $Interface" | \
        awk -F' ' '{ print $1 }' | awk '{ if(NR==1) print $1 }')

        kill -TERM $ppid1 > /dev/null 2>&1

        echo "stopping $InterfaceStatusManagerScript, ppid=$ppid1" >> "$InterfaceManagerInitLogFile"
    else
        echo "Process \"$InterfaceStatusManagerScript $Interface\" is not Running" >> "$InterfaceManagerInitLogFile"
    fi

    PSOutput=$(ps x)
    if echo "$PSOutput" | grep -q "$MqttInterfaceActionManagerScript $Interface"
    then
        ppid2=$(echo "$PSOutput" | grep "$MqttInterfaceActionManagerScript $Interface" | \
        awk -F' ' '{ print $1 }' | awk '{ if(NR==1) print $1 }')

        cpids2=$(pgrep -P $ppid2 | tr '\n' ' ')

        kill -TERM $ppid2 > /dev/null 2>&1
        kill -TERM $cpids2 > /dev/null 2>&1

        echo "stopping $MqttInterfaceActionManagerScript, ppid=$ppid2" >> "$InterfaceManagerInitLogFile"
        echo "stopping $MqttInterfaceActionManagerScript, cpids=$cpids2" >> "$InterfaceManagerInitLogFile"
    else
        echo "Process \"$MqttInterfaceActionManagerScript $Interface\" is not Running" >> "$InterfaceManagerInitLogFile"    
    fi

    PSOutput=$(ps x)
    if echo "$PSOutput" | grep -q "$InterfaceActionManagerScript $Interface"
    then
        ppid2=$(echo "$PSOutput" | grep "$InterfaceActionManagerScript $Interface" | \
        awk -F' ' '{ print $1 }' | awk '{ if(NR==1) print $1 }')


        kill -TERM $ppid2 > /dev/null 2>&1

        echo "stopping $InterfaceActionManagerScript, ppid=$ppid2" >> "$InterfaceManagerInitLogFile"
    else
        echo "Process \"$InterfaceActionManagerScript $Interface\" is not Running" >> "$InterfaceManagerInitLogFile"    
    fi
   
    PSOutput=$(ps x)
    if echo "$PSOutput" | grep -q "$MqttInterfaceAnalyticsManagerScript $Interface"
    then
        ppid3=$(echo "$PSOutput" | grep "$MqttInterfaceAnalyticsManagerScript $Interface" | \
        awk -F' ' '{ print $1 }' | awk '{ if(NR==1) print $1 }')

        cpids3=$(pgrep -P $ppid3 | tr '\n' ' ')

        kill -TERM $ppid3 > /dev/null 2>&1
        kill -TERM $cpids3 > /dev/null 2>&1

        echo "stopping $MqttInterfaceAnalyticsManagerScript, ppid=$ppid3" >> "$InterfaceManagerInitLogFile"
        echo "stopping $MqttInterfaceAnalyticsManagerScript, cpids=$cpids3" >> "$InterfaceManagerInitLogFile"
    else
        echo "Process \"$MqttInterfaceAnalyticsManagerScript $Interface\" is not Running" >> "$InterfaceManagerInitLogFile"    
    fi
    
    PSOutput=$(ps x)
    if echo "$PSOutput" | grep -q "$InterfaceAnalyticsManagerScript $Interface"
    then
        ppid3=$(echo "$PSOutput" | grep "$InterfaceAnalyticsManagerScript $Interface" | \
        awk -F' ' '{ print $1 }' | awk '{ if(NR==1) print $1 }')


        kill -TERM $ppid3 > /dev/null 2>&1

        echo "stopping $InterfaceAnalyticsManagerScript, ppid=$ppid3" >> "$InterfaceManagerInitLogFile"
    else
        echo "Process \"$InterfaceAnalyticsManagerScript $Interface\" is not Running" >> "$InterfaceManagerInitLogFile"    
    fi
    
 
    
}

usage()
{
    echo    "Usage:
            $0 <options>
            options
                boot - to start all interaces
                start <interface> - to start a pariticular interface 
                stop  <interace> - to stop a particular interface"
}

    if [ "$#" = 0 ] || [ "$#" -gt 2 ]
    then
        usage
        exit 1
    fi
#
# Read and Process the each sections found in configuration file
#


if [ ! -d "$InterfaceManagerTmpDir" ]
then
    mkdir $InterfaceManagerTmpDir
fi

if [ ! -d "$InterfaceManagerLogFileDir" ]
then
    mkdir -p $InterfaceManagerLogFileDir
fi

echo "InterfaceManager started on : $(date) " > "$InterfaceManagerInitLogFile"

if [ ! -s "$InterfaceManagerConfigFile" ]
then
    echo "Error: $InterfaceManagerConfigFile does not exists or has no contents" >> "$InterfaceManagerInitLogFile"
    exit 1
fi

case "$1" in
    "boot")
        config_load "$InterfaceManagerConfigFile" 
        config_foreach StartInterfaceManager interface
        ;;
    "start")
        if [ "$#" = "2" ]
        then
            Interface="$2"
            config_load "$InterfaceManagerConfigFile" 
            StartInterfaceManager "$Interface"
        else
            echo "Error: interface name not provided as second argument to start InterfaceManager" >> "$InterfaceManagerInitLogFile"
            usage
            exit 1        
        fi
        ;;
    "stop")
        if [ "$#" = "2" ]
        then
            Interface="$2"
            config_load "$InterfaceManagerConfigFile" 
            StopInterfaceManager "$Interface"
        else
            echo "Error: interface name not provided as second argument to stop InterfaceManager" >> "$InterfaceManagerInitLogFile"
            usage
            exit 1     
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0
