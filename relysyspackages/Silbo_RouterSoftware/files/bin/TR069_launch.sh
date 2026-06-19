#!/bin/sh


username=$(uci get remoteconfig.tr069.username)
password=$(uci get remoteconfig.tr069.password)
periodic_interval=$(uci get remoteconfig.tr069.periodic_interval)
tr069enable=$(uci get remoteconfig.tr069.trenable)
periodic_enable=$(uci get remoteconfig.tr069.periodic_enable)
url=$(uci get remoteconfig.tr069.url)
interface=$(uci get remoteconfig.tr069.interface)
RMS=$(uci get remoteconfig.general.rmsoption)


echo "$username"
echo "$password"
echo "$periodic_interval"
echo "$tr069enable"
echo "$periodic_enable"
echo "$url" 



if [ "$RMS" = "tr069" ] && [ "${tr069enable}" = "1" ]
then
	     uci set easycwmp.@local[0].enable=$tr069enable
	     uci set easycwmp.@acs[0].username=$username
	     uci set easycwmp.@acs[0].password=$password
	     uci set easycwmp.@acs[0].url=$url
	     uci set easycwmp.@acs[0].periodic_enable=$periodic_enable
	     uci set easycwmp.@acs[0].periodic_interval=$periodic_interval
	     uci set easycwmp.@local[0].interface=$interface
	     #update serial number,firmware version,wifi ssid in easycwmp config file
	serial_num=$(uci get boardconfig.board.serialnum)
	Firmwareversion=$(uci get boardconfig.board.FirmwareVer)
	Applicationversion=$(uci get boardconfig.board.ApplicationSwVer)
	wifi_passwd=$(uci get sysconfig.wificonfig.wifi1key)
	wifi_ssid=$(uci get sysconfig.wificonfig.wifi1ssid)
	radioenable=$(uci get sysconfig.wificonfig.wifi1enable)
	Model=$(uci get boardconfig.board.model)
	uci set easycwmp.@device[0].serial_number=$serial_num
	uci set easycwmp.@device[0].software_version=${Firmwareversion}_${Applicationversion}
	uci set remote.@update[0].ssid=$wifi_ssid
	uci set remote.@update[0].passwd=$wifi_passwd
	 if [ "$radioenable" = "0" ]
	then
		uci set remote.@update[0].radioenable=Disable
	elif [ "$radioenable" = "1" ]
	then
	   uci set remote.@update[0].radioenable=Enable
	fi 
	uci set easycwmp.@device[0].product_class=$Model
	uci commit remote
	uci commit easycwmp
	logger -t config -p customs.info "remote configuration changed"
	logger -t config -p customs.info "easycwmp configuration changed"

	     /etc/init.d/easycwmpd start
	     /root/InterfaceManager/script/Tr069_Incomming_event.sh &
else	
	     /etc/init.d/easycwmpd stop
	     pid=$(pgrep -f TR069.sh)
	     if [ -n "$pid" ]; then
	        kill $pid
	       echo "Script has been killed."
	     else
	       echo "Script is not running."
	     fi
fi


