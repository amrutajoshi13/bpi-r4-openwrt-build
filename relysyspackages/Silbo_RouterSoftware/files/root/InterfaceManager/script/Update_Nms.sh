#!/bin/sh

. /lib/functions.sh


NMS_Enable=$(uci get remoteconfig.nms.nmsenable)
NMS_URL=$(uci get remoteconfig.nms.httpurl)
OpenvpnEnable=$(uci get vpnconfig1.general.enableopenvpngeneral)
FileName=$(uci get openvpn.custom_config.config)
RebootBoard="/root/usrRPC/script/Board_Recycle_12V_Script.sh"
RMS=$(uci get remoteconfig.general.rmsoption)
RebootLogfile="/root/ConfigFiles/RebootLog/RebootLog.txt"
RebootreasonLogfile="/root/ConfigFiles/RebootLog/Rebootreason.txt"
nmstunneltype=$(uci get remoteconfig.nms.nmstunneltype)

echo "$RMS"

if [ "$RMS" = "nms" ]
then
     if [ "$OpenvpnEnable" = "1" ]
     then
         if [ ! -f "$FileName" ]
         then
			 uci set openvpn.custom_config.enabled=0
		 else 
			 uci set openvpn.custom_config.enabled=1
		 fi
	else
		uci set openvpn.custom_config.enabled=0
	fi

	uci commit openvpn

	TmpSecretKeyFile="/tmp/nmssecuritykey"

		if [ "${NMS_Enable}" = "1" ]
		then
			uci set openwisp.http.url="${NMS_URL}"
			SecurityKey=$(cat "$TmpSecretKeyFile")
			uci set openwisp.http.shared_secret="$SecurityKey"
			if [ "$nmstunneltype" = "openvpn" ]
			then
			uci set openwisp.http.management_interface="tun0"
			else
			uci set openwisp.http.management_interface="wg0"
			fi
			uci commit openwisp
			sleep 5
			/etc/init.d/openwisp-config restart
			sleep 10
	        #wireguard related 
	        if [ "$nmstunneltype" = "openvpn" ]
	        then
				uci delete network.wg0
				uci delete network.wgpeer_wg0
				uci commit network
	        
				/etc/init.d/openvpn restart
				sleep 10
			else     	
					 uci delete openvpn.$VPN_NAME
					 uci commit openvpn	
				#creating zone  
				uci set firewall.wg0=zone
				uci set firewall.wg0.name="wg0"
				uci set firewall.wg0.input="ACCEPT"
				uci set firewall.wg0.output="ACCEPT"
				uci set firewall.wg0.forward="REJECT"
				uci set firewall.wg0.masq="1"
				uci set firewall.wg0.mtu_fix="1"
				uci set firewall.wg0.network="wg0"
				uci set firewall.wg0.extra_src="-m policy --dir in --pol none"
				uci set firewall.wg0.extra_dest="-m policy --dir out --pol none"
				uci commit firewall	 				 
			fi
			/etc/init.d/openwisp-monitoring restart
         
			#creating zone  
			uci set firewall.VPN=zone
			uci set firewall.VPN.name="VPN"
			uci set firewall.VPN.input="ACCEPT"
			uci set firewall.VPN.output="ACCEPT"
			uci set firewall.VPN.forward="REJECT"
			uci set firewall.VPN.masq="1"
			uci set firewall.VPN.mtu_fix="1"
			uci set firewall.VPN.network="VPN"
			uci set firewall.VPN.extra_src="-m policy --dir in --pol none"
			uci set firewall.VPN.extra_dest="-m policy --dir out --pol none"
			uci commit firewall
		else
			#deleting zone
			uci delete firewall.VPN
			uci delete firewall.wg0
			uci commit firewall
			
			uci set openwisp.http.uuid=''
			uci set openwisp.http.key=''
			uci commit openwisp
			logger -t config -p customs.info "openwisp configuration changed"
			/etc/init.d/openwisp-config stop
			sleep 2
			/etc/init.d/openwisp-monitoring stop
         
	        if [ "$nmstunneltype" = "openvpn" ]
			then
				 VPN_NAME=$(cat /etc/openwisp/remote/etc/config/openvpn | awk NR==1 | cut -d " " -f 3 | tr -d "'")
				 uci delete openvpn.$VPN_NAME
				 uci commit openvpn
				 logger -t config -p customs.info "openvpn configuration changed"
				 sleep 2
				 /etc/init.d/openvpn restart
	        else
				 uci delete network.wg0
				 uci delete network.wgpeer_wg0
				 uci commit network
				 logger -t config -p customs.info "network configuration changed"
				 sleep 2
				 /etc/init.d/network restart
			fi	 
		fi


	while true                             
	do                                                                                                
		sleep 20                   
		UUID=$(uci get openwisp.http.uuid)    
		KEY=$(uci get openwisp.http.key)     
		if [ ! -z "$UUID" ] && [ ! -z "$KEY" ]           
		then                                                                                            
			echo "Device registered"  
			/root/InterfaceManager/script/Post_Reload_Script.sh 
			date=$(date)
			echo "$date:[NMS Registration]:4" >> "$RebootLogfile"                                                                  
			echo "$date:[NMS Registration]:4" > "$RebootreasonLogfile" 
			cp /etc/config/openwisp /root/InterfaceManager/config                                                                 
			cp /etc/config/remoteconfig /root/InterfaceManager/config  
			cp /etc/config/openvpn     /root/InterfaceManager/config 
			#wirgeguard related
			cp /etc/config/network    /root/InterfaceManager/config
			
			$RebootBoard                       
			break         
		fi                                 
	done
fi
exit 0 
