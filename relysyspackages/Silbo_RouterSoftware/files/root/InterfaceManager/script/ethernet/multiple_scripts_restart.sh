#!/bin/sh

. /lib/functions.sh

Operation_Mode=$(uci get sysconfig.sysconfig.CellularOperationMode)

IPSEC(){

	#Get the default ifname from routing table.
	interface_list=$(route -n | awk NR==3 | awk '{print $8}')

	#Ethernet
	wanCount=$(cat /etc/waninterface.txt | wc -l)
	for j in $(seq 1 ${wanCount}); do
		wan=$(cat /etc/waninterface.txt | head -${j} | tail -1)

		#Get the ifname for every interface name
		match_ifname=$(uci get network.$wan.ifname)

		#To get the interface name of the default route ifname, match the ifname from waninterface.txt
		#with the ifname from routing table .

		if [ "$match_ifname" = "$interface_list" ]; then
			interface_name="$wan"
			break
		fi
	done
	
	#Ethernet
	if [ -n "$interface_name" ]; then
		uci set ipsec.general.interface="$interface_name"
		uci set firewall.ipsec_rule1.src="$interface_name"
		uci set firewall.ipsec_rule2.src="$interface_name"
		uci set firewall.ipsec_rule3.src="$interface_name"
	fi

	#STA
	if [ "$interface_list" = "apcli0" ]; then
		uci set ipsec.general.interface="WIFI_WAN"
		uci set firewall.ipsec_rule1.src="WIFI_WAN"
		uci set firewall.ipsec_rule2.src="WIFI_WAN"
		uci set firewall.ipsec_rule3.src="WIFI_WAN"
	fi

	#Cellular
	#DualCellularSinglesim

	#Get the CellularOperationMode
	Cellular_mode=$(uci get sysconfig.sysconfig.CellularOperationMode)
	#Get the CWAN1_Enable
	CWAN1_Enable=$(uci get modem.CWAN1.modemenable)
	#Get the CWAN2_Enable
	CWAN2_Enable=$(uci get modem.CWAN2.modemenable)


	if [ "$Cellular_mode" = "dualcellularsinglesim" ]                                                          
	then
		 if [ "$CWAN1_Enable" = "1" ]
		 then
			  CWAN1_Ifname=$(uci get modem.CWAN1.ifname)
		 fi
		 
		 if [ "$CWAN2_Enable" = "1" ]
		 then
			  CWAN2_Ifname=$(uci get modem.CWAN2.ifname)
		 fi                       

		
		if [ "$interface_list" = "$CWAN1_Ifname" ]
		then
			uci set ipsec.general.interface="CWAN1"
			uci set firewall.ipsec_rule1.src="CWAN1"                                                                                     
			uci set firewall.ipsec_rule2.src="CWAN1"                                                                                     
			uci set firewall.ipsec_rule3.src="CWAN1"
		fi
		
		if [ "$interface_list" = "$CWAN2_Ifname" ]
		then
			uci set ipsec.general.interface="CWAN2"
			uci set firewall.ipsec_rule1.src="CWAN2"                                                                                     
			uci set firewall.ipsec_rule2.src="CWAN2"                                                                                     
			uci set firewall.ipsec_rule3.src="CWAN2"
		fi
	elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]; then
		if [ "$interface_list" = "usb0" ] || [ "$interface_list" = "wwan0" ] || [ "$interface_list" = "usb1" ] || [ "$interface_list" = "wwan1" ]; then
			simnum=$(cat /tmp/simnumfile)
			if [ "$simnum" = "1" ]; then
				uci set ipsec.general.interface="CWAN1_0"
				uci set firewall.ipsec_rule1.src="CWAN1_0"
				uci set firewall.ipsec_rule2.src="CWAN1_0"
				uci set firewall.ipsec_rule3.src="CWAN1_0"
			else
				uci set ipsec.general.interface="CWAN1_1"
				uci set firewall.ipsec_rule1.src="CWAN1_1"
				uci set firewall.ipsec_rule2.src="CWAN1_1"
				uci set firewall.ipsec_rule3.src="CWAN1_1"
			fi
		fi
	else
		if [ "$interface_list" = "usb0" ] || [ "$interface_list" = "wwan0" ] || [ "$interface_list" = "usb1" ] || [ "$interface_list" = "wwan1" ]; then
			uci set ipsec.general.interface="CWAN1"
			uci set firewall.ipsec_rule1.src="CWAN1"
			uci set firewall.ipsec_rule2.src="CWAN1"
			uci set firewall.ipsec_rule3.src="CWAN1"
		fi
	fi
														  
	uci commit ipsec
	uci commit firewall
	
	sleep 1
	
	/etc/init.d/firewall reload
	/etc/init.d/ipsec stop
	
	/bin/sleep 1
	
	/etc/init.d/ipsec start
	
	/bin/sleep 4                                                                    
	
	/usr/sbin/ipsec restart

}

#IPSEC
IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)
if [ "$IpsecEnable" = "1" ] ; then 
	IPSEC
fi

#OPENVPN
OpenvpnEnable=$(uci get vpnconfig1.general.enableopenvpngeneral)
if [ "$OpenvpnEnable" = "1" ] ; then
	/root/InterfaceManager/script/vpn/openvpn/openvpn_handler.sh
fi

#NMS
NMS_Enable=$(uci get remoteconfig.nms.nmsenable)
if [ "${NMS_Enable}" = "1" ]
then
	/root/InterfaceManager/script/vpn/openvpn/openvpn_handler.sh
fi

#ZEROTIER
Enablezerotier=$(uci get vpnconfig1.general.enablezerotiergeneral)                                                                                                        
if [ "${Enablezerotier}" = "1" ]                                                                                             
then                                                                                                                     
	/root/InterfaceManager/script/vpn/zerotier/zerotier_handler.sh
fi

#WIREGUARD
Enablewireguard=$(uci get vpnconfig1.general.enablewireguardgeneral)                                                                                                                         
if [ "${Enablewireguard}" = "1" ]                                                                                         
then                                                                                                                     
	/root/InterfaceManager/script/vpn/wireguard/wireguard_handler.sh
fi 
  
#VRRP
EnableVRRP=$(uci get vrrpd.general.enablevrrpd)                                                                                                                                                             
if [ "${EnableVRRP}" = "1" ]                                                                          
then
	/root/InterfaceManager/script/vrrp/vrrp_handler.sh & 
fi


exit 0
