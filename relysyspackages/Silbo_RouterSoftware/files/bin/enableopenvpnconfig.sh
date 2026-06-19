#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

config_load vpnconfig1
config_get enableopenvpngeneral 'general' enableopenvpngeneral

if [ "$enableopenvpngeneral" = "1" ]
then   
      uci set openvpn.custom_config.enabled=1
else
	  uci set openvpn.custom_config.enabled=0
fi
	uci commit openvpn	

exit 0
