#!/bin/sh
. /lib/functions.sh
wifiap="ra0"
wifiap1="ra1"
wifista="WIFI_WAN"
wirelessdatfile="/etc/wireless/mt7628/mt7628.dat"
cellularwan1interface="CWAN1"
cellularwan2interface="CWAN2"
cellularwan3interface="CWAN3"
cellularwan1sim1interface="CWAN1_0"
cellularwan1sim2interface="CWAN1_1"
#remove 

ReadSystemConfigFile()
{
	    #WifiConfig	
		config_load "$SystemConfigFile"
		config_get WifiDevice wificonfig wifidevice
		config_get Radio0AccessPointEnable wificonfig wifi1enable
		config_get TxPower wificonfig TxPower
		config_get WifiDevicesChannel wificonfig wifideviceschannel
		config_get CountryCode wificonfig CountryCode
		config_get Wifi1Enable wificonfig wifi1enable
		config_get Radio0StationEnable wificonfig radio0stationenable
		config_get Wifi1Ssid wificonfig wifi1ssid
		config_get Wifi1Key wificonfig wifi1key
		config_get Wifi1Mode wificonfig wifi1mode
		config_get Wifi1StaMode wificonfig wifi1stamode
		config_get wifi1authentication wificonfig wifi1authentication
		config_get wifi1encryption wificonfig wifi1encryption
		config_get Wifi1StaSsid wificonfig wifi1stassid
		config_get Wifi1StaEncryption wificonfig wifi1staencryption
		config_get Wifi1StaKey wificonfig wifi1stakey
		config_get Wifi2Enable wificonfig wifi2enable
		config_get Wifi2Ssid wificonfig wifi2ssid
		config_get Wifi2Key wificonfig wifi2key
		config_get Wifi2Mode wificonfig wifi2mode
		config_get InternetOverWifi wificonfig internetoverwifi
		config_get LanWifiBridgeEnable wificonfig lanwifibridgeenable
		config_get Radio0DhcpIp wificonfig radio0dhcpip
		config_get Radio0DHCPRange wificonfig Radio0DHCPrange
		config_get Radio0DHCPLimit wificonfig Radio0DHCPlimit
		config_get ScheduledOnOff wificonfig ScheduledOnOff
		config_get WmmEnable wificonfig WmmEnable
		config_get WpsEnable wificonfig WpsEnable
		config_get EnableDhcpRelay wificonfig EnableDhcpRelay
		config_get WifiRelayServerIP wificonfig WifiRelayServerIP
		config_get WifiRelayLocalIP wificonfig WifiRelayLocalIP
		
		#GuestWifiConfig
		config_get guestwifissid guestwifi guestwifissid
		config_get guestwifiencryption guestwifi guestwifiencryption
		config_get guestwifikey guestwifi guestwifikey
		config_get guestwifi1authentication guestwifi guestwifi1authentication
		config_get guestwifi1encryption guestwifi guestwifi1encryption
		config_get guestradio0dhcpip guestwifi guestradio0dhcpip
		config_get guestRadio0DHCPrange guestwifi guestRadio0DHCPrange
		config_get guestRadio0DHCPlimit guestwifi guestRadio0DHCPlimit
		config_get guestwifienable guestwifi guestwifienable
		config_get guestwifi1authentication guestwifi guestwifi1authentication
		config_get guestwifi1encryption guestwifi guestwifi1encryption
	
		#WirelessConfig
		config_get ScheduledOnOff wirelessconfig ScheduledOnOff
		config_get DayOfWeek wirelessconfig DayOfWeek
		config_get from wirelessconfig from
		config_get fromHours wirelessconfig fromHours
		config_get fromMinutes wirelessconfig fromMinutes
		config_get to wirelessconfig to
		config_get toHours wirelessconfig toHours
		config_get toMinutes wirelessconfig toMinutes
}

