#!/bin/sh

# Define the path to the UCI config file to monitor
CONFIG_FOLDER="/etc/config"
CONFIG_FILE="/etc/config/remote"
DAT_FILE="/etc/wireless/mt7628/mt7628.dat"
SYSCON_FILE="/etc/config/sysconfig"

# Start monitoring the config file for chang
 # Parse the value of passwd and ssid from the uci config file
   SSID=$(uci get remote.@update[0].ssid)
   PASSWD=$(uci get remote.@update[0].passwd)
   radioenable=$(uci get remote.@update[0].radioenable)
	
  # Update the SSID1 and WPAPSK1 values in the .dat file
   sed -i "s/^\(SSID1=\).*/\1$SSID/" $DAT_FILE
   sed -i "s/^\(WPAPSK1=\).*/\1$PASSWD/" $DAT_FILE
   uci set sysconfig.wificonfig.wifi1ssid=$SSID
   uci set sysconfig.wificonfig.wifi1key=$PASSWD
  
   ipaddr=$(uci get sysconfig.wificonfig.radio0dhcpip)
   if [ "$radioenable" = "Disable" ]
   then
       uci set wireless.ra0.disabled=1
       uci set sysconfig.wificonfig.wifi1enable=0
       uci delete network.ra0
       uci commit network
       uci commit wireless
       uci commit sysconfig
       ubus call network.interface.ra0 down
    elif [ "$radioenable" = "Enable" ]
    then
        uci set sysconfig.wificonfig.wifi1enable=1
		uci set wireless.ra0.disabled=0
		uci set network.ra0=interface
		uci set network.ra0.ipaddr=$ipaddr
		uci set network.ra0.netmask='255.255.255.0'
		uci set network.ra0.proto='static'
		uci set network.ra0.ifname='ra0'
		uci commit network
		uci commit wireless
		uci commit sysconfig
		ubus call network.interface.ra0 up
	fi
	
   wifi
   uci commit sysconfig
