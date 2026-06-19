#!/bin/sh

. /lib/functions.sh

RebootLogfile="/root/ConfigFiles/RebootLog/RebootLog.txt"
RebootreasonLogfile="/root/ConfigFiles/RebootLog/Rebootreason.txt"
########################################################################
# Description:This script basically drives PWR_RECYCLE_H GPIO (gpio503)
#             HIGH. This will be enough to recycle 5V PWR. 
########################################################################

ReadSystemGpioFile()                               
{                                                    
        config_load "$SystemGpioConfig"              
        config_get BoardPowerGpio gpio boardpowergpio
        config_get BoardOnValue gpio boardonvalue
        config_get BoardOffValue gpio boardoffvalue
}

SystemGpioConfig="/etc/config/systemgpio"


ReadSystemGpioFile
date=$(date)
echo "$date Executing reboot command from NMS.Please wait for device to reboot"
echo "$date:[Reboot due to NMS]:8" >> "$RebootLogfile"                                                                  
echo "$date:[Reboot due to NMS]:8" > "$RebootreasonLogfile"
echo "$BoardOffValue" > /sys/class/gpio/gpio$BoardPowerGpio/value
exit 0


