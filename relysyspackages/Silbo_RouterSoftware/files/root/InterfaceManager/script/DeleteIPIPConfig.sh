#!/bin/sh

. /lib/functions.sh

ipipconfigfile="/etc/config/ipipconfig"
enableipip=$(uci get tunnelconfig.general.enableipip)

DeleteIPIPConfig()
{

	ipipread="$1"
	config_get tunnelname "$ipipread" tunnelname
    if [ "$enableipip" = "1" ]
	then   
      uci delete network.$tunnelname
      uci delete network."$tunnelname"_static
      uci delete network.tunnel_$tunnelname
      uci commit network
    fi  
}


config_load "$ipipconfigfile" 
config_foreach DeleteIPIPConfig ipipconfig

exit 0;
