#!/bin/sh
 . /lib/functions.sh

GuestWifiOnOffValue=$(uci get sysconfig.guestwifi.guestwifienable)

uci set sysconfig.wificonfig.wifi1enable="0"
if [ "$GuestWifiOnOffValue" = "1" ];then
	uci set sysconfig.guestwifi.guestwifienable="0"
	#guestwififlag is set to 1 just to remember guest wifi was enabled before scheduled wifi ON/OFF
	uci set applist_config.appconfig.guestwififlag="1"
	uci commit applist_config
	uci delete network.ra1
	uci commit network
fi
	uci commit sysconfig
	uci set wireless.ra0.disabled=1
	uci commit wireless
	uci delete network.ra0
	uci commit network
	ifconfig ra0 down
	ifconfig ra1 down
	uci set mwan3config.WIFI_WAN.enabled=0
	uci commit mwan3config
	uci set mwan3.WIFI_WAN.enabled=0
	uci commit mwan3
	wifi
	mwan3 restart

	
