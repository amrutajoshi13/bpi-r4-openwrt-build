#!/bin/sh

. /lib/functions.sh

NetworkInterfacesFile="/etc/config/networkinterfaces"
waninterface=""
laninterface=""
internetoverlan=""

Wifi="wifi"
wifista="WIFI_WAN"
wifiap="ra0"
wifiap1="ra1"
Wifi1Enable=$(uci get sysconfig.wificonfig.wifi1enable)
Wifi1Mode=$(uci get sysconfig.wificonfig.wifi1mode)
Guestwifienable=$(uci get sysconfig.guestwifi.guestwifienable)


EnableCellular=$(uci get sysconfig.sysconfig.enablecellular)
CellularOperationModelocal=$(uci get sysconfig.sysconfig.CellularOperationMode)

Select=$(uci get mwan3config.general.select)

sim1="cwan1_0"
cellularwan1sim1interface="CWAN1_0"
sim2="cwan1_1"
cellularwan1sim2interface="CWAN1_1"
singlesim="cwan1"
cellularwan1interface="CWAN1"

DeleteinterenetOverInterface()
{
	lanCount=$(cat /etc/internetoverlan.txt | wc -l)
	wanCount=$(cat /etc/waninterface.txt | wc -l)
	
	for i in $(seq 1 ${lanCount})
	do
		lan=$(cat /etc/internetoverlan.txt | head -${i} | tail -1)
		for j in $(seq 1 ${wanCount})
		do		   
			wan=$(cat /etc/waninterface.txt | head -${j} | tail -1) 
			uci delete firewall.${lan}${wan}  > /dev/null 2>&1
			uci delete firewall.${lan}${sim1} > /dev/null 2>&1
			uci delete firewall.${lan}${sim2} > /dev/null 2>&1
			uci delete firewall.${lan}${singlesim} > /dev/null 2>&1
			####--->
			uci delete firewall.${wan}${lan}  > /dev/null 2>&1
			uci delete firewall.${wan}${sim1} > /dev/null 2>&1
			uci delete firewall.${wan}${sim2} > /dev/null 2>&1
			uci delete firewall.${wan}${singlesim} > /dev/null 2>&1
			#<----###
			uci delete firewall.${lan}${wifista} > /dev/null 2>&1
			uci delete firewall.${lan}${wifiap} > /dev/null 2>&1
			uci delete firewall.${lan}${wifiap1} > /dev/null 2>&1
			uci delete firewall.${wifiap}${lan} > /dev/null 2>&1
			uci delete firewall.${wifiap1}${lan} > /dev/null 2>&1
			uci delete firewall.${wifiap}${wan} > /dev/null 2>&1
			uci delete firewall.${wifiap1}${wan} > /dev/null 2>&1		
			
		done
	done
	
	uci commit firewall
	#/etc/init.d/firewall restart
}

