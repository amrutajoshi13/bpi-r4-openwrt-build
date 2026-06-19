#!/bin/sh

. /lib/functions.sh

wireguardUCIPath=/etc/config/wireguard


Networkrestart="ubus call network reload"

##Delete wireguard names for Client from the network file.###
delete_file="/root/InterfaceManager/script/vpn/wireguard/ucidelete2.sh"
chmod 700 /root/InterfaceManager/script/vpn/wireguard/ucidelete2.sh

#Run the "/root/InterfaceManager/script/vpn/wireguard/ucidelete2.sh" which deletes the names from the network file.
var=$($delete_file)

#Delete the ucidelete2.sh and then create a new one for every update button pressed.
rm /root/InterfaceManager/script/vpn/wireguard/ucidelete2.sh

#Wireguard SELECTION CHECK
#Run the script, only if Wireguard is enabled in general tab.
wireguard_status=$(uci get vpnconfig1.general.enablewireguardgeneral)

Network_Refresh(){
	for iface in $(ubus list network.interface.* | cut -d'.' -f3); do
		echo "Restarting interface: $iface"
		ubus call network.interface.$iface down
		ubus call network.interface.$iface up
	done
}

#If Wireguard isn't selected, then, exit the script.
if [ "$wireguard_status" = "0" ]; then

	#Reload the network only if the ucidelete file is there. When this file gets deleted, 
	#there's nothing related to wireguard in network config. Hence, no need to run it if the file isn't there. 
	if [ -f "$delete_file" ]; then
        uci commit network
        uci commit firewall

        #Restart firewall
        /sbin/fw3 reload >/dev/null 2>&1

        sleep 1

        response=$($Networkrestart)
		
		#Down & up the network interfaces to update the routing table, mostly wireguard server & clients.
		Network_Refresh
	fi
	
	exit 1
fi

ReadwireguardUCIConfig() {
        config_load "$wireguardUCIPath"
        config_foreach wireguardConfigParameters wireguard
}

