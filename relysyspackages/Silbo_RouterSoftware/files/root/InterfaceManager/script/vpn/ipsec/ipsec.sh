#!/bin/sh

. /lib/functions.sh

#Get it from mwan3.user
    interface="$1"
    action="$2"

#uci get from ipsec config file 
ipsec_config_UCIPath="/etc/config/ipsec"

Read_ipsec_config()                                       
{                                                                      
    config_load "$ipsec_config_UCIPath"
    #Remote section i am getting values                        
    config_foreach ipsec_Parameters  remote
}                                                                        
                                                                           
ipsec_Parameters()                                        
{                                                                           
    local ipsec_ParametersConfigSection="$1"                               
    config_get  interfacelist   "$ipsec_ParametersConfigSection"  interfacelist
    config_get interface_ip "$ipsec_ParametersConfigSection"  interface_ip 
    config_get tunnel "$ipsec_ParametersConfigSection"  tunnel
    config_get gateway "$ipsec_ParametersConfigSection" gateway
    config_get name "$ipsec_ParametersConfigSection" name
     
if [ "$interface" = "$interfacelist" ] 
then 


    if [ "$action" = "disconnected" ] || [ "$action" = "ifdown" ]
    then

	uci set firewall.$name=rule
    uci set firewall.$name.name=$name
	uci set firewall.$name.proto='all'
	uci set firewall.$name.family='any'
	uci set firewall.$name.dest_ip="$gateway"
	uci set firewall.$name.target='DROP'
       
    elif [ "$action" = "connected" ] || [ "$action" = "ifup" ]
    then
       uci delete firewall.$name
    fi
fi
}

Read_ipsec_config

#Comit & firewall reload 
uci commit firewall
/sbin/fw3 reload > /dev/null 2>&1

