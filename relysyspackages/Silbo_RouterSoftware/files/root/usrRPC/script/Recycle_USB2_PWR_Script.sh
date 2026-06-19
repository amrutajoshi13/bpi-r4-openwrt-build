#!/bin/sh

. /lib/functions.sh


########################################################################
#  Description:This script basically drives GPIO496 LOW for 5 seconds
#              before turning it HIGH again. This turns OFF the 5V PWR 
#              to externat USB conn. J10 (USB2) OFF for 5 seconds
########################################################################

ReadSystemGpioFile()                               
{                                                    
        config_load "$SystemGpioConfig"              
        config_get ExternelUsbGpio gpio externelusbgpio
        config_get ExternelUsbOnValue gpio externelusbonvalue
        config_get ExternelUsbOffValue gpio externelusboffvalue
}

SystemGpioConfig="/etc/config/systemgpio"


ReadSystemGpioFile


echo "$ExternelUsbOffValue" > /sys/class/gpio/gpio$ExternelUsbGpio/value
sleep 5
echo "$ExternelUsbOnValue" > /sys/class/gpio/gpio$ExternelUsbGpio/value


exit 0


