#!/bin/sh

. /lib/functions.sh


########################################################################
#  Description:This script basically drives GPIO498 LOW for 5 seconds
#              before turning it HIGH again. This turns OFF the mini-PCIe 
#              2G/3G/4G modem in slot J5 (USB3) OFF for 5 seconds
########################################################################
#ComPort="$1"
ReadSystemGpioFile()                               
{                                                    
        config_load "$SystemGpioConfig"              
        config_get Modem1PowerGpio gpio modem1powergpio
        config_get Modem1PowerOnValue gpio modem1poweronvalue
        config_get Modem1PowerOffValue gpio modem1poweroffvalue
}

ReadSystemSysFile()                               
{                                                    
        config_load "$SystemsysConfig"              
        config_get cellularmodem1 sysconfig cellularmodem1
}

SystemGpioConfig="/etc/config/systemgpio"
SystemsysConfig="/etc/config/sysconfig"

Logfile1="/root/ConfigFiles/Logs/all_logs_mod1.txt"
ReadSystemGpioFile
ReadSystemSysFile

TmpSim1DataFile="/tmp/sim1data"
TmpSim2DataFile="/tmp/sim2data"
TmpSimDataFile="/tmp/simdata"

echo 0 > "$TmpSim1DataFile"
echo 0 > "$TmpSim2DataFile"
echo 0 > "$TmpSimDataFile"
ComPort=$(cat /tmp/InterfaceManager/status/ports.txt | cut -d "=" -f2)



if [ "$cellularmodem1" = "QuectelRM500U" ] 
then
	status=$(/bin/at-cmd $ComPort at+qpowd | grep -o "POWERED DOWN")
else
	status=$(/bin/at-cmd $ComPort at+qpowd)
fi

if [ -z "$status" ] || [ "$status" != "POWERED DOWN" ]
then  

	echo "$Modem1PowerOffValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value
	sleep 5
	echo "$Modem1PowerOnValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value
	logger -t modem -p customs.info "Modem is Restarted"
fi

exit 0



