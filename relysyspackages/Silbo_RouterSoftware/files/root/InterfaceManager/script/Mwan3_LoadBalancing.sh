#!/bin/sh

. /lib/functions.sh

loadbalanceconfigfile="/etc/config/loadbalancingconfig"
Select=$(uci get mwan3config.general.select)

 uci delete mwan3.default_rule_v4
 uci delete mwan3.default_rule_v6

uci delete mwan3.balanced > /dev/null 2>&1

uci delete mwan3.balanced.use_member

if [ "$Select" =  "balanced" ]
 then
      #Default Rule V4
      uci set mwan3.default_rule_v4=rule
      uci set mwan3.default_rule_v4.dest_ip='0.0.0.0/0'
      uci set mwan3.default_rule_v4.family='ipv4'
      uci set mwan3.default_rule_v4.use_policy='balanced'

	  #Default Rule V6
      uci set mwan3.default_rule_v6=rule
      uci set mwan3.default_rule_v6.dest_ip='::/0'
      uci set mwan3.default_rule_v6.family='ipv6'
      uci set mwan3.default_rule_v6.use_policy='balanced'     
 
	  #policy for both V4 and V6
      uci set mwan3.balanced=policy
      uci set mwan3.balanced.last_resort='default'
 
 fi

#uci delete mwan3.balanced > /dev/null 2>&1

UpdateLoadBalancingConfig()
{
  loadbalance="$1"	
  	
  if [ "$loadbalance" = "CWAN1" ] || [ "$loadbalance" = "CWAN2" ] || [ "$loadbalance" = "CWAN1_0" ] || [ "$read_interface" = "CWAN1_1" ] || [ "$loadbalance" = "wan6c1" ] || [ "$loadbalance" = "wan6c2" ]
  then	
       uci add_list mwan3.balanced.use_member="${loadbalance}_balanced"
  else 
		config_get name "$loadbalance" name
		config_get Enabled "$loadbalance" enabled
		config_get Weight "$loadbalance" wanweight
		config_get track_method "$loadbalance" track_method
		config_get TrackIp1 "$loadbalance" trackIp1
		config_get TrackIp2 "$loadbalance" trackIp2
		config_get TrackIp3 "$loadbalance" trackIp3
		config_get TrackIp4 "$loadbalance" trackIp4
		config_get Reliability "$loadbalance" reliability 
		config_get Count "$loadbalance" count
		config_get Up "$loadbalance" up
		config_get Down "$loadbalance" down
		config_get Validtrackip "$loadbalance" validtrackip
		config_get timeout "$loadbalance" timeout
		config_get flush_conntrack "$loadbalance" flush_conntrack
		config_get advance_settings "$loadbalance" advance_settings
		config_get interval "$loadbalance" interval
		config_get check_quality "$loadbalance" check_quality
		config_get failure_latency "$loadbalance" failure_latency
		config_get recovery_latency "$loadbalance" recovery_latency
		config_get failure_loss "$loadbalance" failure_loss
		config_get recovery_loss "$loadbalance" recovery_loss
		config_get initial_state "$loadbalance" initial_state
  
           if [ "$Select" =  "balanced" ]
           then
                
                 uci delete mwan3."$name" > /dev/null 2>&1
                 uci delete mwan3.${name}_balanced > /dev/null 2>&1 
	                  
                 delete_trackip=$(uci get mwan3."$name".track_ip)
                 uci del_list mwan3."$name".track_ip="$delete_trackip" 
                   
                #member
				 uci set mwan3.${name}_balanced=member
				 uci set mwan3.${name}_balanced.interface="$name"
				 uci set mwan3.${name}_balanced.weight="$Weight"
				 uci set mwan3.${name}_balanced.metric="1"
				 
				 uci set network."$name".metric="1"
				 uci commit network
     
	            #adding members under policy
	             uci add_list mwan3.balanced.use_member="${name}_balanced"
  
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
	                 uci set mwan3."$name".timeout="2"
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
            
  
}

config_load "$loadbalanceconfigfile" 
config_foreach UpdateLoadBalancingConfig loadbalancingconfig

#mwan3 restart               
  