UpdateWirelessConfig()
{
	    pid=$(pgrep -f "/root/InterfaceManager/script/wireless/Wifi_udhcpcmonitor.sh")
	    kill -9 $pid
		uci set wireless.ra0.country="$CountryCode"
		uci set wireless.ra0.channel="$WifiDevicesChannel"
		txpower=$(grep -w "TxPower" ${wirelessdatfile})        
		txpower_replace="TxPower=$TxPower"
		sed -i "s/${txpower}/${txpower_replace}/" "$wirelessdatfile"
		wmmenable=$(grep -w "WmmCapable" ${wirelessdatfile})        
		wmmenable_replace="WmmCapable=$WmmEnable"
		sed -i "s/${wmmenable}/${wmmenable_replace}/" "$wirelessdatfile"
		sed -i '/ScheduledWifiOff.sh/d' /etc/crontabs/root
		sed -i '/ScheduledWifiOn.sh/d' /etc/crontabs/root
		countrycode=$(grep -w "CountryCode" ${wirelessdatfile})        
		countrycode_replace="CountryCode=$CountryCode"
		sed -i "s/${countrycode}/${countrycode_replace}/" "$wirelessdatfile"
		ht_bw=$(grep -w "HT_BW" ${wirelessdatfile})        
		ht_bw_replace="HT_BW=$channelwidth"
		sed -i "s/${ht_bw}/${ht_bw_replace}/" "$wirelessdatfile" 
		channel=$(grep -w "Channel" ${wirelessdatfile})        
		Channel_replace="Channel=$WifiDevicesChannel"
		sed -i "s/${channel}/${Channel_replace}/" "$wirelessdatfile"
		uci delete network."${wifiap}" > /dev/null 2>&1
		uci delete network."${wifista}" > /dev/null 2>&1
		uci delete network."${wifiap1}" > /dev/null 2>&1
		uci delete dhcp."${wifiap1}" > /dev/null 2>&1
		uci delete dhcp."${wifiap}" > /dev/null 2>&1
		if [ "$Wifi1Enable" = "0" ]
		then 
		   uci set wireless.ap.disabled="1"
		   uci set wireless.sta.disabled="1"
		   uci delete network."${wifiap}" > /dev/null 2>&1
		   uci delete network."${wifista}" > /dev/null 2>&1
		   uci delete network."${wifiap1}" > /dev/null 2>&1
		   uci delete dhcp."${wifiap1}" > /dev/null 2>&1
		   uci delete dhcp."${wifiap}" > /dev/null 2>&1
		else
			if [ "$Wifi1Mode" = "ap" ]
			then
				ifdown apcli0
				hidessid=$(grep -w "HideSSID" ${wirelessdatfile})        
				hidessid_replace="HideSSID=0"
				sed -i "s/${hidessid}/${hidessid_replace}/" "$wirelessdatfile"
				uci delete  network."${wifiap}" > /dev/null 2>&1
				uci delete  network."${wifista}" > /dev/null 2>&1
				uci set wireless.sta.disabled="1"
				uci set wireless.ap.disabled="0"
				uci set wireless.ap.ssid="$Wifi1Ssid"
				uci set wireless.ap.key="$Wifi1Key"
				uci set wireless.ap.encryption="$wifi1encryption"
				uci set network."${wifiap}"=interface
				
				uci set network."${wifiap}".ipaddr="$Radio0DhcpIp"
				uci set network."${wifiap}".netmask="255.255.255.0"
				uci set network."${wifiap}".proto="static"
				uci set network."${wifiap}".ifname="ra0"
				
				uci set dhcp."${wifiap}"=dhcp
				uci set dhcp."${wifiap}".interface="${wifiap}"
				uci set dhcp."${wifiap}".start="$Radio0DHCPRange"
				uci set dhcp."${wifiap}".limit="$Radio0DHCPLimit"
				uci set dhcp."${wifiap}".leasetime="12h"
				uci set dhcp."${wifiap}".dhcpv6="disabled"
				uci set dhcp."${wifiap}".ra="disabled"
				
				ssid=$(grep -w "SSID1" ${wirelessdatfile})        
				ssid_replace="SSID1=$Wifi1Ssid"
				sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"
				
				wpapsk1=$(grep -w "WPAPSK1" ${wirelessdatfile})        
				wpapsk1_replace="WPAPSK1=$Wifi1Key"
				sed -i "s/${wpapsk1}/${wpapsk1_replace}/" "$wirelessdatfile"
				uci delete network.wan > /dev/null 2>&1
				
				authmode=$(grep -w "AuthMode" ${wirelessdatfile})        
				authmode_replace="AuthMode=$wifi1authentication"
				sed -i "s/${authmode}/${authmode_replace}/" "$wirelessdatfile"
				
				encryption=$(grep -w "EncrypType" ${wirelessdatfile})        
				encrypt_replace="EncrypType=$wifi1encryption"
				sed -i "s/${encryption}/${encrypt_replace}/" "$wirelessdatfile"           		
			fi       
			

	
			if [ "$Wifi1Mode" = "sta" ]
			then
				/root/InterfaceManager/script/wireless/Wifi_udhcpcmonitor.sh &			  		
				iwpriv ra0 set HideSSID=1
				hidessid=$(grep -w "HideSSID" ${wirelessdatfile})        
				hidessid_replace="HideSSID=1"
				sed -i "s/${hidessid}/${hidessid_replace}/" "$wirelessdatfile"
				uci set wireless.sta.disabled="0"
				uci set wireless.sta.ssid="$Wifi1StaSsid"
				uci set wireless.sta.key="$Wifi1StaKey"
				if [ "$Wifi1StaEncryption" = "WPA2PSK" ];then
					uci set wireless.sta.encryption="psk2"
				elif [ "$Wifi1StaEncryption" = "WPAPSK" ];then
					uci set wireless.sta.encryption="psk"
				elif [ "$Wifi1StaEncryption" = "NONE" ];then
					uci set wireless.sta.encryption="none"
				elif [ "$Wifi1StaEncryption" = "WPA1PSKWPA2PSK" ];then
					uci set wireless.sta.encryption="psk-mixed"
				fi				
				uci set network.WIFI_WAN=interface
				uci set network.WIFI_WAN.proto="dhcp"
				uci set network.WIFI_WAN.metric="$WifiWanPriority"
				uci set network.WIFI_WAN.ifname="apcli0"
			
				if [ "$EnableDhcpRelay" = "1" ]
				then
					uci delete dhcp."${wifiap}"
					echo "dhcp-relay=${Radio0DhcpIp},${WifiRelayServerIP}" >> /etc/dnsmasq.conf   
				fi
				
				Select=$(uci get mwan3config.general.select)
				WifiWanPriority=$(uci get mwan3config.WIFI_WAN.wanpriority)
				if [ "$Select" =  "failover" ] && [ -z "$WifiWanPriority" ]
				then
					uci set network.WIFI_WAN.metric="8"
				else 
					uci set network.WIFI_WAN.metric="$WifiWanPriority"
				fi	
			fi
		  
			if [ "$guestwifienable" = "1" ]
			then
				uci set network."${wifiap1}"=interface
				uci set network."${wifiap1}".ipaddr="$guestradio0dhcpip"
				uci set network."${wifiap1}".netmask="255.255.255.0"
				uci set network."${wifiap1}".proto="static"
				uci set network."${wifiap1}".ifname="ra1"
				
				uci set dhcp."${wifiap1}"=dhcp
				uci set dhcp."${wifiap1}".interface="${wifiap1}"
				uci set dhcp."${wifiap1}".leasetime="12h"
				uci set dhcp."${wifiap1}".dhcpv6="disabled"
				uci set dhcp."${wifiap1}".ra="disabled"
				uci set dhcp."${wifiap1}".start="$guestRadio0DHCPrange"
				uci set dhcp."${wifiap1}".limit="$guestRadio0DHCPlimit"
						
				ssid2=$(grep -w "SSID2" ${wirelessdatfile})        
				ssid2_replace="SSID2=$guestwifissid"
				sed -i "s/${ssid2}/${ssid2_replace}/" "$wirelessdatfile"
				
				authmode=$(grep -w "AuthMode" ${wirelessdatfile})        
				authmode_replace="AuthMode=$wifi1authentication;$guestwifi1authentication"
				sed -i "s/${authmode}/${authmode_replace}/" "$wirelessdatfile"
				
				encryption=$(grep -w "EncrypType" ${wirelessdatfile})        
				encrypt_replace="EncrypType=$wifi1encryption;$guestwifi1encryption"
				sed -i "s/${encryption}/${encrypt_replace}/" "$wirelessdatfile"
				
				wpapsk2=$(grep -w "WPAPSK2" ${wirelessdatfile})        
				wpapsk2_replace="WPAPSK2=$guestwifikey"
				sed -i "s/${wpapsk2}/${wpapsk2_replace}/" "$wirelessdatfile"
			else 
				uci delete  network.ra1 > /dev/null 2>&1
			fi
			
			if [ "$Wifi1Mode" = "apsta" ]
			then
				/root/InterfaceManager/script/wireless/Wifi_udhcpcmonitor.sh &			  		
				ssid=$(grep -w "SSID1" ${wirelessdatfile})        
				ssid_replace="SSID1=$Wifi1Ssid"
				sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"
			
				if [ "$guestwifienable" = "0" ];then
					authmode=$(grep -w "AuthMode" ${wirelessdatfile})        
					authmode_replace="AuthMode=$wifi1authentication"
					sed -i "s/${authmode}/${authmode_replace}/" "$wirelessdatfile"
				elif [ "$guestwifienable" = "1" ];then
					authmode=$(grep -w "AuthMode" ${wirelessdatfile})        
					authmode_replace="AuthMode=$wifi1authentication;$guestwifi1authentication"
					sed -i "s/${authmode}/${authmode_replace}/" "$wirelessdatfile"
				fi	
			
				if [ "$guestwifienable" = "0" ];then
					encryption=$(grep -w "EncrypType" ${wirelessdatfile})        
					encrypt_replace="EncrypType=$wifi1encryption"
					sed -i "s/${encryption}/${encrypt_replace}/" "$wirelessdatfile"           
				elif [ "$guestwifienable" = "1" ];then
					encryption=$(grep -w "EncrypType" ${wirelessdatfile})        
					encrypt_replace="EncrypType=$wifi1encryption;$guestwifi1encryption"
					sed -i "s/${encryption}/${encrypt_replace}/" "$wirelessdatfile"
				fi   
				wpapsk1=$(grep -w "WPAPSK1" ${wirelessdatfile})        
				wpapsk1_replace="WPAPSK1=$Wifi1Key"
				sed -i "s/${wpapsk1}/${wpapsk1_replace}/" "$wirelessdatfile"
				
				hidessid=$(grep -w "HideSSID" ${wirelessdatfile})        
				hidessid_replace="HideSSID=0"
				sed -i "s/${hidessid}/${hidessid_replace}/" "$wirelessdatfile"
				uci set wireless.ap.disabled="0"
				uci set wireless.ap.ssid="$Wifi1Ssid"
				uci set wireless.ap.key="$Wifi1Key"
				uci set wireless.ap.encryption="$wifi1encryption"
				uci set network."${wifiap}"=interface
				uci set network."${wifiap}".ipaddr="$Radio0DhcpIp"
				uci set network."${wifiap}".netmask="255.255.255.0"
				uci set network."${wifiap}".proto="static"
				uci set network."${wifiap}".ifname="ra0"
				
				uci set dhcp."${wifiap}"=dhcp
				uci set dhcp."${wifiap}".interface="${wifiap}"
				uci set dhcp."${wifiap}".start="$Radio0DHCPRange"
				uci set dhcp."${wifiap}".limit="$Radio0DHCPLimit"
				uci set dhcp."${wifiap}".leasetime="12h"
				uci set dhcp."${wifiap}".dhcpv6="disabled"
				uci set dhcp."${wifiap}".ra="disabled"
				
			
				if [ "$EnableDhcpRelay" = "1" ]
				then
				   uci delete dhcp."${wifiap}"
				   echo "dhcp-relay=${Radio0DhcpIp},${WifiRelayServerIP}" >> /etc/dnsmasq.conf
				   uci set network."${wifiap}".ipaddr="$Radio0DhcpIp"
				fi
			
				uci set wireless.sta.disabled="0"
				uci set wireless.sta.ssid="$Wifi1StaSsid"
				uci set wireless.sta.key="$Wifi1StaKey"
				
				if [ "$Wifi1StaEncryption" = "WPA2PSK" ];then
					uci set wireless.sta.encryption="psk2"
				elif [ "$Wifi1StaEncryption" = "WPAPSK" ];then
					uci set wireless.sta.encryption="psk"
				elif [ "$Wifi1StaEncryption" = "NONE" ];then
					uci set wireless.sta.encryption="none"
				elif [ "$Wifi1StaEncryption" = "WPA1PSKWPA2PSK" ];then
					uci set wireless.sta.encryption="psk-mixed"
				fi
				uci set network.WIFI_WAN=interface
				uci set network.WIFI_WAN.proto="dhcp"
				Select=$(uci get mwan3config.general.select)
				WifiWanPriority=$(uci get mwan3config.WIFI_WAN.wanpriority)
				if [ "$Select" =  "failover" ] && [ -z "$WifiWanPriority" ]
				then
					uci set network.WIFI_WAN.metric="12"
				else 
					uci set network.WIFI_WAN.metric="$WifiWanPriority"
				fi
				uci set network.WIFI_WAN.ifname="apcli0"           
			fi
		fi
	uci commit wireless
	uci commit network
	uci commit dhcp
	logger -t config -p customs.info "wireless configuration changed"
	logger -t config -p customs.info "dhcp configuration changed"
}