wireguardConfigParameters() {

        local wireguardConfigSection="$1"
        config_get Name "$wireguardConfigSection" name

        config_get Disabled "$wireguardConfigSection" disabled
        config_get Role "$wireguardConfigSection" role
        config_get Proto "$wireguardConfigSection" proto
        config_get Listen_port "$wireguardConfigSection" listen_port
        config_get Endpoint_Port "$wireguardConfigSection" endpoint_hostport
        config_get Publickey "$wireguardConfigSection" public_key
        config_get Privatekey "$wireguardConfigSection" private_key
        config_get Public_peers "$wireguardConfigSection" public_peers
        config_get defaultroute "$wireguardConfigSection" defaultroute
        config_get Peers "$wireguardConfigSection" peers
        config_get Preshared_key "$wireguardConfigSection" preshared_key

        #IPV4 & IPV6
        config_get enable_ipv4 "$wireguardConfigSection" enable_ipv4
        config_get enable_ipv6 "$wireguardConfigSection" enable_ipv6
        config_get endpoint_hostipv4 "$wireguardConfigSection" endpoint_hostipv4
        config_get endpoint_hostipv6 "$wireguardConfigSection" endpoint_hostipv6
        config_get Allowedipv4 "$wireguardConfigSection" Allowedipv4
        config_get Allowedipv6 "$wireguardConfigSection" Allowedipv6
        config_get route_allowed_ips "$wireguardConfigSection" route_allowed_ips
        config_get enable_allowedipv6 "$wireguardConfigSection" enable_allowedipv6
        config_get addressesv4 "$wireguardConfigSection" addressesv4
        config_get addressesv6 "$wireguardConfigSection" addressesv6

        #Handler Wireguard
        config_get Master_endpoint "$wireguardConfigSection" master_endpoint
        #config_get Failover "$wireguardConfigSection" failover

        #Get Network Page
        echo uci delete network.wireguard_$Name
        echo uci delete network.$Name

        echo uci delete firewall.$Name

        echo uci delete network.def_$Name

        uci set network.$Name=interface
        uci set network.$Name.proto=$Proto

        if [ "$enable_ipv4" = "1" ] || [ "$enable_ipv6" = "1" ]; then
                if [ -n "$addressesv4" ]; then
                        uci add_list network.$Name.addresses=$addressesv4
                fi
                if [ -n "$addressesv6" ]; then
                        uci add_list network.$Name.addresses=$addressesv6
                fi

        elif [ "$enable_ipv4" = "0" ] && [ "$enable_ipv6" = "1" ]; then
                if [ -n "$addressesv6" ]; then
                        uci add_list network.$Name.addresses=$addressesv6
                fi

        elif [ "$enable_ipv4" = "1" ] && [ "$enable_ipv6" = "0" ]; then
                if [ -n "$addressesv4" ]; then
                        uci add_list network.$Name.addresses=$addressesv4
                fi
        fi

        uci set network.$Name.private_key=$Privatekey
        uci set network.$Name.public_key=$Publickey
        uci set network.$Name.disabled=$Disabled
        uci set network.$Name.listen_port=$Listen_port

        uci set network."wireguard_$Name"=wireguard_"$Name"

        if [ "$enable_ipv4" = "1" ] || [ "$enable_ipv6" = "1" ]; then
                if [ "$Master_endpoint" = "IPV4" ]; then
                        #echo "IPV4_MAsterEndpoint"
                        uci set network."wireguard_$Name".endpoint_host="$endpoint_hostipv4"
                fi
                if [ "$Master_endpoint" = "IPV6" ]; then
                        uci set network."wireguard_$Name".endpoint_host="$endpoint_hostipv6"
                fi

        elif [ "$enable_ipv4" = "0" ] && [ "$enable_ipv6" = "1" ]; then
                if [ "$Master_endpoint" = "IPV6" ]; then
                        uci set network."wireguard_$Name".endpoint_host="$endpoint_hostipv6"
                fi

        elif [ "$enable_ipv4" = "1" ] && [ "$enable_ipv6" = "0" ]; then
                if [ "$Master_endpoint" = "IPV4" ]; then
                        #echo "IPV4_Endpointhostipv4"
                        uci set network."wireguard_$Name".endpoint_host="$endpoint_hostipv4"
                fi
        fi

        # List_delete logic for allowed IPs
        if [[ "$route_allowed_ips" = "1" || "$enable_allowedipv6" = "1" ]]; then
                # Create a list for allowed IPs (separated by a newline or space)
                echo "$Allowedipv4" >/root/InterfaceManager/script/vpn/wireguard/allowed_ipv4_list
                echo "$Allowedipv6" >/root/InterfaceManager/script/vpn/wireguard/allowed_ipv6_list

                # Process IPv4 addresses
                count=1
                for ip in $(cat /root/InterfaceManager/script/vpn/wireguard/allowed_ipv4_list); do
                        eval ipv4_allowedips$count=$ip
                        eval uci add_list network."wireguard_$Name".allowed_ips=\"\$ipv4_allowedips$count\"
                        count=$((count + 1))
                done

                # Process IPv6 addresses
                count=1
                for ip in $(cat /root/InterfaceManager/script/vpn/wireguard/allowed_ipv6_list); do
                        eval ipv6_allowedips$count=$ip
                        eval uci add_list network."wireguard_$Name".allowed_ips=\"\$ipv6_allowedips$count\"
                        count=$((count + 1))
                done
        fi

        # Handle deletion of allowed IPs when DNS is disabled
        if [[ "$route_allowed_ips" != "1" || "$enable_allowedipv6" != "1" ]]; then
                # Remove IPv4 from allowed_ips
                if [ -n "$Allowedipv4" ]; then
                        uci del_list network."wireguard_$Name".allowed_ips
                fi

                # Remove IPv6 from allowed_ips
                if [ -n "$Allowedipv6" ]; then
                        uci del_list network."wireguard_$Name".allowed_ips
                fi
        fi

        if [ "$Role" = "CLIENT" ]; then                                                                    
                uci set network."wireguard_$Name".persistent_keepalive='25'                                
        fi 
        uci set network."wireguard_$Name".public_key="$Peers"
        uci set network."wireguard_$Name".endpoint_port="$Endpoint_Port"
        uci set network."wireguard_$Name".preshared_key="$Preshared_key"
        uci set network."wireguard_$Name".route_allowed_ips=$route_allowed_ips

        # Default route is set.
        if [ "$defaultroute" = "1" ] && [ "$Role" = "CLIENT" ]; then
                uci set network.def_$Name=route
                uci set network.def_$Name.interface=$Name
                uci set network.def_$Name.target='0.0.0.0'
                uci set network.def_$Name.netmask='0.0.0.0'
                uci set network.def_$Name.metric='0'

                sleep 1
                uci set network.rule_$Name=rule
                uci set network.rule_$Name.src='0.0.0.0/0'
                uci set network.rule_$Name.lookup='main'
                uci set network.rule_$Name.priority='1'

                # # Add rule, if it is set as default route.
                # ip rule add from all lookup main priority 1 >/dev/null 2>&1
        else
                uci delete network.def_$Name

                sleep 1

                uci delete network.rule_$Name

                # ip rule del from all lookup main priority 1 >/dev/null 2>&1
        fi
        
        ##NEW

        #Firewall
        #All the VPN features are working with single ZONE
        uci set firewall.$Name=zone
        uci set firewall.$Name.name="$Name"
        uci set firewall.$Name.input="ACCEPT"
        uci set firewall.$Name.output="ACCEPT"
        uci set firewall.$Name.forward="ACCEPT"
        uci set firewall.$Name.network="$Name"
        uci set firewall.$Name.masq="1"
        uci set firewall.$Name.mtu_fix="1"
        
#For ra0_Zone creation
        uci set firewall.src_ra0_$Name="forwarding"
        uci set firewall.src_ra0_$Name.src="$Name"
        uci set firewall.src_ra0_$Name.dest="ra0"
                
        uci set firewall.des_ra0_$Name="forwarding"
        uci set firewall.des_ra0_$Name.src="ra0"
        uci set firewall.des_ra0_$Name.dest="$Name"
        
        echo uci delete firewall.src_ra0_$Name
        echo uci delete firewall.des_ra0_$Name
        
#For ra1_Zone creation
guestwifi=$(uci get sysconfig.guestwifi.guestwifienable)
 if [ "$guestwifi" = "1" ];then
        uci set firewall.src_ra1_$Name="forwarding"
        uci set firewall.src_ra1_$Name.src="$Name"
        uci set firewall.src_ra1_$Name.dest="ra1"
                
        uci set firewall.des_ra1_$Name="forwarding"
        uci set firewall.des_ra1_$Name.src="ra1"
        uci set firewall.des_ra1_$Name.dest="$Name"
fi        
        echo uci delete firewall.src_ra1_$Name
        echo uci delete firewall.des_ra1_$Name

#For_WanInterfaces Zone creation
 
        wanCount=$(cat /etc/waninterface.txt | wc -l)
        for j in $(seq 1 ${wanCount}); do
 
                wan=$(cat /etc/waninterface.txt | head -${j} | tail -1)
 
                #Creating the firewall Forwarding ZONE
 
                uci set firewall.src${wan}_$Name="forwarding"
                uci set firewall.src${wan}_$Name.src="$Name"
                uci set firewall.src${wan}_$Name.dest=${wan}
 
                uci set firewall.des${wan}_$Name="forwarding"
                uci set firewall.des${wan}_$Name.src=${wan}
                uci set firewall.des${wan}_$Name.dest="$Name"
                
                echo uci delete firewall.src${wan}_$Name
                echo uci delete firewall.des${wan}_$Name
                
        done
        
#For Lan_InterfacesZone Creation
 
        lanCount=$(cat /etc/internetoverlan.txt | wc -l)
        for k in $(seq 1 ${lanCount}); do
                lan=$(cat /etc/internetoverlan.txt | head -${k} | tail -1)
 
                uci set firewall.src${lan}_$Name="forwarding"
                uci set firewall.src${lan}_$Name.src="$Name"
                uci set firewall.src${lan}_$Name.dest=${lan}
 
                uci set firewall.des${lan}_$Name="forwarding"
                uci set firewall.des${lan}_$Name.src=${lan}
                uci set firewall.des${lan}_$Name.dest="$Name"
 
                echo uci delete firewall.src${lan}_$Name
                echo uci delete firewall.des${lan}_$Name
 
        done
}

ReadwireguardUCIConfig >>/root/InterfaceManager/script/vpn/wireguard/ucidelete2.sh

uci commit network
uci commit firewall
logger -t config -p customs.info "network configuration changed"
logger -t config -p customs.info "firewall configuration changed"

#Restart firewall
/sbin/fw3 reload >/dev/null 2>&1

sleep 1
#Reload the network for wireguard to restart.
response=$($Networkrestart)

#Down & up the network interfaces to update the routing table, mostly wireguard server & clients.
Network_Refresh
