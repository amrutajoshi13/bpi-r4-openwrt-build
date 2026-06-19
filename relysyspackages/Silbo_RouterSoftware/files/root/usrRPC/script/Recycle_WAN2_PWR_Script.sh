#!/bin/sh

. /lib/functions.sh


########################################################################
#  Description:This script basically drives GPIO497 LOW for 5 seconds
#              before turning it HIGH again. This turns OFF the mini-PCIe 
#              2G/3G/4G modem in slot J2 (USB4) OFF for 5 seconds
########################################################################

ReadSystemGpioFile()                               
{                                                    
        config_load "$SystemGpioConfig"              
        config_get Modem2PowerGpio gpio modem2powergpio
        config_get Modem2PowerOnValue gpio modem2poweronvalue
        config_get Modem2PowerOffValue gpio modem2poweroffvalue
}

SystemGpioConfig="/etc/config/systemgpio"


ReadSystemGpioFile


echo "$Modem2PowerOffValue" > /sys/class/gpio/gpio$Modem2PowerGpio/value
sleep 5
echo "$Modem2PowerOnValue" > /sys/class/gpio/gpio$Modem2PowerGpio/value


exit 0