UpdateScheduledWifiOnOff()
{   	
	CronReadListValuesMaintenanceReboot()
	{
		TmpVal=""
		local value="$1"
		local VarName="$2"
		TmpVal="$(eval echo '$'ListValue"$VarName")"
		eval ListValue"$VarName"="${TmpVal}${value},"
	
	}
	
	if [ "$Wifi1Mode" = "ap" ] || [ "$Wifi1Mode" = "apsta" ]
	then		
	
		if [ "$ScheduledOnOff" = "1" ]
		then
			config_load "$SystemConfigFile"             
			config_list_foreach "wirelessconfig" fromHours CronReadListValuesMaintenanceReboot fromHours
			config_list_foreach "wirelessconfig" fromMinutes CronReadListValuesMaintenanceReboot fromMinutes
			config_list_foreach "wirelessconfig" toHours CronReadListValuesMaintenanceReboot toHours
			config_list_foreach "wirelessconfig" toMinutes CronReadListValuesMaintenanceReboot toMinutes
			config_list_foreach "wirelessconfig" DayOfMonth CronReadListValuesMaintenanceReboot DayOfMonth
			config_list_foreach "wirelessconfig" Month CronReadListValuesMaintenanceReboot Month
			config_list_foreach "wirelessconfig" DayOfWeek CronReadListValuesMaintenanceReboot DayOfWeek
				
			ListValfromHours=$(echo "$ListValuefromHours" | sed s'/,$//')
			ListValfromMinutes=$(echo "$ListValuefromMinutes" | sed s'/,$//')
			ListValtoHours=$(echo "$ListValuetoHours" | sed s'/,$//')
			ListValtoMinutes=$(echo "$ListValuetoMinutes" | sed s'/,$//')
			ListValDayOfWeek=$(echo "$ListValueDayOfWeek" | sed s'/,$//')
			ListValDayOfMonth=$(echo "$ListValueDayOfMonth" | sed s'/,$//')
			ListValMonth=$(echo "$ListValueMonth" | sed s'/,$//')
			echo "$ListValfromMinutes $ListValfromHours * * $ListValDayOfWeek /root/InterfaceManager/script/wireless/ScheduledWifiOff.sh" >> /etc/crontabs/root
			echo "$ListValtoMinutes $ListValtoHours * * $ListValDayOfWeek /root/InterfaceManager/script/wireless/ScheduledWifiOn.sh" >> /etc/crontabs/root
		elif [ "$ScheduledOnOff" = "0" ];then 
			sed -i '/ScheduledWifiOff.sh/d' /etc/crontabs/root
			sed -i '/ScheduledWifiOn.sh/d' /etc/crontabs/root	
		fi
	fi
}

