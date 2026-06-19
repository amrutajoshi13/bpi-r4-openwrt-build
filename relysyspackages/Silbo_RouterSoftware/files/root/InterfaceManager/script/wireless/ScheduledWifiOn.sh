#!/bin/sh

wifiap="ra0"
wifiap1="ra1"
GuestWifiOnOffValue=$(uci get sysconfig.guestwifi.guestwifienable)
uci set sysconfig.wificonfig.wifi1enable="1"
uci set wireless.ra0.disabled=0
uci commit wireless
uci commit sysconfig
guestwififlag=$(uci get applist_config.appconfig.guestwififlag)
wifi1mode=$(uci get sysconfig.wificonfig.wifi1mode)
if [ "$GuestWifiOnOffValue" = "0" ]	&& [ "$guestwififlag" = "1" ];then
	uci set sysconfig.guestwifi.guestwifienable="1"
	#guestwififlag is set to 0 reset the flag value of  guest wifi.
	uci set applist_config.appconfig.guestwififlag="0"
	uci commit applist_config
	ipaddr=$(uci get sysconfig.guestwifi.guestradio0dhcpip)
	uci set network."${wifiap1}"=interface
	uci set network."${wifiap1}".ipaddr="$ipaddr"
	uci set network."${wifiap1}".netmask="255.255.255.0"
	uci set network."${wifiap1}".proto="static"
	uci set network."${wifiap1}".ifname="ra1"
	uci commit network
	ifconfig ra1 up
fi
if [ "$wifi1mode" = "ap" ] || [ "$wifi1mode" = "apsta" ];then
	ra0ipaddr=$(uci get sysconfig.wificonfig.radio0dhcpip)
	uci set network."${wifiap}"=interface
	uci set network."${wifiap}".ipaddr="$ra0ipaddr"
	uci set network."${wifiap}".netmask="255.255.255.0"
	uci set network."${wifiap}".proto="static"
	uci set network."${wifiap}".ifname="ra0"
	uci commit network

	uci commit sysconfig
	uci set wireless.ra0.disabled=0
	uci commit wireless
	ifconfig ra0 up
	wifi
fi

if [ "$wifi1mode" = "sta" ] || [ "$wifi1mode" = "apsta" ];then
	uci set network.WIFI_WAN=interface
	uci set network.WIFI_WAN.proto="dhcp"
	uci set sysconfig.guestwifi.guestwifienable="1"
	Select=$(uci get mwan3config.general.select)
	
	WifiWanPriority=$(uci get mwan3config.WIFI_WAN.wanpriority)
	if [ "$Select" =  "failover" ] && [ -z "$WifiWanPriority" ]
	then
		uci set network.WIFI_WAN.metric="12"
	else 
		uci set network.WIFI_WAN.metric="$WifiWanPriority"
	fi
	uci set network.WIFI_WAN.ifname="apcli0" 
		uci set mwan3config.WIFI_WAN.enabled=1
	uci commit sysconfig
	uci commit mwan3config
	uci set mwan3.WIFI_WAN.enabled=1
	uci commit mwan3
	uci commit network
	ifconfig apcli0 up
	wifi
	mwan3 restart

fi
exit 0
