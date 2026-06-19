#!/bin/sh

. /lib/functions.sh


if [ ! -f "/etc/x509" ]
then 
   mkdir -p "/etc/x509"
fi

cp /etc/openwisp/remote/etc/x509/* /etc/x509/

if [ ! -f "/etc/dropbear" ]
then 
   mkdir -p "/etc/dropbear"
fi

cp /etc/openwisp/remote/etc/dropbear/authorized_keys /etc/dropbear/


VPN_NAME=$(cat /etc/openwisp/remote/etc/config/openvpn | awk NR==1 | cut -d " " -f 3 | tr -d "'")

AUTH=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".auth)

CA=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".ca)

CERT=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".cert)

CIPER=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".cipher)

DEV=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".dev)

DEV_TYPE=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".dev_type)

ENABLED=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".enabled)

KEEPALIVE=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".keepalive)

KEY=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".key)

MODE_OPENVPN=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".mode)

MUTE=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".mute)

NOBIND=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".nobind)

PERSIST_KEY=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".persist_key)

PERSIST_TUN=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".persist_tun)

PROTO=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".proto)

PULL=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".pull)

REMOTE=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".remote | tr -d "'")

REMOTE_CERT_TLS=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".remote_cert_tls)

RENEG_SEC=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".reneg_sec)

RESOLVE_RETRY=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".resolv_retry)

SCRIPT_SECURITY=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".script_security)

TLS_CLIENT=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".tls_client)

TLS_CRYPT=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".tls_crypt)

Route_NoPull=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".route_nopull) 

TLS_TIMEOUT=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".tls_timeout)

VERB=$(uci get /etc/openwisp/remote/etc/config/openvpn."${VPN_NAME}".verb)

SW_PROTO=$(uci get /etc/openwisp/remote/etc/config/network.SW_LAN.protoswlan)

SWIPADDR=$(uci get /etc/openwisp/remote/etc/config/network.SW_LAN.ipaddr)

EWAN5_GATEWAY=$(uci get /etc/openwisp/remote/etc/config/network.EWAN5.ewan5_gateway)

EWAN5_PROTO=$(uci get /etc/openwisp/remote/etc/config/network.EWAN5.ewan5_proto)

EWAN5_IP=$(uci get /etc/openwisp/remote/etc/config/network.EWAN5.ewan5_ip)


APN=$(uci get /etc/openwisp/remote/etc/config/network.usb0.apn)

APN_SIM2=$(uci get /etc/openwisp/remote/etc/config/network.usb0.APN2)

MODE=$(uci get /etc/openwisp/remote/etc/config/network.usb0.CellularMode)

DUAL_SIM=$(uci get /etc/openwisp/remote/etc/config/network.usb0.Dual_SIM)

SINGLE_SIM=$(uci get /etc/openwisp/remote/etc/config/network.usb0.Single_SIM)

DESTINATION_IP1=$(uci get /etc/openwisp/remote/etc/config/network.rule1.dest)

DESTINATION_IP2=$(uci get /etc/openwisp/remote/etc/config/network.rule1.destination_Ip2)

DESTINATION_IP3=$(uci get /etc/openwisp/remote/etc/config/network.rule1.destination_Ip3)

DESTINATION_IP4=$(uci get /etc/openwisp/remote/etc/config/network.rule1.destination_Ip4)

DESTINATION_PORT1=$(uci get /etc/openwisp/remote/etc/config/network.rule1.destination_port)

DESTINATION_PORT2=$(uci get /etc/openwisp/remote/etc/config/network.rule1.destination_port2)

DESTINATION_PORT3=$(uci get /etc/openwisp/remote/etc/config/network.rule1.destination_port3)

DESTINATION_PORT4=$(uci get /etc/openwisp/remote/etc/config/network.rule1.destination_port4)

SOURCE_PORT1=$(uci get /etc/openwisp/remote/etc/config/network.rule1.source_dport)

SOURCE_PORT2=$(uci get /etc/openwisp/remote/etc/config/network.rule1.source_dport1)

SOURCE_PORT3=$(uci get /etc/openwisp/remote/etc/config/network.rule1.source_dport2)

SOURCE_PORT4=$(uci get /etc/openwisp/remote/etc/config/network.rule1.source_dport3)

ACCOUNT_ID=$(uci get /etc/openwisp/remote/etc/config/network.SIA.account_id)

SERVER_IP=$(uci get /etc/openwisp/remote/etc/config/network.SIA.server_ip)

IPSEC_REMOTE_IP=$(uci get /etc/openwisp/remote/etc/config/network.IPSEC.REMOTE_IP)

IPSEC_REMOTE_ID=$(uci get /etc/openwisp/remote/etc/config/network.IPSEC.REMOTE_ID)

IPSEC_REMOTE_SUBNET1=$(uci get /etc/openwisp/remote/etc/config/network.IPSEC.REMOTE_SUBNET1)

IPSEC_LOCAL_SUBNET1=$(uci get /etc/openwisp/remote/etc/config/network.IPSEC.LOCAL_SUBNET1)

IPSEC_ENABLE=$(uci get /etc/openwisp/remote/etc/config/network.IPSEC.ipsec_enable)

IPSEC_PSK=$(uci get /etc/openwisp/remote/etc/config/network.IPSEC.PSK)

#wireguard related
wg0_address=$(uci get /etc/openwisp/remote/etc/config/network.wg0.addresses)
wg0_listen_port=$(uci get /etc/openwisp/remote/etc/config/network.wg0.listen_port)
wg0_mtu=$(uci get /etc/openwisp/remote/etc/config/network.wg0.mtu)
wg0_nohostroute=$(uci get /etc/openwisp/remote/etc/config/network.wg0.nohostroute)
wg0_private_key=$(uci get /etc/openwisp/remote/etc/config/network.wg0.private_key)
wg0_public_key=$(uci get /etc/openwisp/remote/etc/config/network.wg0.public_key)
wg0_proto=$(uci get /etc/openwisp/remote/etc/config/network.wg0.proto)

wgpeer_allowed_ips=$(uci get /etc/openwisp/remote/etc/config/network.wgpeer_wg0.allowed_ips)
wgpeer_endpoint_host=$(uci get /etc/openwisp/remote/etc/config/network.wgpeer_wg0.endpoint_host)
wgpeer_endpoint_port=$(uci get /etc/openwisp/remote/etc/config/network.wgpeer_wg0.endpoint_port)
wgpeer_persistent_keepalive=$(uci get /etc/openwisp/remote/etc/config/network.wgpeer_wg0.persistent_keepalive)
wgpeer_public_key=$(uci get /etc/openwisp/remote/etc/config/network.wgpeer_wg0.public_key)
wgpeer_route_allowed_ips=$(uci get /etc/openwisp/remote/etc/config/network.wgpeer_wg0.route_allowed_ips)

source /root/Web_page/Board_info.txt
if [ "$board_name" = "Silbo_RF44" ]
then
    if [ $SWIPADDR != "x" ]; then
	uci set networkinterfaces.SW_LAN.staticIP="$SWIPADDR"
    fi
    if [ $SW_PROTO != "x" ]; then
	uci set networkinterfaces.SW_LAN.protocol="${SW_PROTO}"
	fi
else

	if [ $SWIPADDR != "x" ] && [ $SW_PROTO != "x" ]; then
			 #uci set sysconfig.sysconfig.EthernetServerDHCPIPswlan="$SWIPADDR"
	
			#uci set sysconfig.sysconfig.EthernetServerStaticIPswlan="$SWIPADDR"
	        uci set networkinterfaces.SW_LAN.staticIP="$SWIPADDR" 
	         
			uci set networkinterfaces.SW_LAN.protocol="${SW_PROTO}"
	fi
	if [ $EWAN5_GATEWAY != "x" ] && [ $EWAN5_PROTO != "x" ] && [ $EWAN5_IP != "x" ]; then
	
	    if [ "$EWAN5_PROTO" = "dhcp" ]
	    then
			uci set networkinterfaces.EWAN5.dhcpgateway="${EWAN5_GATEWAY}"
			uci set networkinterfaces.EWAN5.protocol="${EWAN5_PROTO}"
		else
			uci set networkinterfaces.EWAN5.protocol="${EWAN5_PROTO}"
			uci set networkinterfaces.EWAN5.staticgateway="${EWAN5_GATEWAY}"
			uci set networkinterfaces.EWAN5.staticIP="${EWAN5_IP}"
		fi
     fi
fi
if [ "${DUAL_SIM}" = "1" ]
then
    if [ $DUAL_SIM != "x" ];then
       uci set sysconfig.sysconfig.CellularOperationMode="singlecellulardualsim"
    fi
elif [ "${SINGLE_SIM}" = "1" ]
then
	if [ $SINGLE_SIM != "x" ];then
       uci set sysconfig.sysconfig.CellularOperationMode="singlecellularsinglesim"
    fi
elif [ "${SINGLE_SIM}" = "2" ]
then
	if [ $SINGLE_SIM != "x" ];then
       uci set sysconfig.sysconfig.CellularOperationMode="singlecellulardualsim"
    fi
fi

if [ $DESTINATION_IP1 != "x" ] && [ $DESTINATION_PORT1 != "x" ] && [ $SOURCE_PORT1 != "x" ]; then
	uci set firewall.redirect1=redirect
	
	uci set firewall.redirect1.dest='SW_LAN'
	
	uci set firewall.redirect1.dest_ip="${DESTINATION_IP1}"
	
	uci set firewall.redirect1.dest_port="${DESTINATION_PORT1}"
	
	uci set firewall.redirect1.name='Rule1'
	
	uci set firewall.redirect1.proto='tcp udp'
	
	uci set firewall.redirect1.src='VPN'
	
	uci set firewall.redirect1.src_dport="${SOURCE_PORT1}"
	
	uci set firewall.redirect1.target='DNAT'
fi
if [ $DESTINATION_IP2 != "x" ] && [ $DESTINATION_PORT2 != "x" ] && [ $SOURCE_PORT2 != "x" ]; then
	uci set firewall.redirect2=redirect                                                                                                            
	                                                                                            
	uci set firewall.redirect2.dest='SW_LAN'                                                                                                       
	                                                                                            
	uci set firewall.redirect2.dest_ip="${DESTINATION_IP2}"                                                                                             
	                                                                                                                                               
	uci set firewall.redirect2.dest_port="${DESTINATION_PORT2}"                               
	                                                                                            
	uci set firewall.redirect2.name='DVR'                                                                                                          
	                                                                                            
	uci set firewall.redirect2.proto='tcp udp'                                                                                                     
	                                                                                                                                               
	uci set firewall.redirect2.src='VPN'                                                                                                           
	                                                                                            
	uci set firewall.redirect2.src_dport="${SOURCE_PORT2}"                                                                                                    
	                                                                                            
	uci set firewall.redirect2.target='DNAT' 
fi
if [ $DESTINATION_IP3 != "x" ] && [ $DESTINATION_PORT3 != "x" ] && [ $SOURCE_PORT3 != "x" ]; then
	uci set firewall.redirect3=redirect                                                                                                            
	                                                                                            
	uci set firewall.redirect3.dest='SW_LAN'                                                                                                       
	                                                                                            
	uci set firewall.redirect3.dest_ip="${DESTINATION_IP3}"                                                                                             
	                                                                                            
	uci set firewall.redirect3.dest_port="${DESTINATION_PORT3}"                                                                                                    
	                                                                                            
	uci set firewall.redirect3.name='IP_CAM'                                                                                                        
	                                                                                            
	uci set firewall.redirect3.proto='tcp udp'                                                                                                     
	                                                                                            
	uci set firewall.redirect3.src='VPN'                                                                                                           
	                                                                                                                                               
	uci set firewall.redirect3.src_dport="${SOURCE_PORT3}"                                                
	                                                                                            
	uci set firewall.redirect3.target='DNAT'   
fi
if [ $DESTINATION_IP4 != "x" ] && [ $DESTINATION_PORT4 != "x" ] && [ $SOURCE_PORT4 != "x" ]; then

	uci set firewall.redirect4=redirect                                                         
	                                                                                                                                               
	uci set firewall.redirect4.dest='SW_LAN'                                                    
	                                                                                                                                               
	uci set firewall.redirect4.dest_ip="${DESTINATION_IP4}"                                     
	                                                                                                                                               
	uci set firewall.redirect4.dest_port="${DESTINATION_PORT4}"                                 
	                                                                                                                                               
	uci set firewall.redirect4.name='RULE4'                                                     
	                                                                                                                                               
	uci set firewall.redirect4.proto='tcp udp'                                                  
	                                                                                                                                               
	uci set firewall.redirect4.src='VPN'                                                                                                           
	                                                                                            
	uci set firewall.redirect4.src_dport="${SOURCE_PORT4}"                                                 
	                                                                                                                                               
	uci set firewall.redirect4.target='DNAT'    
fi
if [ $APN != "x" ]; then
uci set sysconfig.sysconfig.apn="$APN"
fi
if [ $APN_SIM2 != "x" ]; then
uci set sysconfig.sysconfig.sim2apn="${APN_SIM2}"
fi
CellularModem1=$(uci get sysconfig.sysconfig.cellularmodem1)

if [ "$CellularModem1" = "QuectelEC20" ] || [ "$CellularModem1" = "QuectelEC25E" ]
then
     if [ $MODE != "x" ]; then
	    uci set sysconfig.sysconfig.Protocol1EC20="$MODE"
	fi
else
    if [ $MODE != "x" ]; then
     uci set sysconfig.sysconfig.protocol1="$MODE"
     fi
fi

if [ $IPSEC_ENABLE != "x" ] && [ $IPSEC_REMOTE_IP != "x" ] && [ $IPSEC_LOCAL_SUBNET1 != "x" ] && [ $IPSEC_REMOTE_ID != "x" ]  && [ $IPSEC_REMOTE_SUBNET1 != "x" ] && [ $IPSEC_PSK != "x" ]; then

uci set vpnconfig1.general.enableipsecgeneral="${IPSEC_ENABLE}"

uci set vpnconfig1.testVPN1.remoteserverIP="${IPSEC_REMOTE_IP}"

uci set vpnconfig1.testVPN1.localsubnet1="${IPSEC_LOCAL_SUBNET1}"

uci set vpnconfig1.testVPN1.remoteid="${IPSEC_REMOTE_ID}"

uci set vpnconfig1.testVPN1.remotesubnet1="${IPSEC_REMOTE_SUBNET1}"

uci set vpnconfig1.testVPN1.pskvalue="${IPSEC_PSK}"
fi

nmstunneltype=$(uci get remoteconfig.nms.nmstunneltype)
echo "$nmstunneltype"

uci delete openvpn."${VPN_NAME}"
uci commit openvpn

uci delete network.wg0
uci delete network.wgpeer_wg0
uci commit network

if [ "$nmstunneltype" = "openvpn" ]
then

	uci set openvpn."${VPN_NAME}"=openvpn

	uci set openvpn."${VPN_NAME}".auth="${AUTH}"

	uci set openvpn."${VPN_NAME}".ca="${CA}" 

	uci set openvpn."${VPN_NAME}".cert="${CERT}"

	uci set openvpn."${VPN_NAME}".cipher="${CIPER}"

	uci set openvpn."${VPN_NAME}".dev="${DEV}"

	uci set openvpn."${VPN_NAME}".dev_type="${DEV_TYPE}"

	uci set openvpn."${VPN_NAME}".enabled="${ENABLED}"

	uci set openvpn."${VPN_NAME}".keepalive="${KEEPALIVE}"

	uci set openvpn."${VPN_NAME}".key="${KEY}"

	uci set openvpn."${VPN_NAME}".mode="${MODE_OPENVPN}"

	uci set openvpn."${VPN_NAME}".mute="${MUTE}"

	uci set openvpn."${VPN_NAME}".nobind="${NOBIND}"

	uci set openvpn."${VPN_NAME}".persist_key="${PERSIST_KEY}"

	uci set openvpn."${VPN_NAME}".persist_tun="${PERSIST_TUN}"

	uci set openvpn."${VPN_NAME}".proto="${PROTO}"

	uci set openvpn."${VPN_NAME}".pull="${PULL}"

	uci set openvpn."${VPN_NAME}".remote="${REMOTE}"

	uci set openvpn."${VPN_NAME}".remote_cert_tls="${REMOTE_CERT_TLS}" 

	uci set openvpn."${VPN_NAME}".reneg_sec="${RENEG_SEC}"

	uci set openvpn."${VPN_NAME}".resolv_retry="${RESOLVE_RETRY}"

	uci set openvpn."${VPN_NAME}".script_security="${SCRIPT_SECURITY}"

	uci set openvpn."${VPN_NAME}".tls_client="${TLS_CLIENT}"

	uci set openvpn."${VPN_NAME}".tls_crypt="${TLS_CRYPT}"

	uci set openvpn."${VPN_NAME}".tls_timeout="${TLS_TIMEOUT}"

	uci set openvpn."${VPN_NAME}".route_nopull="${Route_NoPull}"

	uci set openvpn."${VPN_NAME}".verb="${VERB}" 

	uci commit openvpn

else
    
	 #ifname_wireguard= "wg0"
	 #peer_name="wgpeer_wg0"
	 
	wg0_public_key=$(echo "$wg0_private_key" | wg pubkey)	
	echo "wg0_public_key"
	 
	 uci set network.wg0=interface
     uci set network.wg0.addresses="$wg0_address"
	 uci set network.wg0.listen_port="$wg0_listen_port"
	 uci set network.wg0.mtu="$wg0_mtu"
	 uci set network.wg0.nohostroute="$wg0_nohostroute"
	 uci set network.wg0.private_key="$wg0_private_key"
	 uci set network.wg0.public_key="$wg0_public_key"
	 uci set network.wg0.proto="$wg0_proto"
	
	 uci set network.wgpeer_wg0=wireguard_wg0
	 uci set network.wgpeer_wg0.allowed_ips="$wgpeer_allowed_ips"
	 uci set network.wgpeer_wg0.endpoint_host="$wgpeer_endpoint_host"
	 uci set network.wgpeer_wg0.endpoint_port="$wgpeer_endpoint_port"
	 uci set network.wgpeer_wg0.persistent_keepalive="$wgpeer_persistent_keepalive"
	 uci set network.wgpeer_wg0.public_key="$wgpeer_public_key"
	 uci set network.wgpeer_wg0.route_allowed_ips="$wgpeer_route_allowed_ips"	
	
	uci commit network
fi

uci commit vpnconfig1

uci commit siaserverconfig

uci commit firewall

uci commit sysconfig

uci commit networkinterfaces

/etc/init.d/firewall reload

/bin/UpdateWanConfig.sh

sleep 2

#/root/InterfaceManager/script/SystemStart.sh

#sleep 2

sleep 2

/root/InterfaceManager/script/IpSecStart.sh

sleep 6

/etc/init.d/openvpn restart

