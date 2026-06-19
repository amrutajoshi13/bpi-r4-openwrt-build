#!/bin/sh

. /lib/functions.sh

failoverconfigfile="/etc/config/mwan3config"
Select=$(uci get mwan3config.general.select)

DeleteFailoverConfig()
{
   failover="$1"
   config_get name "$failover" name
     
			if [ "$Select" =  "failover" ]
			then
				if [ "$name" = "CWAN1_0" ] || [ "$name" = "CWAN1_1" ]  || [ "$name" = "CWAN1" ]
				then 
					echo
				else               
	               uci delete mwan3.$name          
	               delete_oldmember=$(uci get mwan3.failover.use_member)
		           uci del_list mwan3.failover.use_member="$delete_oldmember" 		      
		           uci delete mwan3.default_rule.use_policy		     
		           uci delete mwan3."$name"_failover		           
		           uci delete mwan3statusconfig.$name
		           uci delete loadbalancingconfig.$name	           
				fi  
			fi
          
   uci commit mwan3
   uci commit mwan3statusconfig
   uci commit loadbalancingconfig
}

config_load "$failoverconfigfile" 
config_foreach DeleteFailoverConfig mwan3config

exit 0;

