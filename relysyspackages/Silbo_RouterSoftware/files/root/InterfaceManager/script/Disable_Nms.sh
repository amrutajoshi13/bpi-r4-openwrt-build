#!/bin/sh

. /lib/functions.sh


NMS_Enable=$(uci get remoteconfig.nms.nmsenable)
RMS=$(uci get remoteconfig.general.rmsoption)
nmstunneltype=$(uci get remoteconfig.nms.nmsenable)
#NMS_URL=$(uci get nmsconfig.nmsconfig.httpurl)
#OpenvpnEnable=$(uci get vpnconfig1.general.enableopenvpngeneral)
#FileName=$(uci get openvpn.custom_config.config)

#if [ "$OpenvpnEnable" = "1" ]
#then
   #if [ ! -f "$FileName" ]
   #then
      #uci set openvpn.custom_config.enabled=0
   #else 
      #uci set openvpn.custom_config.enabled=1
   #fi
#else
   #uci set openvpn.custom_config.enabled=0
#fi

#uci commit openvpn

#TmpSecretKeyFile="/tmp/nmssecuritykey"
 
if [ "$RMS" = "none" ] ||  [ "${NMS_Enable}" = "0" ] || [ "$RMS" = "tr069" ]
then
		  #deleting zone
          uci delete firewall.VPN
          uci commit firewall
          
          uci set openwisp.http.uuid=''
          uci set openwisp.http.key=''
          uci commit openwisp
          /etc/init.d/openwisp-config stop
          sleep 2
          /etc/init.d/openwisp-monitoring stop
          VPN_NAME=$(cat /etc/openwisp/remote/etc/config/openvpn | awk NR==1 | cut -d " " -f 3 | tr -d "'")
          uci delete openvpn.$VPN_NAME
          uci commit openvpn
          sleep 2
         /etc/init.d/openvpn restart
		 cp /etc/config/openwisp /root/InterfaceManager/config                                                                 
		 cp /etc/config/remoteconfig /root/InterfaceManager/config  
		 cp /etc/config/openvpn     /root/InterfaceManager/config
        
         if [ "$nmstunneltype" = "wireguard" ];then
	          uci delete network.wg0
			  uci delete network.wgpeer_wg0
			  uci commit network
			  sleep 2
	         /etc/init.d/network reload
         fi
fi
     
exit 0

