#!/bin/sh

. /lib/functions.sh

loadbalanceconfigfile="/etc/config/loadbalancingconfig"
Select=$(uci get mwan3config.general.select)

DeleteLoadBalancingConfig()
{
   loadbalance="$1"
   config_get name "$loadbalance" name
     
          if [ "$Select" =  "balanced" ]
          then
             if [ "$name" = "CWAN1_0" ] || [ "$name" = "CWAN1_1" ]  || [ "$name" = "CWAN1" ]
              then 
                echo
               else
          
               uci delete mwan3.$name
          
               delete_oldmember=$(uci get mwan3.balanced.use_member)
	           uci del_list mwan3.balanced.use_member="$delete_oldmember" 
	      
	           uci delete mwan3.default_rule.use_policy
	        
	           uci delete mwan3."$name"_balanced
	           
	           uci delete mwan3statusconfig.$name
          fi 
         fi 
          
   uci commit mwan3
   uci commit mwan3statusconfig
}

config_load "$loadbalanceconfigfile" 
config_foreach DeleteLoadBalancingConfig loadbalancingconfig 

exit 0;

