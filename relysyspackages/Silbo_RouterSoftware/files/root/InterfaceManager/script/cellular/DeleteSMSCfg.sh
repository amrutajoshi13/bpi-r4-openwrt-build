#!/bin/sh

. /lib/functions.sh

#
# PKG_RELEASE: 1.01
#

#
# Input arguments and Default Parameters
#
InterfaceName="$1"
ScriptStatustDir="/tmp/InterfaceManager/status"
ScriptLogDir="/tmp/InterfaceManager/log"
DeleteSMSCfgStatusFile="$ScriptStatustDir/$InterfaceName"".DeleteSMSCfgStatus"
AddSMSCfgStatusFile="$ScriptStatustDir/$InterfaceName"".AddSMSCfgStatus"
PortDetailsFile="$ScriptStatustDir/$InterfaceName"".smsport"
lockfile="/var/run/$InterfaceName""DeleteSMSCfg.lockfile"
SMSCfgFile="/etc/smsd.conf"

[ -d "$ScriptStatustDir" ]  || mkdir -p "$ScriptStatustDir"
[ -d "$ScriptLogDir" ]  || mkdir -p "$ScriptLogDir"

#
# verify input arguments
#
if [ "x$InterfaceName" = "x" ]
then
        echo "Usage: $0 InterfaceName"
        echo "status=Invalid interface" > "$DeleteSMSCfgStatusFile"
        exit 1
fi

#
# Delete sms configurations
#
DeleteSMSConfiguration()
{
        # remove Modem settings from sms configuration
        
        # remove modem name from  devices variable
        Devices=$(sed -n "/^\<devices\>/p" "$SMSCfgFile"  | cut -d "=" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')
        ModifiedDevices=$(echo "$Devices" | awk  -v awkIfaceName="$InterfaceName" -F', ' '{for (i=1; i<=NF; i++) if ($i !~ awkIfaceName) printf $i","}') 
        if [ "x$ModifiedDevices" = "x" ]         
        then                             
                # deleting values assigned for 'devices' variable
                tmpdevicesline="devices = "
                sed -i 's!\<devices\>.*!'"$tmpdevicesline"'!' "$SMSCfgFile"
        else                                                 
                # update 'devices' variable with new value        
                pdevices=$(echo "$ModifiedDevices" | sed s'/,$//')       
                tmpdevicesline="devices = $pdevices"
                sed -i 's!\<devices\>.*!'"$tmpdevicesline"'!' "$SMSCfgFile"
        fi

        # remove section                 
        sed -i '/\['"$InterfaceName"'\]/,/'"\#end""$InterfaceName"'/d' "$SMSCfgFile"  > /dev/null 2>&1
        
        # remove consecutive blank lines                         
        sed -i 'N;/^\n$/d;P;D' "$SMSCfgFile" > /dev/null 2>&1      

}

#
# 
#
if (set -o noclobber; echo $$ > "$lockfile") 2> /dev/null
then
        trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
        /etc/init.d/smstools3 stop > /dev/null 2>&1
        DeleteSMSConfiguration
        rm -f "$AddSMSCfgStatusFile"
        rm -f "$PortDetailsFile"
        echo "status=Disabled" > "$DeleteSMSCfgStatusFile"
        rm -f "$lockfile"
        trap - INT TERM EXIT
fi

exit 0
