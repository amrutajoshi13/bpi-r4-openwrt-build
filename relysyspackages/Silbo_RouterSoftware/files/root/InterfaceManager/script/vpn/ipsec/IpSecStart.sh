#!/bin/sh

. /lib/functions.sh

rm /bin/updatevpnconfigoutput.txt
touch /bin/updatevpnconfigoutput.txt
chmod 0777 /bin/updatevpnconfigoutput.txt
ipsecstop="/etc/init.d/ipsec stop"
Updatedipsecstatus="/bin/ipsecstatus.sh"

ReadIpsecConfigFile()
{
    vpnread="$1"
    
    config_get IpsecType "$vpnread" ipsectype
    config_get IpsecRole "$vpnread" ipsecrole
    config_get ConnectionEnable "$vpnread" connectionenable
    config_get ConnectionType "$vpnread" connectiontype
    config_get ConnectionMode "$vpnread" connectionmode
    config_get RemoteServerIP "$vpnread" remoteserverIP
    config_get RemoteIP "$vpnread" remoteIP
    config_get LocalId "$vpnread" localid
    #  config_get LocalSubnet "$vpnread" localsubnet
    config_get RemoteId "$vpnread" remoteid
    #  config_get RemoteSubnet "$vpnread" remotesubnet
    config_get KeyexChange "$vpnread" keyexchange
    config_get DpdDetectionEnable "$vpnread" dpddetectionenable
    config_get TimeInterval "$vpnread" timeinterval
    config_get TimeOut "$vpnread" timeout
    config_get Action "$vpnread" action
    config_get AuthenticationMethod "$vpnread" authenticationmethod
    config_get PskValue "$vpnread" pskvalue
    config_get P1Encrypalgorithm "$vpnread" p1encrypalgorithm
    config_get P1Authentication "$vpnread" p1authentication
    config_get P1DhGroup "$vpnread" p1dhgroup
    config_get P2Encrypalgorithm "$vpnread" p2encrypalgorithm
    config_get P2Authentication "$vpnread" p2authentication
    config_get P2Pfs "$vpnread" p2pfs
    config_get NoOfLocalSubnetToBypass "$vpnread" nooflocalsubnettobypass
    config_get LocalSubnetIp1 "$vpnread" localsubnetip1
    config_get LocalSubnetIp2 "$vpnread" localsubnetip2
    config_get LocalSubnetIp3 "$vpnread" localsubnetip3
    config_get LocalSubnetIp4 "$vpnread" localsubnetip4
    config_get LocalSubnetIp5 "$vpnread" localsubnetip5
    config_get NoOfLocalSubnets "$vpnread" nooflocalsubnets
    config_get LocalSubnet1 "$vpnread" localsubnet1
    config_get LocalSubnet2 "$vpnread" localsubnet2
    config_get NoOfRemoteSubnets "$vpnread" noofremotesubnets
    config_get RemoteSubnet1 "$vpnread" remotesubnet1
    config_get RemoteSubnet2 "$vpnread" remotesubnet2
    config_get RemoteSubnet3 "$vpnread" remotesubnet3
    config_get RemoteSubnet4 "$vpnread" remotesubnet4
    config_get RemoteSubnet5 "$vpnread" remotesubnet5
    config_get RemoteSubnet6 "$vpnread" remotesubnet6
    config_get RemoteSubnet7 "$vpnread" remotesubnet7
    config_get RemoteSubnet8 "$vpnread" remotesubnet8
    config_get aggressive    "$vpnread" aggressive
    config_get ikelifetime   "$vpnread" ikelifetime
    config_get lifetime      "$vpnread" lifetime
    config_get lanWifiConnectivity "$vpnread" lanWifiConnectivity
    config_get splitTunnel   "$vpnread" splitTunnel
    config_get connectionprotocol "$vpnread" connectionprotocol
    config_get INTERFACE_LIST "$vpnread" interface_list
    config_get name "$vpnread" name
}