interenetOverInterface()
{
	lanCount=$(cat /etc/internetoverlan.txt | wc -l)
	wanCount=$(cat /etc/waninterface.txt | wc -l)
	
	for i in $(seq 1 ${lanCount})
	do
		lan=$(cat /etc/internetoverlan.txt | head -${i} | tail -1)
		
		#When there's no waninterface.txt file, but we still want forwarding from CWANs & lans.	
		if [ "$wanCount" = "0" ]
		then
			wanCount="1"
		fi
		
		for j in $(seq 1 ${wanCount})
		do		   
			wan=$(cat /etc/waninterface.txt | head -${j} | tail -1) 
			
			if [ -z "$wan" ]
			then
				 echo
			else
				uci set firewall.${lan}${wan}=forwarding
				uci set firewall.${lan}${wan}.src="$lan"
				uci set firewall.${lan}${wan}.dest="$wan"
			fi
		###################################################################	
			if [ "$Wifi1Enable" = "1" ]
			then
			     if [ "$Wifi1Mode" = "sta" ] ||  [ "$Wifi1Mode" = "apsta" ]
				 then
			          uci set firewall.${lan}${wifista}=forwarding
			          uci set firewall.${lan}${wifista}.src="$lan"
			          uci set firewall.${lan}${wifista}.dest="$wifista"
			     fi
			fi
			
			if [ "$EnableCellular" = "1" ]
	        then
		         if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		         then
		              uci delete firewall.${lan}${singlesim} 
		         
		              uci set firewall.${lan}${sim1}=forwarding
				      uci set firewall.${lan}${sim1}.src="$lan"
				      uci set firewall.${lan}${sim1}.dest="$cellularwan1sim1interface"
			 
			          uci set firewall.${lan}${sim2}=forwarding
				      uci set firewall.${lan}${sim2}.src="$lan"
				      uci set firewall.${lan}${sim2}.dest="$cellularwan1sim2interface"
				      
			     else
			          if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
			          then 
							uci delete firewall.${lan}${sim1}
						    uci delete firewall.${lan}${sim2}	
			           
							uci set firewall.${lan}${singlesim}=forwarding
							uci set firewall.${lan}${singlesim}.src="$lan"
							uci set firewall.${lan}${singlesim}.dest="$cellularwan1interface"
					  fi
			     fi
			fi    
					
		done
	done
	         
			if [ "$Wifi1Enable" = "1" ]
			then
			    if [ "$Wifi1Mode" = "ap" ] || [ "$Wifi1Mode" = "apsta" ]
				then
					if [ -n "$wanCount" ]
					then
					wan_interfaces=$(cat /etc/config/networkinterfaces | grep -i type | grep -c WAN)
                    if [ "$wan_interfaces" -gt 0 ]  
                    then                                               
					    wanCount=$(cat /etc/waninterface.txt | wc -l)				
						for i in $(seq 1 ${wanCount})
						do
							wan=$(cat /etc/waninterface.txt | head -${i} | tail -1)
							
							uci set firewall.${wifiap}${wan}=forwarding
							uci set firewall.${wifiap}${wan}.src="$wifiap"
							uci set firewall.${wifiap}${wan}.dest="$wan"
			          
							if [ "$Guestwifienable" = '1' ]
							then 
								echo "$Guestwifienable" 
								uci set firewall.${wifiap1}${wan}=forwarding
								uci set firewall.${wifiap1}${wan}.src="$wifiap1"
								uci set firewall.${wifiap1}${wan}.dest="$wan" 
							else
								uci delete firewall.${wifiap1}${wan} > /dev/null 2>&1   
							fi
						done				
					
				    fi	   
				fi
			 fi	
		   else
				uci delete firewall.${wifiap}${wan} > /dev/null 2>&1		
		   fi  
	uci commit firewall	 	 
		 	 
}

ReadNetworkinterfaceConfigFile()
{
	config_load "$NetworkInterfacesFile"
	config_foreach UpdateNetworkinterfaceConfigFile redirect

}

