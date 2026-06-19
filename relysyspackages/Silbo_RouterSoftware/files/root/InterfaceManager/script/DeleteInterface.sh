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
DeleteStatusFile="$ScriptStatustDir/$InterfaceName"".DeleteIfaceStatus"
AddIfaceStatusFile="$ScriptStatustDir/$InterfaceName"".AddIfaceStatus"
PortDetailsFile="$ScriptStatustDir/$InterfaceName"".ports"
lockfile="/var/run/$InterfaceName""DeleteIface.lockfile"
SystemGpioConfig="/etc/config/systemgpio"
SleepAfterIfdown=7

ReadSystemGpioFile()
{
   	config_load "$SystemGpioConfig"
	config_get SimSelectGpio gpio simselectgpio
	config_get Sim1SelectValue gpio sim1selectvalue
	config_get Sim2SelectValue gpio sim2selectvalue
	config_get Sim1LedGpio gpio Sim1LedGpio
    config_get Sim1LedGpioOnvalue gpio Sim1LedGpioOnvalue
    config_get Sim1LedGpioOffvalue gpio Sim1LedGpioOffvalue
    config_get Sim2LedGpio gpio Sim2LedGpio
    config_get Sim2LedGpioOnvalue gpio Sim2LedGpioOnvalue
    config_get Sim2LedGpioOffvalue gpio Sim2LedGpioOffvalue
    config_get numberOfModem1SignalStrengthleds gpio numberOfModem1SignalStrengthleds
    config_get modem1SignalStrengthLedOnValue gpio modem1SignalStrengthLedOnValue
    config_get modem1SignalStrengthLedOffValue gpio modem1SignalStrengthLedOffValue
    config_get modem1SignalStrengthLed1 gpio modem1SignalStrengthLed1
    config_get modem1SignalStrengthLed2 gpio modem1SignalStrengthLed2
    config_get modem1SignalStrengthLed3 gpio modem1SignalStrengthLed3
    config_get modem1SignalStrengthLed4 gpio modem1SignalStrengthLed4
    config_get networkModeLedOnValue gpio networkModeLedOnValue
    config_get networkModeLedOffValue gpio networkModeLedOffValue
    config_get networkModeLed gpio networkModeLed
}

[ -d "$ScriptStatustDir" ]  || mkdir -p "$ScriptStatustDir"
[ -d "$ScriptLogDir" ]  || mkdir -p "$ScriptLogDir"

#
# verify input arguments
#
if [ "x$InterfaceName" = "x" ]
then
    echo "Usage: $0 InterfaceName"
    echo "status=Invalid interface" > "$DeleteStatusFile"
    exit 1
fi

#to turn off sim status led and signal strength status led's
if [ "$InterfaceName" = "CWAN1_0" ] || [ "$InterfaceName" = "CWAN1_1" ] || [ "$InterfaceName" = "CWAN1" ]
then 
	
	if echo "$board_name" | grep -qE "(Silbo_IA44|Silbo_IB44|Silbo_IC44|Silbo_IC44_GW)";
	then
		ReadSystemGpioFile
		echo "$Sim1LedGpioOffvalue" > /sys/class/gpio/gpio${Sim1LedGpio}/value
		echo "$Sim2LedGpioOffvalue" > /sys/class/gpio/gpio${Sim2LedGpio}/value
		echo "modem1SignalStrengthLedOffValue" > /sys/class/gpio/gpio${modem1SignalStrengthLed1}/value
		echo "modem1SignalStrengthLedOffValue" > /sys/class/gpio/gpio${modem1SignalStrengthLed2}/value
		echo "modem1SignalStrengthLedOffValue" > /sys/class/gpio/gpio${modem1SignalStrengthLed3}/value
		echo "modem1SignalStrengthLedOffValue" > /sys/class/gpio/gpio${modem1SignalStrengthLed4}/value
		echo "$networkModeLedOffValue" > /sys/class/gpio/gpio${networkModeLed}/value
	fi
fi
#
# 
#
if ( set -o noclobber; echo $$ > "$lockfile") 2> /dev/null
then
    trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
    ifdown "$InterfaceName" > /dev/null 2>&1
    sleep "$SleepAfterIfdown"
    uci delete network."$InterfaceName" > /dev/null 2>&1
    uci commit network
    ubus call network reload
    rm -f "$PortDetailsFile"
    rm -f "$AddIfaceStatusFile"
    echo "status=Disabled" > "$DeleteStatusFile"
    rm -f "$lockfile"
    trap - INT TERM EXIT
fi

exit 0