UpdateIpsecConfig()
{
    vpn="$1"
    echo "vpn is $vpn"
    ReadIpsecConfigFile "$vpn"
    
    if [ "$EnableIpsec" = "1" ]
    then
        if [ "$ConnectionEnable" = "1" ]
        then
            
            if [ "$ConnectionType" = 'transport' ]; then
                uci set ipsec.transport=ipsec
                uci set ipsec.transport.rtinstall_enabled="1"
            else
                uci set ipsec.general=ipsec
                uci set ipsec.general.uniqueids="on"
            fi


             #uci get from mwan3config file  
	        mode=$(uci get mwan3config.general.select)
            # If the mode is balanced → interface set
	        if [ "$mode" = "balanced" ]; then
                #Routing_NetworkHandling
                uci set network.$name="route" 
                uci set network.$name.interface="$INTERFACE_LIST"
                uci set network.$name.target="$RemoteServerIP" 
                gateway_ip=$(ifstatus $INTERFACE_LIST | grep '"nexthop":' | head -n1 | awk -F'"' '{print $4}') 
                uci set network.$name.gateway="$gateway_ip" 
                Ip_Address=$(ifstatus $INTERFACE_LIST | grep '"address":' | awk -F'"' '{print $4}') 
                uci set network.$name.source="$Ip_Address"  
                uci set network.$name.metric="1"
                
                uci commit network
            else
                uci delete network."${vpn}"
                uci commit network
            fi
            
            #STA
            if [ "$interface_list" = "apcli0" ]
            then
                uci set ipsec.general.interface="WIFI_WAN"
                uci set firewall.ipsec_rule1.src="WIFI_WAN"
                uci set firewall.ipsec_rule2.src="WIFI_WAN"
                uci set firewall.ipsec_rule3.src="WIFI_WAN"
            fi
            
            #Cellular
            #DualCellularSinglesim

            #####################################################
            
            uci set ipsec."${vpn}"=remote
            uci set ipsec."${vpn}".enabled="$ConnectionEnable"

            if [ $IpsecRole == "server" ]; then
                uci set ipsec."${vpn}".gateway="$RemoteIP"
            else
                uci set ipsec."${vpn}".gateway="$RemoteServerIP"
            fi
            #uci set ipsec."${vpn}".gateway="$RemoteServerIP"
            #uci set ipsec."${vpn}".gateway="$RemoteIP"
            uci set ipsec."${vpn}".authentication_method="$AuthenticationMethod"
            uci set ipsec."${vpn}".pre_shared_key="$PskValue"
            uci set ipsec."${vpn}".exchange_mode="default"
            uci set ipsec."${vpn}".local_identifier="$LocalId"
            uci set ipsec."${vpn}".remote_identifier="$RemoteId"
            uci set ipsec."${vpn}".name="${vpn}"
            if [ $KeyexChange == "ikev1" ]; then
                uci set ipsec."${vpn}".aggressive="$aggressive"
            else
                uci delete ipsec."${vpn}".aggressive="$aggressive"
            fi  
            uci set ipsec."${vpn}".ikelifetime="$ikelifetime"
            uci set ipsec."${vpn}".lifetime="$lifetime"

            #uci get from mwan3config file  
	        mode=$(uci get mwan3config.general.select)
            # If the mode is balanced → interface set
	        if [ "$mode" = "balanced" ]; then
                Ip_Address=$(ifstatus $INTERFACE_LIST | grep '"address":' | awk -F'"' '{print $4}')
		        uci set ipsec."${vpn}".interface_ip="$Ip_Address"
                uci set ipsec."${vpn}".interfacelist="$INTERFACE_LIST"
	        # If the mode is failover → %any is set 
	        else 
                uci set ipsec."${vpn}".interface_ip="%any"
	        fi

            uci set ipsec."${vpn}_proposel_one"=p1_proposal
            uci set ipsec."${vpn}_proposel_one".encryption_algorithm_p1="$P1Encrypalgorithm"
            uci set ipsec."${vpn}_proposel_one".hash_algorithm="$P1Authentication"
            uci set ipsec."${vpn}_proposel_one".dh_group="$P1DhGroup"
            
            uci set ipsec."${vpn}_proposel_two"=p2_proposal
            uci set ipsec."${vpn}_proposel_two".encryption_algorithm_p2="$P2Encrypalgorithm"
            uci set ipsec."${vpn}_proposel_two".authentication_algorithm="$P2Authentication"
            uci set ipsec."${vpn}_proposel_two".pfs_group="$P2Pfs"
            
            #lanip=$(uci get network.SW_LAN.ipaddr | cut -d "." -f 1,2,3)
            #wifiip=$(uci get network.ra0.ipaddr | cut -d "." -f 1,2,3)
            #ip rule del to $lanip.0/24 lookup main priority 100
            #ip rule del to $wifiip.0/24 lookup main priority 101
            
            if [ "$ConnectionType" = 'transport' ]
            then
                uci set ipsec."${vpn}_transport"=transport
                uci set ipsec."${vpn}_transport".p2_proposal="${vpn}_proposel_two"
                uci set ipsec."${vpn}_transport".keyexchange="$KeyexChange"
                uci set ipsec."${vpn}_transport".mode="$ConnectionMode"
                uci set ipsec."${vpn}_transport".connectionprotocol="$connectionprotocol"
                
                if [ "$DpdDetectionEnable" = "1" ]
                then
                    uci set ipsec."${vpn}_transport".dpdaction="$Action"
                    uci set ipsec."${vpn}_transport".dpddelay="${TimeInterval}s"
                fi
                uci add_list ipsec."${vpn}".transport="${vpn}_transport"
                
            elif [ "$splitTunnel" = "0" ] && [ "$ConnectionType" = 'tunnel' ]
            then
                uci set ipsec."${vpn}".lanWifiConnectivity="$lanWifiConnectivity"
                uci set ipsec."${vpn}".NoOfLocalSubnetToBypass="$NoOfLocalSubnetToBypass"
                if [ "$lanWifiConnectivity" = "1" ]
                then
                    if [ "$NoOfLocalSubnetToBypass" = "1" ]
                    then
                        uci set ipsec."${vpn}".passthrough_ip1="$LocalSubnetIp1"
                    elif  [ "$NoOfLocalSubnetToBypass" = "2" ]
                    then
                        uci set ipsec."${vpn}".passthrough_ip1="$LocalSubnetIp1"
                        uci set ipsec."${vpn}".passthrough_ip2="$LocalSubnetIp2"
                    elif  [ "$NoOfLocalSubnetToBypass" = "3" ]
                    then
                        uci set ipsec."${vpn}".passthrough_ip1="$LocalSubnetIp1"
                        uci set ipsec."${vpn}".passthrough_ip2="$LocalSubnetIp2"
                        uci set ipsec."${vpn}".passthrough_ip3="$LocalSubnetIp3"
                    elif  [ "$NoOfLocalSubnetToBypass" = "4" ]
                    then
                        uci set ipsec."${vpn}".passthrough_ip1="$LocalSubnetIp1"
                        uci set ipsec."${vpn}".passthrough_ip2="$LocalSubnetIp2"
                        uci set ipsec."${vpn}".passthrough_ip3="$LocalSubnetIp3"
                        uci set ipsec."${vpn}".passthrough_ip4="$LocalSubnetIp4"
                    elif  [ "$NoOfLocalSubnetToBypass" = "5" ]
                    then
                        uci set ipsec."${vpn}".passthrough_ip1="$LocalSubnetIp1"
                        uci set ipsec."${vpn}".passthrough_ip2="$LocalSubnetIp2"
                        uci set ipsec."${vpn}".passthrough_ip3="$LocalSubnetIp3"
                        uci set ipsec."${vpn}".passthrough_ip4="$LocalSubnetIp4"
                        uci set ipsec."${vpn}".passthrough_ip5="$LocalSubnetIp5"
                    fi
                fi
                
                uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel"=tunnel
                uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel".local_subnet="${LocalSubnet1}"
                uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel".remote_subnet="0.0.0.0/0"
                uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel".p2_proposal="${vpn}_proposel_two"
                uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel".keyexchange="$KeyexChange"
                uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel".mode="$ConnectionMode"
                uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel".connectionprotocol="$connectionprotocol"
                
                
                if [ "$DpdDetectionEnable" = "1" ]
                then
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel".dpdaction="$Action"
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel".dpddelay="${TimeInterval}s"
                fi
                uci add_list ipsec."${vpn}".tunnel="${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel"
                
                if [ "$NoOfLocalSubnets" = "2" ]
                then
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1"=tunnel
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1".local_subnet="${LocalSubnet1}"
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1".remote_subnet="0.0.0.0/0"
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1".p2_proposal="${vpn}_proposel_two"
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1".keyexchange="$KeyexChange"
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1".mode="$ConnectionMode"
                    uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1".connectionprotocol="$connectionprotocol"
                    
                    if [ "$DpdDetectionEnable" = "1" ]
                    then
                        uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1".dpdaction="$Action"
                        uci set ipsec."${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1".dpddelay="${TimeInterval}s"
                    fi
                    uci add_list ipsec."${vpn}".tunnel="${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel1"
                fi
                
            else
                tunnel_index=1
                for l in $(seq 1 "$NoOfLocalSubnets"); do
                    for r in $(seq 1 "$NoOfRemoteSubnets"); do
                        tunnel="${vpn}_${NoOfLocalSubnets}_${NoOfRemoteSubnets}_tunnel$tunnel_index"
                        
                        echo The tunnel index is : $tunnel
                        
                        eval local_subnet=\$LocalSubnet$l
                        eval remote_subnet=\$RemoteSubnet$r
                        
						echo The localsubnet is : $local_subnet
                        echo The remote subnet is : $remote_subnet


                        
                        uci set ipsec."$tunnel"=tunnel
                        uci set ipsec."$tunnel".local_subnet="$local_subnet"
                        uci set ipsec."$tunnel".remote_subnet="$remote_subnet"
                        uci set ipsec."$tunnel".p2_proposal="${vpn}_proposel_two"
                        uci set ipsec."$tunnel".keyexchange="$KeyexChange"
                        uci set ipsec."$tunnel".mode="$ConnectionMode"
                        uci set ipsec."$tunnel".connectionprotocol="$connectionprotocol"
                        
                        if [ "$DpdDetectionEnable" = "1" ]; then
                            uci set ipsec."$tunnel".dpdaction="$Action"
                            uci set ipsec."$tunnel".dpddelay="${TimeInterval}s"
                        fi
                        
                        uci add_list ipsec."$vpn".tunnel="$tunnel"
                        tunnel_index=$((tunnel_index + 1))
                    done
                done
                
            fi
        else    
            uci delete network."${vpn}"
            uci commit network

            uci delete ipsec."${vpn}"
            uci delete ipsec.general.interface
            uci delete firewall.ipsec_rule1.src
            uci delete firewall.ipsec_rule2.src
            uci delete firewall.ipsec_rule3.src
        fi
    else
        uci delete network."${vpn}"
        uci commit network
        
        uci delete ipsec."${vpn}"
        uci delete ipsec.general.interface
        uci delete firewall.ipsec_rule1.src
        uci delete firewall.ipsec_rule2.src
        uci delete firewall.ipsec_rule3.src

        response=$($ipsecstop)
        response=$($Updatedipsecstatus)
    fi
    
    uci commit ipsec
    uci commit network
}

