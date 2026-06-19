#!/bin/sh


systemstartscript="/root/InterfaceManager/script/SystemStart.sh"


WifiOnOffValue=$(uci get sysconfig.wificonfig.wifi1enable)
if [ "$WifiOnOffValue" = "1" ]
then 
	uci set sysconfig.wificonfig.wifi1enable="0"
	uci commit sysconfig
	$systemstartscript
elif [ "$WifiOnOffValue" = "0" ]
then 
	uci set sysconfig.wificonfig.wifi1enable="1"
	uci commit sysconfig
	$systemstartscript  
fi
