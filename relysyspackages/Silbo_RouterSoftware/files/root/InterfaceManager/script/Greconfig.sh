#!/bin/sh

. /lib/functions.sh

greconfigfile="/etc/config/greconfig"
enablegre=$(uci get greconfig.general.enablegre)

UpdateGreConfig()
{
  greread="$1"
  echo "greread value is $greread" 
  config_get tunnelname "$greread" tunnelname
  config_get localexternalIP "$greread" localexternalIP
  config_get remoteexternalIP "$greread" remoteexternalIP
  config_get peertunnelIP "$greread" peertunnelIP
  config_get localtunnelIP "$greread" localtunnelIP
  config_get enabletunlink "$greread" enabletun
  config_get interfacetype "$greread" interfacetype
  config_get mtu "$greread" mtu
  config_get ttl "$greread" ttl

  config_get tunnelkey "$greread" tunnelkey
  config_get enablekeepalive "$greread" enablekeepalive
  config_get aliveinterval    "$greread" aliveinterval
  config_get remotenetmask   "$greread"  remotenetmask
  config_get localnetmask   "$greread"  localnetmask
  config_get remoteip   "$greread"   remoteip

  mygrestatic="$tunnelname"_static
  tunnel_gre="tunnel_$tunnelname"

       if [ "$enablegre" = "1" ]
       then     
            uci set network.$tunnelname=interface
		    uci set network.$tunnelname.ipaddr="$localexternalIP"
		    uci set network.$tunnelname.peeraddr="$remoteexternalIP"
		    uci set network.$tunnelname.proto=gre 
		    uci set network.$tunnelname.mtu="$mtu"
		    uci set network.$tunnelname.ttl="$ttl"
		    uci set network.$tunnelname.keep_alive="$enablekeepalive"
		    if [ "$enablekeepalive" = "1" ]
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
		        uci delete firewall.gretun
		   fi 
                uci set network.$mygrestatic=interface
                uci set network.$mygrestatic.proto=static
                uci set network.$mygrestatic.ifname="@$tunnelname"
                uci set network.$mygrestatic.ipaddr="$localtunnelIP"
                uci set network.$mygrestatic.netmask="$localnetmask"
      
	           remote_netmask=$(ipcalc.sh $remoteip | grep -i "NETMASK" | cut -d'=' -f2)
	           uci set network.$tunnel_gre=route
		       uci set network.$tunnel_gre.interface="$mygrestatic"
		       uci set network.$tunnel_gre.target="$remoteip"
		       uci set network.$tunnel_gre.netmask="$remote_netmask"
		       uci set network.$tunnel_gre.gateway="$peertunnelIP"
		       uci set network.$tunnelname.ikey="$tunnelkey" 
	           uci set network.$tunnelname.okey="$tunnelkey"	
	           
	     else 
	          uci delete network.$tunnelname 
	          uci delete network.$mygrestatic 
	          uci delete network.$tunnel_gre          
                  
       fi     
                                                                             
    uci commit network  
}

/etc/init.d/network restart

config_load "$greconfigfile" 
config_foreach UpdateGreConfig greconfig
logger -t config -p customs.info "network configuration changed"



