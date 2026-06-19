#!/bin/sh

. /lib/functions.sh

#killing the Wifi_monitor.sh, before running wireless_handler.sh
pid=$(pgrep -f "/root/InterfaceManager/script/wireless/Wifi_udhcpcmonitor.sh")
kill -9 $pid
restart_flag=$(/root/InterfaceManager/script/common_scripts/create_mwan3_interface.sh wireless 2>/dev/null)
/root/InterfaceManager/script/wireless/wireless_settings.sh 
guestwifienable=$(uci get sysconfig.guestwifi.guestwifienable)
if [ "$guestwifienable" = "1" ]
then
	ubus call network.interface.ra1 up > /dev/null 2>&1
elif [  "$guestwifienable" = "0" ];then
     ifconfig ra1 down
fi
touch /tmp/mwan-ignore-CWAN1_0
touch /tmp/mwan-ignore-CWAN1
touch /tmp/mwan-ignore-wan6c1
/etc/init.d/dnsmasq restart
/etc/init.d/firewall restart
/etc/init.d/network restart
ifconfig usb0 up

wifi
sleep 5

echo > /proc/net/nf_conntrack

sleep 1

#For wifi schedule.
/etc/init.d/cron restart > /dev/null 2>&1

if [ "$restart_flag" = "1" ]
then
	rm -rf /var/run/mwan3.lock

	/etc/init.d/mwan3 stop 2>&1

	sleep 5

	rm -rf /var/run/mwan3.lock

	pids=$(ps w | grep -i "mwan3" | grep -v grep | awk '{print $1}')
	kill -9 $pids
	
	sleep 1

	/usr/sbin/mwan3 restart 2>&1
	
	sleep 1
	
fi


if [ "$Wifi1Mode" = "sta" ]
then
     iwpriv ra0 set HideSSID=1
fi

######################################################
#If the server is restarted, then, the channel changes. 
#STA and APSTA mode needs same channel as that of the server. 
#Hence, using Wifi_monitor.sh, we call "Wifi_restart.sh" every 10 seconds to update the channel if the mode is STA/APSTA.

#Kill any earlier Wifi_monitor.sh, if present.
Wifi_monitor_pid=$(ps w | grep -i "Wifi_monitor.sh" | grep -v grep | awk '{print $1}')
kill $Wifi_monitor_pid

#Restart VPNs, PBR & nodogsplash.
/root/InterfaceManager/script/ethernet/multiple_scripts_restart.sh

exit 0
