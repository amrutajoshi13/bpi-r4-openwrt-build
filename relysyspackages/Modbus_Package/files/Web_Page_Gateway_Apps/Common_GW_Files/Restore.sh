#!/bin/sh

. /lib/functions.sh

ReadSystemGpioFile()                               
{
	    config_load "$SystemGpioConfig"
	    config_get ProgramLed1Number gpio programled1number
        config_get ProgramLed1OnValue gpio programled1onvalue
		config_get SimSelectGpio gpio simselectgpio
		config_get Sim1SelectValue gpio sim1selectvalue
		config_get Modem1PowerGpio gpio modem1powergpio      
		config_get Modem1PowerOffValue gpio modem1poweroffvalue

}

pid=$(pgrep -f "/root/InterfaceManager/script/GPIO_Polling_nvp_int_wo_Print_w_script")
kill -TERM "$pid" > /dev/null 2>&1
sleep 1
kill -KILL "$pid" > /dev/null 2>&1


SystemGpioConfig="/etc/config/systemgpio"

ReadSystemGpioFile

echo "$ProgramLed1OnValue" > /sys/class/gpio/gpio$ProgramLed1Number/value

mwan3 stop

ipsec stop

uci set modem.CWAN1_0.modemenable="1"
uci set modem.CWAN1_0.modemenable="0"

uci commit modem

echo "$Modem1PowerOffValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value

sleep 2

echo "$Sim1SelectValue" > /sys/class/gpio/gpio$SimSelectGpio/value

/root/InterfaceManager/script/InterfaceInitializer.sh stop

rm /tmp/simnumfile

cp /etc/config/boardconfig /root/


rm -r /etc/config

cp -r /root/InterfaceManager/config /etc/

#############################################################################

cp /root/InterfaceManager/mt7628/mt7628.dat /etc/wireless/mt7628/mt7628.dat

#############################################################################
			
sleep 3

sh -x /etc/init.d/GD44AppManager stop

uci set applist_config.appconfig.running="0"
uci commit applist_config

rm /etc/ser2net.conf
rm /etc/mbusdconfig.conf
rm /etc/mbusdconfig2.conf

cp -r /Web_Page_Gateway_Apps/Default_Gateway/config /etc/
cp /Web_Page_Gateway_Apps/Default_Gateway/ser2net.conf /etc/
cp /Web_Page_Gateway_Apps/Default_Gateway/mbusdconfig.conf /etc/
cp /Web_Page_Gateway_Apps/Default_Gateway/mbusdconfig2.conf /etc/
cp /Web_Page_Gateway_Apps/Default_Gateway/root /etc/crontab/


/root/usrRPC/script/Board_Recycle_12V_Script.sh

exit 0