UpdateNetworkinterfaceConfigFile()
{
	
 readnetint="$1"
 
	config_get Interfacename "$readnetint" interface	
	config_get protocol "$readnetint" protocol	
	config_get protocol_lan "$readnetint" protocol_lan	
	config_get ifname "$readnetint" ifname	
	config_get type "$readnetint" type
	config_get EthernetClientPppoeUsername "$readnetint" EthernetClientPppoeUsername
	config_get EthernetClientPppoePassword "$readnetint" EthernetClientPppoePassword
	config_get EthernetClientPppoeAccessConcentrator "$readnetint" EthernetClientPppoeAccessConcentrator
	config_get EthernetClientPppoeServiceName "$readnetint" EthernetClientPppoeServiceName
	config_get enable_zoneforward "$readnetint" enable_zoneforward
	config_get internetoverinterface "$readnetint" internetoverinterface
	config_get advanced_settings "$readnetint" advanced_settings
	config_get enableipv4routetable "$readnetint" enableipv4routetable
	config_get ip4table "$readnetint" ip4table
	config_get gatewaymetric "$readnetint" gatewaymetric
	config_get broadcast "$readnetint" broadcast
	config_get mtu "$readnetint" mtu
	config_get macaddress "$readnetint" macaddress
	config_get delegate "$readnetint" delegate
	config_get force_link "$readnetint" force_link
	config_get enable_bridge "$readnetint" enable_bridge
	config_get bridge_interfaces "$readnetint" bridge_interfaces
	config_get enable_dhcprelay "$readnetint" enable_dhcprelay
	config_get EthernetRelayServerIP "$readnetint" EthernetRelayServerIP
	
	###################### 06-03-2025 IPV6  #############################333
	
	#IPV6 WAN Iputs 
	config_get ipmodewan "$readnetint" ipmodewan
	config_get staticgatewayv6 "$readnetint" staticgatewayv6
	config_get ipv6requestmode "$readnetint" ipv6requestmode
	config_get ipv6requestprefix "$readnetint" ipv6requestprefix
	config_get ipmodelandelegateprefix "$readnetint" ipmodelandelegateprefix
	config_get ipv6_metric "$readnetint" ipv6_metric
	config_get ipv6defaultroute "$readnetint" ipv6defaultroute
	config_get staticIPv6wan "$readnetint" staticIPv6wan 
	config_get staticnetmaskv6 "$readnetint" staticnetmaskv6
	
	###################### 06-03-2025 IPV6  #############################333
 
 #Save all the WAN interfaces in waninterface.txt
 if [[ "$type" == "WAN" ]]
 then 
      waninterface="${waninterface},${Interfacename}"
      echo "$Interfacename" >> /etc/waninterface.txt
 fi
 #Save all the LAN interfaces in laninterface.txt
 if [[ "$type" == "LAN" ]]
 then 
	laninterface="${laninterface},${Interfacename}"
	echo "$Interfacename" >> /etc/laninterface.txt
 fi
 	  
 #Save all the LAN interfaces in internetoverlan.txt only when that particular interface has internetoverinterface selected.
 if [[ "$type" == "LAN" ]] && [[ "$internetoverinterface" == "1" ]] && [[ "$enable_zoneforward" == "1" ]]
 then
	 echo "$Interfacename" >> /etc/internetoverlan.txt
 fi
		  
 	   #Delete the interface first, before creating the interface in network file.
		uci delete network.$Interfacename
		uci delete dhcp.$Interfacename
		
 	
 	    #STATIC Protocol (LAN)
		if [ "$protocol_lan" = "static_lan" ] && [ "$type" = "LAN" ]
		then 
			config_get staticipaddr "$readnetint" staticIP
			config_get staticnetmask "$readnetint" staticnetmask
			config_get static_lan_enable_dns "$readnetint" static_lan_enable_dns
			config_get static_lan_Dns_Server "$readnetint" static_lan_Dns_Server
			config_get custom_DHCP_options "$readnetint" custom_DHCP_options
			config_get enable_dns "$readnetint" enable_dns 
			config_get ServerStaticDnsServer "$readnetint" ServerStaticDnsServer
			config_get enable_gateway "$readnetint" enable_gateway 
			config_get ServerStaticGateways "$readnetint" ServerStaticGateways
			config_get enable_dhcpv4 "$readnetint" enable_dhcpv4
			config_get enable_dhcpv6 "$readnetint" enable_dhcpv6
			config_get dhcprange "$readnetint" ServerDHCPrange 
			config_get dhcplimit "$readnetint" ServerDHCPlimit 
			config_get leasetimehr "$readnetint" leasetimehr 
			config_get leasetimemin "$readnetint" leasetimemin
			config_get leasetimesec "$readnetint" leasetimesec
			config_get leasetime_duration "$readnetint" leasetime_duration
			
			################# 10-03-2025 ############################
			
			config_get enable_netmask "$readnetint" enable_netmask
			config_get ServerNetmask "$readnetint" ServerNetmask
			config_get enable_ntp_sever "$readnetint" enable_ntp_sever
			config_get ServerNTP "$readnetint" ServerNTP
			config_get enable_tftp_server "$readnetint" enable_tftp_server
			config_get ServerTFTP "$readnetint" ServerTFTP
			config_get enable_bootfile "$readnetint" enable_bootfile
			config_get ServerBootfileName "$readnetint" ServerBootfileName
			config_get enable_custom_option "$readnetint" enable_custom_option
			config_get ServerCustomOption "$readnetint" ServerCustomOption
		
			################# 10-03-2025 ############################
			
			############### 06-03-2025 IPV6 ################
			
			#For IPV6 LAN
			config_get ipmodelan "$readnetint" ipmodelan
			config_get staticIPv6 "$readnetint" staticIPv6 
			config_get staticnetmaskv6 "$readnetint" staticnetmaskv6
			config_get ipmodelandelegateprefix "$readnetint" ipmodelandelegateprefix
			config_get ipv6delegateprefix "$readnetint" ipv6delegateprefix
			config_get ipv6prefixhint "$readnetint" ipv6prefixhint
			config_get ipv6interval "$readnetint" ipv6interval
			config_get ra_mininterval "$readnetint" ra_mininterval
			config_get ra_maxinterval "$readnetint" ra_maxinterval 
			config_get ipv6metric "$readnetint" ipv6metric 
			config_get ipv6addressingmode "$readnetint" ipv6addressingmode
			config_get ipv6relayingmode "$readnetint" ipv6relayingmode
			
			
			############### 06-03-2025 IPV6 ################

			#NETWORK Config
			uci set network.$Interfacename=interface
			uci set network.$Interfacename.ifname=$ifname
			uci set network.$Interfacename.proto='static'
			uci set network.$Interfacename.ipaddr=$staticipaddr
			uci set network.$Interfacename.netmask=$staticnetmask
			
		############### 06-03-2025 IPV6 ################
		
			############### 06-08-2025 ##############--->>
			
			#Configure DNS provider.
			#OpenWrt uses peer DNS as the upstream resolvers for dnsmasq by default. 
			#These are typically provided by the ISP upstream DHCP server.
			#Hence, when the proto is static, we have to add list dns in network config file, 
			#else, domain name will not be resolved. That is, google.com cannot be opened.
			
			#Delete the earlier dns and replace it with new.
			uci -q delete network.$Interfacename.dns
			if [[ "$static_lan_enable_dns" == "1" && -n "$static_lan_Dns_Server" ]]; then
				for dns in $static_lan_Dns_Server; do
					uci add_list network.$Interfacename.dns="$dns"
				done
			fi
			
			############### 06-08-2025 ##############--->>
		
		
			
			if [ "$ipmodelan" = "1" ] && [ "$type" = "LAN" ]
			then 	
				uci set network.$Interfacename.ip6addr=$staticIPv6
				#uci set network.$Interfacename.netmask=$staticnetmaskv6
				uci set network.$Interfacename.ip6hint=$ipv6prefixhint
				uci set network.$Interfacename.metric=$ipv6metric
					if [ "$ipmodelandelegateprefix" = "1" ]
					then 
						uci set network.$Interfacename.delegate="1"
						uci set network.$Interfacename.ip6assign="$ipv6delegateprefix"
					else
						uci set network.$Interfacename.delegate="0"
						uci delete.network.$Interfacename.ip6assign
					fi
					if [ "$ipv6interval" = "1" ]
					then 
						uci set network.$Interfacename.ra_mininterval="$ra_mininterval"
						uci set network.$Interfacename.ra_maxinterval="$ra_maxinterval"
					fi
			fi
			
		    #DHCP
			uci set dhcp.$Interfacename=dhcp
			uci set dhcp.$Interfacename.interface=$Interfacename
			uci set dhcp.$Interfacename.start=$dhcprange
			uci set dhcp.$Interfacename.limit=$dhcplimit
			uci set dhcp.$Interfacename.dhcpv4='disabled'
			uci set dhcp.$Interfacename.dhcpv6='disabled'
			if [ "$leasetime_duration" = "h" ]
			then
				uci set dhcp.$Interfacename.leasetime=$leasetimehr$leasetime_duration
			elif [ "$leasetime_duration" = "m" ]
			then
				uci set dhcp.$Interfacename.leasetime=$leasetimemin$leasetime_duration
			else
				uci set dhcp.$Interfacename.leasetime=$leasetimesec$leasetime_duration
			fi

			# First, compute an “effective” DHCPv6 flag that’s only 1 if both GUI and ipmodelan are set.
			# This is to solve -- In gui, if the checkbox for ipmodelan and enable_dhcpv6 is clicked, 
			# then in config file, it would write 1 for both. But, if just the ipmodelan is unchecked then, 
			# the value for ipmodelan is 0 but it is still 1 for enable_dhcpv6.
			if [ "$enable_dhcpv6" = "1" ] && [ "$ipmodelan" = "1" ]; then
				effective_dhcpv6=1
			else
				effective_dhcpv6=0
			fi
			
			if [ "$enable_dhcpv4" = "1" ] && [ "$effective_dhcpv6" = "0" ] 
			then
				uci set dhcp.$Interfacename.dhcpv4='server'
				uci set dhcp.$Interfacename.dhcpv6='disabled'
				uci set dhcp.$Interfacename.ra='disabled'
			elif [ "$effective_dhcpv6" = "1" ] && [ "$enable_dhcpv4" = "0" ]
			then
				uci set dhcp.$Interfacename.dhcpv6='server'				
				uci set dhcp.$Interfacename.ra='server'
				uci set dhcp.$Interfacename.dhcpv4='disabled'
			elif [ "$enable_dhcpv4" = "1" ] && [ "$effective_dhcpv6" = "1" ]
			then	
				uci set dhcp.$Interfacename.dhcpv4='server'
				uci set dhcp.$Interfacename.dhcpv6='server'
				uci set dhcp.$Interfacename.ra='server'
			elif [ "$enable_dhcpv4" = "0" ] && [ "$effective_dhcpv6" = "0" ]
			then 
				# Disable the IPv4 server if none of the above modes are matched.
				#uci delete dhcp.$Interfacename
				uci set dhcp.$Interfacename.dhcpv4='disabled'
				uci set dhcp.$Interfacename.dhcpv6='disabled'
				uci set dhcp.$Interfacename.ra='disabled'
			fi	
			
			if [ "$enable_dhcpv6" = "1" ] && [ "$ipmodelan" = "1" ]
			then
				# STATEFUL
				if [[ "$ipv6addressingmode" = "stateful" ]]; then
					uci set dhcp.$Interfacename.ra='server'
					uci set dhcp.$Interfacename.ndp='disabled'
					uci set dhcp.$Interfacename.ra_management='2'

				# STATELESS ONLY (SLAAC)
				elif [[ "$ipv6addressingmode" = "stateless" ]]; then
					uci set dhcp.$Interfacename.ra='server'
					uci set dhcp.$Interfacename.ndp='disabled'
					uci set dhcp.$Interfacename.ra_management='0'

				# STATEFUL + STATELESS
				elif [[ "$ipv6addressingmode" = "stateful_stateless" ]]; then
					uci set dhcp.$Interfacename.ra='server'
					uci set dhcp.$Interfacename.ndp='disabled'
					uci set dhcp.$Interfacename.ra_management='1'

				# IPv6 RELAY
				elif [[ "$ipv6addressingmode" = "ipv6_relay" ]]; then
					uci delete dhcp.wan6
					uci delete dhcp.wan6c1
					uci delete dhcp.wan6c2
					uci commit dhcp
					
					#uci set dhcp.$Interfacename.dhcpv4='disabled'
					uci set dhcp.$Interfacename.dhcpv6='disabled'
					uci set dhcp.$Interfacename.ra='relay'
					uci set dhcp.$Interfacename.ndp='relay'

					#One more Section For Relay
					uci set dhcp.$ipv6relayingmode=dhcp
					uci set dhcp.$ipv6relayingmode.interface="$ipv6relayingmode"
					uci set dhcp.$ipv6relayingmode.dhcpv6='disabled'
					uci set dhcp.$ipv6relayingmode.ra='relay'
					uci set dhcp.$ipv6relayingmode.ndp='relay'
					uci set dhcp.$ipv6relayingmode.master='1'

				# IPv6 RELAY HYBRID
				elif [[ "$ipv6addressingmode" = "ipv6_relay_hybrid" ]]; then
					uci delete dhcp.wan6
					uci delete dhcp.wan6c1
					uci delete dhcp.wan6c2
					uci commit dhcp
					
					uci set dhcp.$Interfacename.dhcpv6='disabled'
					uci set dhcp.$Interfacename.ra='hybrid'
					uci set dhcp.$Interfacename.ndp='relay'

					#One more Section For Hybrid
					uci set dhcp.$ipv6relayingmode=dhcp
					uci set dhcp.$ipv6relayingmode.interface="$ipv6relayingmode"
					uci set dhcp.$ipv6relayingmode.dhcpv6='disabled'
					uci set dhcp.$ipv6relayingmode.ra='hybrid'
					uci set dhcp.$ipv6relayingmode.ndp='relay'
					uci set dhcp.$ipv6relayingmode.master='1'		
				fi
			else
				uci set dhcp.$Interfacename.ra='disabled'
				uci delete dhcp.$Interfacename.ndp
				uci delete dhcp.$ipv6relayingmode
			fi
		############### 06-03-2025 IPV6 ################			
		
			#delete_olddns=$(uci get network.$Interfacename.dns)
			#uci del_list network.$Interfacename.dns="$delete_olddns"
				
				##Delete the old dhcp_options, if present.
				#existing_dhcp_options=$(uci get dhcp.$Interfacename.dhcp_option)
			
					#if [ -n "$existing_dhcp_options" ]; then
						#for option in $existing_dhcp_options; do
							#uci del_list dhcp.$Interfacename.dhcp_option="$option"
						#done
					#fi
				
					######################
					## CUSTOM DHCP OPTIONS
					######################
					#if [[ "$custom_DHCP_options" = "1" ]]
					#then	
						## Configure custom DNS (option 6)
						#if [[ "$enable_dns" == "1" && -n "$ServerStaticDnsServer" ]]; then
							#local dns_combined="6"
							#for dns_ip in $ServerStaticDnsServer; do
								#dns_combined="$dns_combined,$dns_ip"
							#done
							#uci add_list dhcp.$Interfacename.dhcp_option="$dns_combined"
						#fi

						## Configure custom Gateway (option 3)
						#if [[ "$enable_gateway" == "1" && -n "$ServerStaticGateways" ]]; then
							#local gateway_combined="3"
							#for gateway_ip in $ServerStaticGateways; do
								#gateway_combined="$gateway_combined,$gateway_ip"
							#done
							#uci add_list dhcp.$Interfacename.dhcp_option="$gateway_combined"
						#fi
					#fi
			
			##################################################################################
			
						#Delete the old dhcp_options, if present.
			existing_dhcp_options=$(uci get dhcp.$Interfacename.dhcp_option)
			
			if [ -n "$existing_dhcp_options" ]; then
				for option in $existing_dhcp_options; do
					uci del_list dhcp.$Interfacename.dhcp_option="$option"
				done
			fi
			
			#####################
			# CUSTOM DHCP OPTIONS
			#####################
			if [[ "$custom_DHCP_options" = "1" ]]
			then
				
				# Configure custom netmask (option 1)
				# Length - 4 octates.
				if [[ "$enable_netmask" == "1" && -n "$ServerNetmask" ]]; then
					local netmask_option="1"
					uci add_list dhcp.$Interfacename.dhcp_option="$netmask_option,$ServerNetmask"
				fi
				
				# Configure custom Gateway/router (option 3)
				# Length - Multiples of 4 octates.
				if [[ "$enable_gateway" == "1" && -n "$ServerStaticGateways" ]]; then
					local gateway_combined="3"
					for gateway_ip in $ServerStaticGateways; do
						gateway_combined="$gateway_combined,$gateway_ip"
					done
					uci add_list dhcp.$Interfacename.dhcp_option="$gateway_combined"
				fi
				
				# Configure custom DNS (option 6)
				# Length - Multiples of 4 octates.
				if [[ "$enable_dns" == "1" && -n "$ServerStaticDnsServer" ]]; then
					local dns_combined="6"
					for dns_ip in $ServerStaticDnsServer; do
						dns_combined="$dns_combined,$dns_ip"
					done
					uci add_list dhcp.$Interfacename.dhcp_option="$dns_combined"
				fi
				
				# Configure custom NTP Server (option 42)
				# Length - Multiples of 4 octates.
				if [[ "$enable_ntp_sever" == "1" && -n "$ServerNTP" ]]; then
					local ntp_server_combined="42"
					for ntp_server in $ServerNTP; do
						ntp_server_combined="$ntp_server_combined,$ntp_server"
					done
					uci add_list dhcp.$Interfacename.dhcp_option="$ntp_server_combined"
				fi
				
				# Configure tftp-server (option 66)
				# Length - minimum of 1 octate. It is string based. Hence, accepts only single string.
				if [[ "$enable_tftp_server" == "1" && -n "$ServerTFTP" ]]; then
					local tftp_option="66"
					uci add_list dhcp.$Interfacename.dhcp_option="$tftp_option,$ServerTFTP"
				fi
				
				# Configure bootfile-name (option 67)
				# Length - minimum of 1 octate. It is string based. Hence, accepts only single string.
				if [[ "$enable_bootfile" == "1" && -n "$ServerBootfileName" ]]; then
					local bootfile_option="67"
					uci add_list dhcp.$Interfacename.dhcp_option="$bootfile_option,$ServerBootfileName"
				fi
				
				# Configure custom option
				# Length - Multiples of 4 octates.
				# We get the custom_option_number from the user.
				if [[ "$enable_custom_option" == "1" && -n "$ServerCustomOption" ]]; then
						for custom_option in $ServerCustomOption; do
							uci add_list dhcp.$Interfacename.dhcp_option="$custom_option"
						done
				fi
			fi
			
			######################## 10-03-2025 ########################################
			
			#STATIC Protocol (WAN)	
			elif [ "$protocol" = "static" ] && [ "$type" = "WAN" ]
			then 
				config_get staticipaddr "$readnetint" staticIP
				config_get staticnetmask "$readnetint" staticnetmask
				config_get staticgateway "$readnetint" staticgateway
				config_get static_wan_enable_dns "$readnetint" static_wan_enable_dns
				config_get static_wan_Dns_Server "$readnetint" static_wan_Dns_Server
				
				#NETWORK Config
				uci set network.$Interfacename=interface
				uci set network.$Interfacename.ifname=$ifname
				uci set network.$Interfacename.proto='static'
				uci set network.$Interfacename.ipaddr=$staticipaddr
				uci set network.$Interfacename.gateway=$staticgateway
				uci set network.$Interfacename.netmask=$staticnetmask
				
				
				if [ "$ipmodewan" = "1" ] 
				then 	
					uci set network.$Interfacename.ip6addr=$staticIPv6wan
					uci set network.wan6=interface
					#uci set network.wan6.ip6addr=$staticIPv6
					#uci set network.$Interfacename_v6.netmask=$staticnetmaskv6
					uci set network.wan6.ip6gw=$staticgatewayv6
					uci set network.wan6.reqprefix="$ipv6requestprefix"
					uci set network.wan6.reqaddress="$ipv6requestmode"
					uci set network.wan6.delegate="$ipmodelandelegateprefix"
					if [ "$ipv6defaultroute" = "1" ]
					then 
						uci set network.wan6.ipv6defaultroute="1"
						uci set network.wan6.metric=$ipv6_metric
					fi	
				else
					uci delete network.wan6
					uci commit network	
                fi
               
				#Delete the earlier dns and replace it with new.
				uci -q delete network.$Interfacename.dns
				if [[ "$static_wan_enable_dns" == "1" && -n "$static_wan_Dns_Server" ]]; then
					for dns in $static_wan_Dns_Server; do
						uci add_list network.$Interfacename.dns="$dns"
					done
				fi
               
          #PPPOE Protocol       
		  elif [ "$protocol" = "pppoe" ] && [ "$type" = "WAN" ]                                              
		  then
				config_get pppoegateway "$readnetint" pppoegateway
				
				uci set network.$Interfacename=interface                         
				uci set network.$Interfacename.ifname=$ifname 
				uci set network.$Interfacename.proto="pppoe"
				uci set network.$Interfacename.username="$EthernetClientPppoeUsername"
				uci set network.$Interfacename.password="$EthernetClientPppoePassword"              
				uci set network.$Interfacename.ac="$EthernetClientPppoeAccessConcentrator"              
				uci set network.$Interfacename.service="$EthernetClientPppoeServiceName"    
				uci set network.$Interfacename.gateway=$pppoegateway    
		
		  #DHCP Protocol
          elif [ "$protocol" = "dhcpclient" ] && [ "$type" = "WAN" ]                                              
		  then 
               config_get dhcpgateway "$readnetint" dhcpgateway
               
               uci set network.$Interfacename=interface
	           uci set network.$Interfacename.ifname=$ifname
               uci set network.$Interfacename.proto='dhcp'
               uci set network.$Interfacename.gateway=$dhcpgateway
               
               if [ "$ipmodewan" = "1" ] 
			   then 
					uci set network.wan6=interface
				    uci set network.wan6.ifname=$ifname
				    uci set network.wan6.ipv6='1'
				    uci set network.wan6.proto='dhcpv6'
					uci set network.wan6.reqprefix="$ipv6requestprefix"
					uci set network.wan6.reqaddress="$ipv6requestmode"
					uci set network.wan6.delegate="0"
					if [ "$ipv6defaultroute" = "1" ]
					then 
						uci set network.wan6.defaultroute="1"
						uci set network.wan6.metric=$ipv6_metric
					fi		
			   else
					uci delete network.wan6
					uci commit network
			   fi  
	      fi
	   
	      #updating override mac address   
	      uci set network.$Interfacename.macaddr=$macaddress
   
	     #Updating DHCP Relay
	     if [[ "$type" = "LAN" ]]
	     then
	          if [[ "$enable_dhcprelay" = "1" ]]
	          then
	                #emptying the file /etc/dnsmasq.conf
					echo -n > /etc/dnsmasq.conf
	                
	                uci set dhcp.$Interfacename.dhcpv4='disabled'
					echo "dhcp-relay=${staticipaddr},${EthernetRelayServerIP}" >> /etc/dnsmasq.conf
			  else
					uci set network."${Interfacename}".ipaddr="$staticipaddr"    
			  fi     
	     fi 
	      
	  uci commit network    
	  ################
	  # FIREWALL ZONE
	  ################
	  #Create firewall Zone
	      if [[ "$enable_zoneforward" = "1" ]]
	      then 
				#Don't create the zone if it is already present.
		
				check_zone=$(uci get firewall.$Interfacename.name)
				
				if [ "$check_zone" != "$Interfacename" ]
				then
					uci set firewall.$Interfacename=zone
					uci set firewall.$Interfacename.name=$Interfacename
					if [ "$type" = "LAN" ]; then
					    uci set firewall.$Interfacename.input='ACCEPT'
					elif [ "$type" = "WAN" ]; then
					    uci set firewall.$Interfacename.input='REJECT'
					fi				
					uci set firewall.$Interfacename.output="ACCEPT"
					uci set firewall.$Interfacename.forward="REJECT"
					uci set firewall.$Interfacename.masq="1"
					uci set firewall.$Interfacename.mtu_fix="1"
					uci set firewall.$Interfacename.network=$Interfacename
					uci set firewall.$Interfacename.extra_src="-m policy --dir in --pol none"
					uci set firewall.$Interfacename.extra_dest="-m policy --dir out --pol none"
				fi
            else
				uci delete firewall.$Interfacename
			
				uci delete firewall.${Interfacename}${sim1} > /dev/null 2>&1
				uci delete firewall.${Interfacename}${sim2} > /dev/null 2>&1
				uci delete firewall.${Interfacename}${singlesim} > /dev/null 2>&1
				uci delete firewall.${Interfacename}${wifista} > /dev/null 2>&1
				uci delete firewall.${Interfacename}${wifiap} > /dev/null 2>&1
				uci delete firewall.${Interfacename}${wifiap1} > /dev/null 2>&1
				
				wanCount=$(cat /etc/waninterface.txt | wc -l)
				for i in $(seq 1 ${wanCount})
				do
					uci delete firewall.${Interfacename}${wan}  > /dev/null 2>&1
				done
				
            fi 
	      
	       if [[ "$enable_bridge" = "1" ]]
	        then 
	        uci set network.$Interfacename.type='bridge'
	        uci set network.$Interfacename.ifname="$ifname $bridge_interfaces"
            else
              uci delete network.$Interfacename.type
              uci set network.$Interfacename.ifname=$ifname
            fi
	      
	   	   if [[ "$advanced_settings" = "1" ]]
		   then  
	         uci set network.$Interfacename.mtu=$mtu
	         uci set network.$Interfacename.broadcast=$broadcast
	          if [[ "$type" = "WAN" ]]
	          then
	               if [ "$Select" =  "failover" ]
				   then
						# METRIC
						#Set metric for mwan3.
						#Lan interface name isn't there in mwan3. So, only Wan interfaces get the metric.
						uci set network.$Interfacename.metric=$gatewaymetric 
						uci set mwan3config.$Interfacename.wanpriority=$gatewaymetric 
						uci set mwan3.${Interfacename}_failover.metric=$gatewaymetric 
				   else
				        uci set network.$Interfacename.metric="1" 
						uci set mwan3.${Interfacename}_balanced.metric="1"
				   fi
	          else
					uci set network.$Interfacename.metric=$gatewaymetric 				
			  fi		
            
            if [[ "$enableipv4routetable" = "1" ]]
	        then 
	        uci set network.$Interfacename.ip4table="$ip4table"
	        fi 
             
	        if [[ "$delegate" = "1" ]]
	        then 
	        uci set network.$Interfacename.delegate='1'
	        fi
	        
	        if [[ "$force_link" = "1" ]]
	        then 
	        uci set network.$Interfacename.force_link='1'
	        fi
    
        fi    
       
	          
     NoOfSectionCount=$((NoOfSectionCount + 1))
      
     uci commit network
     uci commit dhcp
     uci commit firewall
     uci commit mwan3config
     uci commit mwan3
     
}      	   

#DeleteinterenetOverInterface
 
rm -rf /etc/waninterface.txt
rm -rf /etc/laninterface.txt
rm -rf /etc/internetoverlan.txt 
    
ReadNetworkinterfaceConfigFile     
#interenetOverInterface    
/root/InterfaceManager/script/update_firewall.sh
/etc/init.d/firewall restart
exit 0    	
	
	
