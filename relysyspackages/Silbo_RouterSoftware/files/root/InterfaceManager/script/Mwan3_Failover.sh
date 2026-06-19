#!/bin/sh

. /lib/functions.sh

mwan3configfile="/etc/config/mwan3config"
Select=$(uci get mwan3config.general.select)

 uci delete mwan3.default_rule_v4
 uci delete mwan3.default_rule_v6

uci delete mwan3.failover > /dev/null 2>&1

uci delete mwan3.failover.use_member

 if [ "$Select" =  "failover" ]
 then
      #Default Rule V4
      uci set mwan3.default_rule_v4=rule
      uci set mwan3.default_rule_v4.dest_ip='0.0.0.0/0'
      uci set mwan3.default_rule_v4.family='ipv4'
      uci set mwan3.default_rule_v4.use_policy='failover'

	  #Default Rule V6
      uci set mwan3.default_rule_v6=rule
      uci set mwan3.default_rule_v6.dest_ip='::/0'
      uci set mwan3.default_rule_v6.family='ipv6'
      uci set mwan3.default_rule_v6.use_policy='failover'     
 
	  #policy for both V4 and V6
      uci set mwan3.failover=policy
      uci set mwan3.failover.last_resort='default'
 
 fi

UpdateFailoverConfig()
{
    failover="$1"
   	
  if [ "$failover" = "CWAN1" ] || [ "$failover" = "CWAN2" ] || [ "$failover" = "CWAN1_0" ] || [ "$failover" = "CWAN1_1" ]  || [ "$failover" = "wan6c1" ] || [ "$failover" = "wan6c2" ]
  then
        uci add_list mwan3.failover.use_member="${failover}_failover"
       
  else      
		config_get name "$failover" name
		config_get Enabled "$failover" enabled
		config_get Wanpriority "$failover" wanpriority
		config_get track_method "$failover" track_method
		config_get TrackIp1 "$failover" trackIp1
		config_get TrackIp2 "$failover" trackIp2
		config_get TrackIp3 "$failover" trackIp3
		config_get TrackIp4 "$failover" trackIp4
		config_get Reliability "$failover" reliability 
		config_get Count "$failover" count
		config_get Up "$failover" up
		config_get Down "$failover" down
		config_get Validtrackip "$failover" validtrackip
		config_get timeout "$failover" timeout
		config_get flush_conntrack "$failover" flush_conntrack
		config_get advance_settings "$failover" advance_settings
		config_get interval "$failover" interval
		config_get check_quality "$failover" check_quality
		config_get failure_latency "$failover" failure_latency
		config_get recovery_latency "$failover" recovery_latency
		config_get failure_loss "$failover" failure_loss
		config_get recovery_loss "$failover" recovery_loss
		config_get initial_state "$failover" initial_state

				if [ "$Select" =  "failover" ]
				then
                 
                     uci delete mwan3."$name" > /dev/null 2>&1
	                 uci delete mwan3.${name}_failover > /dev/null 2>&1 
	                  
                     delete_trackip=$(uci get mwan3."$name".track_ip)
                     uci del_list mwan3."$name".track_ip="$delete_trackip" 
                     
                     uci set loadbalancingconfig."$name"=loadbalancingconfig
                     uci set loadbalancingconfig."$name".name="$name"
                     uci set loadbalancingconfig."$name".enabled="1"
                     #uci set loadbalancingconfig."$name".weight="30"

                     #member
					 uci set mwan3.${name}_failover=member
					 uci set mwan3.${name}_failover.interface="$name"
					 uci set mwan3.${name}_failover.metric="$Wanpriority"
					 
					 #updating metric in network file as well
					 uci set network.${name}.metric="$Wanpriority"
					 uci set networkinterfaces.${name}.gatewaymetric="$Wanpriority"
     
	                 #adding members under policy
	                 uci add_list mwan3.failover.use_member="${name}_failover"
	            
					 uci set mwan3."$name"=interface
					 uci set mwan3."$name".enabled="$Enabled"
					 uci set mwan3."$name".track_method="$track_method"
                
                     if [ "$Validtrackip" =  "1" ]
	                 then 
						 uci add_list mwan3."$name".track_ip="$TrackIp1"
					 fi
					 if [ "$Validtrackip" =  "2" ]
					 then 
		             uci add_list mwan3."$name".track_ip="$TrackIp1"
		             uci add_list mwan3."$name".track_ip="$TrackIp2"
					 fi
					 if [ "$Validtrackip" =  "3" ]
					 then 
						 uci add_list mwan3."$name".track_ip="$TrackIp1"
						 uci add_list mwan3."$name".track_ip="$TrackIp2"
						 uci add_list mwan3."$name".track_ip="$TrackIp3"
					 fi
					 if [ "$Validtrackip" =  "4" ]
					 then 
						 uci add_list mwan3."$name".track_ip="$TrackIp1"
						 uci add_list mwan3."$name".track_ip="$TrackIp2"
						 uci add_list mwan3."$name".track_ip="$TrackIp3"
						 uci add_list mwan3."$name".track_ip="$TrackIp4"
					 fi
	                 uci set mwan3."$name".family="ipv4"
	                 uci set mwan3."$name".reliability="$Reliability"
	                 uci set mwan3."$name".count="$Count"
	                 uci set mwan3."$name".down="$Down"
	                 uci set mwan3."$name".up="$Up"
	                 
	                if [ "$flush_conntrack" =  "1" ]
					then 
						uci add_list mwan3."${name}".flush_conntrack="ifup"
						uci add_list mwan3."${name}".flush_conntrack="ifdown"
						uci add_list mwan3."${name}".flush_conntrack="connected"
						uci add_list mwan3."${name}".flush_conntrack="disconnected"
					else
					    uci del_list mwan3."${name}".flush_conntrack
					    uci del_list mwan3."${name}".flush_conntrack="ifdown"
						uci del_list mwan3."${name}".flush_conntrack="connected"
						uci del_list mwan3."${name}".flush_conntrack="disconnected"	
	                fi  
	                 
	                if [ "$initial_state" =  "1" ]
					then 
						uci set mwan3."$name".initial_state="offline"
	                else
						uci delete mwan3."$name".initial_state
	                fi 
	               
						uci set mwan3."${name}".timeout="$timeout"
						uci set mwan3."${name}".interval="$interval"
						uci set mwan3."${name}".check_quality="$check_quality"
						if [ "$check_quality" =  "1" ]
						then
							uci set mwan3."${name}".check_quality="1"
							uci set mwan3."${name}".failure_latency="$failure_latency"
							uci set mwan3."${name}".recovery_latency="$recovery_latency"
							uci set mwan3."${name}".failure_loss="$failure_loss"
							uci set mwan3."${name}".recovery_loss="$recovery_loss"
						else
							uci set mwan3."${name}".check_quality="0"
							uci delete mwan3."${name}".failure_latency
							uci delete mwan3."${name}".recovery_latency
							uci delete mwan3."${name}".failure_loss
							uci delete mwan3."${name}".recovery_loss	
						fi	
           fi   
    
     fi
     
  uci commit mwan3
  uci commit loadbalancingconfig
  uci commit networkinterfaces
  uci commit network
}

config_load "$mwan3configfile" 
config_foreach UpdateFailoverConfig mwan3config

#mwan3 restart
#/etc/init.d/network restart


