#!/bin/sh
. /lib/functions.sh


#DdosConfigFile="/etc/config/firewall"
#DdosConfigSection="firewall"

#ReadDdosConfigFile()
#{
        #config_load "$DdosConfigFile"
        #config_foreach UpdateDdosConfig rule
        #config_get Enabled rule enabled
#}


#UpdateDdosConfig()
#{
    #NoOfSectionCount=$((NoOfSectionCount + 1))
	
     #enabled=$(uci get firewall.@rule[$NoOfSectionCount].enabled)
	#if [ "$enabled" = "1" ]
	 #then           
	#uci set firewall.@rule[$NoOfSectionCount].limit
    #uci set firewall.@rule[$NoOfSectionCount].limit_burst
    #else
       #uci delete firewall.@rule[$NoOfSectionCount].enabled 
     	#uci delete firewall.@rule[$NoOfSectionCount].limit
    #uci delete firewall.@rule[$NoOfSectionCount].limit_burst    
     #fi
    #uci commit firewall
    
#}

RestartInitScript()
{
	/etc/init.d/firewall reload
	
	sleep 1
    
    echo > /proc/net/nf_conntrack 
}


#ReadDdosConfigFile
#UpdateDdosConfig

RestartInitScript
 
 
exit 0