UpdateFirewallConfig()
{
		Radio0AccessPointEnable=$(uci get sysconfig.wificonfig.wifi1enable)	
		uci delete firewall.wifi_wan > /dev/null 2>&1
		uci delete firewall.wifi > /dev/null 2>&1
		uci delete firewall.guestwifi > /dev/null 2>&1

		
		if [ "$Wifi1Enable" = "0" ]
		then 
		   uci delete firewall.wifi_wan > /dev/null 2>&1
		   uci delete firewall.wifi > /dev/null 2>&1
		   uci delete firewall.guestwifi > /dev/null 2>&1
		else
			if [ "$Wifi1Enable" = "1" ]
			then
			    if [ "$guestwifienable" = "1" ]
				then
					uci set firewall.guestwifi=zone
					uci set firewall.guestwifi.name="$wifiap1"
					uci set firewall.guestwifi.input="ACCEPT"
					uci set firewall.guestwifi.output="ACCEPT"
					uci set firewall.guestwifi.forward="REJECT"
					uci set firewall.guestwifi.network="$wifiap1"
					uci set firewall.guestwifi.masq="1"
					uci set firewall.guestwifi.mtu_fix="1"
			    else
					uci delete firewall.guestwifi > /dev/null 2>&1
				fi
				if [ "$Wifi1Mode" = "ap" ] || [ "$Wifi1Mode" = "apsta" ]
				then
					uci delete firewall.wifi_wan > /dev/null 2>&1
					uci set firewall.wifi=zone
					uci set firewall.wifi.name="$wifiap"
					uci set firewall.wifi.input="ACCEPT"
					uci set firewall.wifi.output="ACCEPT"
					uci set firewall.wifi.forward="REJECT"
					uci set firewall.wifi.network=ra0
					uci set firewall.wifi.masq="1"
					uci set firewall.wifi.mtu_fix="1"
					uci set firewall.wifi.extra_src="-m policy --dir in --pol none"
					uci set firewall.wifi.extra_dest="-m policy --dir out --pol none"	
				else
					uci delete firewall.wifi > /dev/null 2>&1
				fi 
				
				if [ "$Wifi1Mode" = "sta" ] ||  [ "$Wifi1Mode" = "apsta" ]
				then
					 #uci delete firewall.wifi > /dev/null 2>&1
					 uci set firewall.wifi_wan=zone
					 uci set firewall.wifi_wan.name="$wifista"
					 uci set firewall.wifi_wan.input="ACCEPT"
					 uci set firewall.wifi_wan.output="ACCEPT"
					 uci set firewall.wifi_wan.forward="REJECT"
					 uci set firewall.wifi_wan.network="$wifista"
					 uci set firewall.wifi_wan.masq="1"
					 uci set firewall.wifi_wan.mtu_fix="1"
					 uci set firewall.wifi_wan.extra_src="-m policy --dir in --pol none"
					 uci set firewall.wifi_wan.extra_dest="-m policy --dir out --pol none"   
				else
					 uci delete firewall.wifi_wan
				fi
			fi
		fi
		
/root/InterfaceManager/script/update_firewall.sh

		
}

SystemConfigFile="/etc/config/sysconfig"
ReadSystemConfigFile
UpdateWirelessConfig
UpdateFirewallConfig
UpdateScheduledWifiOnOff
uci commit firewall
