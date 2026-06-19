#!/bin/sh

. /lib/functions.sh


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

echo "$BoardOffValue" > /sys/class/gpio/gpio$BoardPowerGpio/value
exit 0