ipsec_handle_policy() {

	IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)	
	enablecellular=$(uci get sysconfig.sysconfig.enablecellular)
	CellularOperationModelocal=$(uci get sysconfig.sysconfig.CellularOperationMode)

	if [ "$enablecellular" = "1" ]
	then
		#singlecellulardualsim
		if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
			CWAN1_0_get_pdp=$(uci get modem.CWAN1_0.pdp)
			CWAN1_1_get_pdp=$(uci get modem.CWAN1_1.pdp)
			CWAN1_0ifname=$(uci get modem.CWAN1_0.interfacename)
			CWAN1_1ifname=$(uci get modem.CWAN1_1.interfacename)

			if [ "$CWAN1_0_get_pdp" = "IPV4" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.cwan1_0.extra_src="-i ${CWAN1_0ifname} -m policy --dir in --pol none"
					uci set firewall.cwan1_0.extra_dest="-o ${CWAN1_0ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.cwan1_0.extra_src >/dev/null 2>&1
					uci delete firewall.cwan1_0.extra_dest >/dev/null 2>&1
				fi
			fi

			if [ "$CWAN1_0_get_pdp" = "IPV6" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.wan6c1.extra_src="-i ${CWAN1_0ifname} -m policy --dir in --pol none"
					uci set firewall.wan6c1.extra_dest="-o ${CWAN1_0ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.wan6c1.extra_src >/dev/null 2>&1
					uci delete firewall.wan6c1.extra_dest >/dev/null 2>&1
				fi
			fi

			if [ "$CWAN1_1_get_pdp" = "IPV4" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.cwan1_1.extra_src="-i ${CWAN1_1ifname} -m policy --dir in --pol none"
					uci set firewall.cwan1_1.extra_dest="-o ${CWAN1_1ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.cwan1_1.extra_src >/dev/null 2>&1
					uci delete firewall.cwan1_1.extra_dest >/dev/null 2>&1
				fi
			fi

			if [ "$CWAN1_1_get_pdp" = "IPV6" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.wan6c2.extra_src="-i ${CWAN1_1ifname} -m policy --dir in --pol none"
					uci set firewall.wan6c2.extra_dest="-o ${CWAN1_1ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.wan6c2.extra_src >/dev/null 2>&1
					uci delete firewall.wan6c2.extra_dest >/dev/null 2>&1
				fi
			fi

		#singlecellularsinglesim
		else
			CWAN1_get_pdp=$(uci get modem.CWAN1.pdp)
			CWAN1ifname=$(uci get modem.CWAN1.interfacename)

			if [ "$CWAN1_get_pdp" = "IPV4" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.cwan1.extra_src="-i ${CWAN1ifname} -m policy --dir in --pol none"
					uci set firewall.cwan1.extra_dest="-o ${CWAN1ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.cwan1.extra_src >/dev/null 2>&1
					uci delete firewall.cwan1.extra_dest >/dev/null 2>&1
				fi
			fi

			if [ "$CWAN1_get_pdp" = "IPV6" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.wan6c1.extra_src="-i ${CWAN1ifname} -m policy --dir in --pol none"
					uci set firewall.wan6c1.extra_dest="-o ${CWAN1ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.wan6c1.extra_src >/dev/null 2>&1
					uci delete firewall.wan6c1.extra_dest >/dev/null 2>&1
				fi
			fi
		fi
		uci commit firewall
	fi
}

vpnconfigfile="/etc/config/vpnconfig1"
ipsecconfigfile="/etc/config/ipsec"

rm -rf "$ipsecconfigfile"
touch "$ipsecconfigfile"

EnableIpsec=$(uci get vpnconfig1.general.enableipsecgeneral)

ipsec_handle_policy

config_load "$vpnconfigfile"
config_foreach UpdateIpsecConfig vpnconfig1


/etc/init.d/firewall reload
sleep 1
/etc/init.d/ipsec stop
sleep 1
/etc/init.d/ipsec start

sleep 1

if [ "$EnableIpsec" = "1" ]
then
    sed -i '/ipsecstatus.sh/d' /etc/crontabs/root
    echo "*/1 * * * * /bin/ipsecstatus.sh" >> /etc/crontabs/root
    
    sed -i '/IpsecRestart.sh/d' /etc/crontabs/root
    echo "*/15 * * * * /root/InterfaceManager/script/vpn/ipsec/IpsecRestart.sh" >> /etc/crontabs/root

      ################### Firewall #######################
			#Firewall rules creation & deletion in case of Failover & Load Balancing 
			/root/InterfaceManager/script/common_scripts/Ipsec_firewall.sh >/dev/null 2>&1
          
    #####################   End  ########################
    
    ubus call network reload
    /etc/init.d/cron restart
     /etc/init.d/ipsec start
    /usr/sbin/ipsec restart
   
    
else
    
    sed -i '/ipsecstatus.sh/d' /etc/crontabs/root
    
    sed -i '/IpsecRestart.sh/d' /etc/crontabs/root
    
   
    #Firewall rules creation & deletion in case of Failover & Load Balancing 
    /root/InterfaceManager/script/common_scripts/Ipsec_firewall.sh >/dev/null 2>&1

    ubus call network reload

    /etc/init.d/ipsec stop

    /usr/sbin/ipsec stop
    
fi
