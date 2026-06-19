#!/bin/sh

. /lib/functions.sh

ipipconfigfile="/etc/config/ipipconfig"
enableipip=$(uci get vpnconfig1.general.enableipip)

UpdateIPIPConfig()
{
	ipipread="$1"
	echo "ipipread value is $ipipread" 

	config_get tunnelname "$ipipread" tunnelname
	config_get localexternalIP "$ipipread" localexternalIP
	config_get remoteexternalIP "$ipipread" remoteexternalIP
	config_get peertunnelIP "$ipipread" peertunnelIP
	config_get localtunnelIP "$ipipread" localtunnelIP
	config_get enabletunlink "$ipipread" enabletun
	config_get interfacetype "$ipipread" interfacetype
	config_get mtu "$ipipread" mtu
	config_get ttl "$ipipread" ttl

	config_get tunnelkey "$ipipread" tunnelkey
	config_get enablekeepalive "$ipipread" enablekeepalive
	config_get aliveinterval "$ipipread" aliveinterval
	config_get remotenetmask "$ipipread" remotenetmask
	config_get localnetmask "$ipipread" localnetmask
	config_get remoteip "$ipipread" remoteip

	myipipstatic="$tunnelname"_static
	tunnel_ipip="tunnel_$tunnelname"

	if [ "$enableipip" = "1" ]
	then   
		uci set network.$tunnelname=interface
		uci set network.$tunnelname.ipaddr="$localexternalIP"
		uci set network.$tunnelname.peeraddr="$remoteexternalIP"
		uci set network.$tunnelname.proto=ipip 
		uci set network.$tunnelname.mtu="$mtu"
		uci set network.$tunnelname.ttl="$ttl" 
		
		if [ "$enablekeepalive" = '1' ]
		then
			uci set network.$tunnelname.keep_alive_interval="$aliveinterval"
		else
			uci delete network.$tunnelname.keep_alive_interval
		fi 
		
		if [ "$enabletunlink" = '1' ]
		then
			uci set network.$tunnelname.tunlink="$interfacetype"
		else
			uci delete network.$tunnelname.tunlink
		fi 

		uci set network.$myipipstatic=interface
		uci set network.$myipipstatic.proto=static
		uci set network.$myipipstatic.ifname="@$tunnelname"
		uci set network.$myipipstatic.ipaddr="$localtunnelIP"
		uci set network.$myipipstatic.netmask="$localnetmask"

		remote_netmask=$(ipcalc.sh $remoteip | grep -i "NETMASK" | cut -d'=' -f2)
		uci set network.$tunnel_ipip=route
		uci set network.$tunnel_ipip.interface="$myipipstatic"
		uci set network.$tunnel_ipip.target="$remoteip"
		uci set network.$tunnel_ipip.netmask="$remote_netmask"
		uci set network.$tunnel_ipip.gateway="$peertunnelIP"
		uci set network.$tunnelname.ikey="$tunnelkey" 
	    uci set network.$tunnelname.okey="$tunnelkey"
	else 
		uci delete network.$tunnelname
		uci delete network.$myipipstatic
		uci delete network.$tunnel_ipip
	fi                                                                           
	uci commit network  
	
}

config_load "$ipipconfigfile" 
config_foreach UpdateIPIPConfig ipipconfig

/etc/init.d/network restart



