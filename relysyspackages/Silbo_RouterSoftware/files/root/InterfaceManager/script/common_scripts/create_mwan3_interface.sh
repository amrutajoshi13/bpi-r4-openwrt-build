#!/bin/sh

. /lib/functions.sh

# Adds WIFI_WAN to mwan3 if WIFI_WAN isn't there in mwan3 and the modes are sta/apsta.

Wireless()
{
	mwaninterface="WIFI_WAN"
	wifipriority="12"
	
	if [ "$wifi1enable" = "1" ]
	then
		# prints true or false
		interface_status=$(ubus call mwan3 status '{}' | jq --arg mwaninterface "$mwaninterface" '.interfaces | has($mwaninterface)')

		#interface_status=false
		#If WIFI_WAN isn't there in mwan3 and the modes are sta/apsta, then, create it.
		if [ "$interface_status" = "false" ]
		then
			if [ "$wifi1mode" =  "sta" ] || [ "$wifi1mode" =  "apsta" ]
			then
				#create a flag, using which, we restart mwan3.
				mwan3_restart_flag=1
				
				#Call the function to create new interface in mwan3 & mwan3config.
				CreateMwan3configInterface $mwaninterface $wifipriority
			fi
		#interface_status=true
		#If ${mwaninterface} is present in mwan3 & wifimode is AP, then delete from mwan3config and disable it in mwan3.
		else
			if [ "$wifi1mode" = "ap" ]
			then
				uci delete mwan3config.${mwaninterface}
				uci commit mwan3config
				uci delete loadbalancingconfig.${mwaninterface}
				uci commit loadbalancingconfig
				
				# disable interface in /etc/config/mwan3
				uci -q delete mwan3."${mwaninterface}"
				
				member="${mwaninterface}_member"
				# remove member entry from policies and delete the member section
				uci -q del_list mwan3.balanced_v4.use_member="$member"
				uci -q del_list mwan3.balanced_v6.use_member="$member"
				uci -q del_list mwan3.failover_v4.use_member="$member"
				uci -q del_list mwan3.failover_v6.use_member="$member"
				
				uci -q delete mwan3."${member}"

				uci commit mwan3
				
				#create a flag, using which, we restart mwan3.
				mwan3_restart_flag=1
			fi
		fi
	#If wifi is disabled, delete the ${mwaninterface} if it is present in mwan3.
	else	
		# prints true or false
		interface_status=$(ubus call mwan3 status '{}' | jq --arg mwaninterface "$mwaninterface" '.interfaces | has($mwaninterface)')
		
		#interface_status=true
		if [ "$interface_status" = "true" ]
		then
			uci delete mwan3config.${mwaninterface}
			uci commit mwan3config
			
			# disable interface in /etc/config/mwan3
			uci -q delete mwan3."${mwaninterface}"
			
			member="${mwaninterface}_member"
			# remove member entry from policies and delete the member section
			uci -q del_list mwan3.balanced_v4.use_member="$member"
			uci -q del_list mwan3.balanced_v6.use_member="$member"
			uci -q del_list mwan3.failover_v4.use_member="$member"
			uci -q del_list mwan3.failover_v6.use_member="$member"
			
			uci -q delete mwan3."${member}"

			uci commit mwan3
			
			#create a flag, using which, we restart mwan3.
			mwan3_restart_flag=1
		fi
	fi
}

# Helper: delete a single mwan interface + its config/member/policy entries
DeleteMwan3Entries()
{
    del="$1"
    [ -z "$del" ] && return

    # Map interface name -> member name
    case "$del" in
        CWAN1)   member="cwan1_member" ;;
        CWAN2)   member="cwan2_member" ;;
        CWAN1_0) member="cwan1sim1_member" ;;
        CWAN1_1) member="cwan1sim2_member" ;;
        wan6c1)  member="cwan6_1_member" ;;
        wan6c2)  member="cwan6_2_member" ;;
        *)       member="" ;;
    esac

    # check presence (use jq --arg to pass the shell var safely)
    interface_status=$(ubus call mwan3 status '{}' | jq --arg del "$del" '.interfaces | has($del)')

    if [ "$interface_status" = "true" ]
    then
        # remove from /etc/config/mwan3config if present
        uci -q delete mwan3config."${del}"
        uci commit mwan3config

        # disable interface in /etc/config/mwan3
        uci -q delete mwan3."${del}"

        # remove member entry from policies and delete the member section (only if we know the member name)
        if [ -n "$member" ]; then
            uci -q del_list mwan3.balanced_v4.use_member="$member"
            uci -q del_list mwan3.balanced_v6.use_member="$member"
            uci -q del_list mwan3.failover_v4.use_member="$member"
            uci -q del_list mwan3.failover_v6.use_member="$member"
            uci -q delete mwan3."${member}"
        fi

        uci commit mwan3

        # mark for restart
        mwan3_restart_flag=1
    fi
}

Cellular()
{
    # Build the lists correctly (space-separated strings)
    interface=""
    del_interface=""

    if [ "$enablecellular" = "1" ]
    then
        if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then
			if [ "$pdp" = "IPV4" ]
			then
				interface="CWAN1"
				del_interface="wan6c1 CWAN1_0"
			elif [ "$pdp" = "IPV6" ]
			then
				interface="wan6c1"
				del_interface="CWAN1_0 CWAN1"
			elif [ "$pdp" = "IPV4V6" ]
			then
				interface="CWAN1 wan6c1"
				del_interface="CWAN1_0"
			fi

			if [ "$sim2pdp" = "IPV4" ]
			then
				interface="${interface} CWAN2"
				del_interface="${del_interface} CWAN1_1 wan6c2"
			elif [ "$sim2pdp" = "IPV6" ]
			then
				interface="${interface} wan6c2"
				del_interface="${del_interface} CWAN1_1 CWAN2"
			elif [ "$sim2pdp" = "IPV4V6" ]
			then
				interface="${interface} CWAN2 wan6c2"
				del_interface="${del_interface} CWAN1_1"
			fi

		elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
			if [ "$pdp" = "IPV4" ]
			then
				interface="CWAN1_0"
				del_interface="wan6c1 CWAN1"
			elif [ "$pdp" = "IPV6" ]
			then
				interface="wan6c1"
				del_interface="CWAN1_0 CWAN1"
			elif [ "$pdp" = "IPV4V6" ]
			then
				interface="CWAN1_0 wan6c1"
				del_interface="CWAN1"
			fi

			if [ "$sim2pdp" = "IPV4" ]
			then
				interface="${interface} CWAN1_1"
				del_interface="${del_interface} CWAN2 wan6c2"
			elif [ "$sim2pdp" = "IPV6" ]
			then
				interface="${interface} wan6c2"
				del_interface="${del_interface} CWAN1_1 CWAN2"
			elif [ "$sim2pdp" = "IPV4V6" ]
			then
				interface="${interface} CWAN1_1 wan6c2"
				del_interface="${del_interface} CWAN2"
			fi

		elif [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
		then
			if [ "$pdp" = "IPV4" ]
			then
				interface="CWAN1"
				del_interface="wan6c1 CWAN1_0 CWAN1_1 wan6c2 CWAN2"
			elif [ "$pdp" = "IPV6" ]
			then
				interface="wan6c1"
				del_interface="CWAN1_0 CWAN1 CWAN1_1 wan6c2 CWAN2"
			elif [ "$pdp" = "IPV4V6" ]
			then
				interface="CWAN1 wan6c1"
				del_interface="CWAN1_0 CWAN1_1 wan6c2 CWAN2"
			fi
		fi
		
        # iterate over interfaces to ensure creation
        for mwaninterface in $interface
        do
            case "$mwaninterface" in
                CWAN1)   cellpriority="6" ;;
                CWAN2)   cellpriority="7" ;;
                CWAN1_0) cellpriority="8" ;;
                CWAN1_1) cellpriority="9" ;;
                wan6c1)  cellpriority="254" ;;
                wan6c2)  cellpriority="256" ;;
            esac

            # check presence using --arg to pass the shell variable safely
            interface_status=$(ubus call mwan3 status '{}' | jq --arg mwaninterface "$mwaninterface" '.interfaces | has($mwaninterface)')

            if [ "$interface_status" = "false" ]
            then
                mwan3_restart_flag=1
                
                CreateMwan3configInterface $mwaninterface $cellpriority
            fi
        done

        # now delete any interfaces from the del_interface list
        for del in $del_interface
        do
            DeleteMwan3Entries "$del"
        done
        
    else
		uci delete mwan3config.CWAN1
		uci delete mwan3config.CWAN2
		uci delete mwan3config.CWAN1_0
		uci delete mwan3config.CWAN1_1
		uci delete mwan3config.wan6c1
		uci delete mwan3config.wan6c2
		
		uci commit mwan3config
		
		for int in "wan6c1" "CWAN1_0" "CWAN1_1" "wan6c2" "CWAN2" "CWAN1"
		do
			uci -q delete mwan3."${int}"
			
			case "$int" in
				CWAN1)   member="cwan1_member" ;;
				CWAN2)   member="cwan2_member" ;;
				CWAN1_0) member="cwan1sim1_member" ;;
				CWAN1_1) member="cwan1sim2_member" ;;
				wan6c1)  member="cwan6_1_member" ;;
				wan6c2)  member="cwan6_2_member" ;;
				*)       member="" ;;
			esac
			
			# remove member entry from policies and delete the member section (only if we know the member name)
			if [ -n "$member" ]; then
				uci -q del_list mwan3.balanced_v4.use_member="$member"
				uci -q del_list mwan3.balanced_v6.use_member="$member"
				uci -q del_list mwan3.failover_v4.use_member="$member"
				uci -q del_list mwan3.failover_v6.use_member="$member"
				uci -q delete mwan3."${member}"
			fi
		done
		
        uci commit mwan3
    fi
}

CreateMwan3configInterface()
{	
	mwaninterface="$1"
	interfacepriority="$2"
	
	uci set mwan3config.${mwaninterface}=mwan3config
	uci set mwan3config.${mwaninterface}.name=${mwaninterface}
	
	if [ "$policy_type" = "balanced" ]
	then
		uci set mwan3config.${mwaninterface}.wanpriority=1
	else
		uci set mwan3config.${mwaninterface}.wanpriority="$interfacepriority"
	fi
	
	uci set mwan3config.${mwaninterface}.track_method="ping"
	uci set mwan3config.${mwaninterface}.validtrackip=2
	uci set mwan3config."${mwaninterface}".enabled="1"

	if [ "$mwaninterface" = "wan6c1" ] || [ "$mwaninterface" = "wan6c2" ]
	then
		uci set mwan3config.${mwaninterface}.trackIp1=2001:4860:4860::8888
		uci set mwan3config.${mwaninterface}.trackIp2=2001:4860:4860::8844
		pdp=$(uci get sysconfig.sysconfig.pdp)
		pdp2=$(uci get sysconfig.sysconfig.sim2pdp)
		if ([ "$pdp" = "IPV6" ] && [ "$mwaninterface" = "wan6c1" ]) || ([ "$pdp2" = "IPV6" ] && [ "$mwaninterface" = "wan6c2" ]);then
			uci set mwan3config."${mwaninterface}".enabled="1"
		else 
			uci set mwan3config."${mwaninterface}".enabled="0"
		fi
	else
		uci set mwan3config.${mwaninterface}.trackIp1=8.8.8.8
		uci set mwan3config.${mwaninterface}.trackIp2=8.8.4.4
	fi	
	uci set mwan3config.${mwaninterface}.reliability=1
	uci set mwan3config.${mwaninterface}.count=1
	uci set mwan3config.${mwaninterface}.timeout=2
	uci set mwan3config.${mwaninterface}.up=3
	uci set mwan3config.${mwaninterface}.down=3
	uci set mwan3config.${mwaninterface}.flush_conntrack=1
	uci set mwan3config.${mwaninterface}.interval=2

	uci commit mwan3config

	#Now create mwan3 interface.
	CreateMwan3Interface $mwaninterface		
	
}

CreateMwan3Interface()
{
	mwaninterface="$1"
	
	#Load /etc/config/mwan3config
	config_load "$MwanConfigFile"
	
	config_get name "$mwaninterface" name
	config_get wanpriority "$mwaninterface" wanpriority
	config_get wanweight "$mwaninterface" wanweight
	config_get enabled "$mwaninterface" enabled
	config_get trackIp1 "$mwaninterface" trackIp1
	config_get trackIp2 "$mwaninterface" trackIp2
	config_get trackIp3 "$mwaninterface" trackIp3
	config_get trackIp4 "$mwaninterface" trackIp4
	config_get reliability "$mwaninterface" reliability 
	config_get count "$mwaninterface" count
	config_get up "$mwaninterface" up
	config_get down "$mwaninterface" down
	config_get validtrackip "$mwaninterface" validtrackip
	config_get track_method "$mwaninterface" track_method
	config_get flush_conntrack "$mwaninterface" flush_conntrack
	config_get initial_state "$mwaninterface" initial_state
	config_get interval "$mwaninterface" interval
	config_get timeout "$mwaninterface" timeout
	config_get check_quality "$mwaninterface" check_quality
	config_get failure_latency "$mwaninterface" failure_latency
	config_get recovery_latency "$mwaninterface" recovery_latency
	config_get failure_loss "$mwaninterface" failure_loss
	config_get recovery_loss "$mwaninterface" recovery_loss

	uci set mwan3."${mwaninterface}"=interface
	#Check mwan3 enable/disable for individual interfaces
	if [ "$enabled" = "1" ]
	then
		uci set mwan3."${mwaninterface}".enabled="1"
	else
		uci set mwan3."${mwaninterface}".enabled="0"
	fi

	if [ "$validtrackip" =  "1" ]
	then 
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp1"
	fi
	if [ "$validtrackip" =  "2" ]
	then 
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp1"
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp2"
	fi
	if [ "$validtrackip" =  "3" ]
	then 
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp1"
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp2"
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp3"
	fi
	if [ "$validtrackip" =  "4" ]
	then 
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp1"
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp2"
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp3"
		uci add_list mwan3."${mwaninterface}".track_ip="$trackIp4"
	fi

	#uci set mwan3."${mwaninterface}".family="ipv4"
	uci set mwan3."${mwaninterface}".reliability="$reliability"
	uci set mwan3."${mwaninterface}".count="$count"
	uci set mwan3."${mwaninterface}".down="$down"
	uci set mwan3."${mwaninterface}".up="$up"
	uci set mwan3."${mwaninterface}".track_method="$track_method"
	uci set mwan3."${mwaninterface}".interval="$interval"
	uci set mwan3."${mwaninterface}".timeout="$timeout"
	uci set mwan3."${mwaninterface}".check_quality="$check_quality"
	if [ "$check_quality" =  "1" ]
	then 
		uci set mwan3."${mwaninterface}".failure_latency="$failure_latency"
		uci set mwan3."${mwaninterface}".recovery_latency="$recovery_latency"
		uci set mwan3."${mwaninterface}".failure_loss="$failure_loss"
		uci set mwan3."${mwaninterface}".recovery_loss="$recovery_loss"
	else
		uci delete mwan3."${mwaninterface}".failure_latency
		uci delete mwan3."${mwaninterface}".recovery_latency
		uci delete mwan3."${mwaninterface}".failure_loss
		uci delete mwan3."${mwaninterface}".recovery_loss	
	fi
	
	if [ "$flush_conntrack" = "1" ]
	then
		uci add_list mwan3."${mwaninterface}".flush_conntrack="ifup"
		uci add_list mwan3."${mwaninterface}".flush_conntrack="ifdown"
		uci add_list mwan3."${mwaninterface}".flush_conntrack="connected"
		uci add_list mwan3."${mwaninterface}".flush_conntrack="disconnected"
	fi
	
	if [ "$initial_state" = "1" ]
	then
		uci set mwan3."${mwaninterface}".initial_state="offline"
	fi
	
	case "$mwaninterface" in
		CWAN1)   member="cwan1_member" ;;
		CWAN2)   member="cwan2_member" ;;
		CWAN1_0) member="cwan1sim1_member" ;;
		CWAN1_1) member="cwan1sim2_member" ;;
		wan6c1)  member="cwan6_1_member" ;;
		wan6c2)  member="cwan6_2_member" ;;
		*)       member="WIFI_WAN_member" ;;
	esac

	
	#member
	uci set mwan3.$member=member
	uci set mwan3.$member.interface="${mwaninterface}"
	uci set mwan3.$member.metric="$wanpriority"

	#Add weight only when policy is balanced.
	if [ "$policy_type" = "balanced" ]
	then
		uci set mwan3.$member.weight="$wanweight"
	fi
	
	if [ "$mwaninterface" = "wan6c1" ] || [ "$mwaninterface" = "wan6c2" ]
	then
		uci set mwan3."${mwaninterface}".family="ipv6"
		if [ "$policy_type" = "balanced" ]
		then
			#balanced_v6
			uci set mwan3.balanced_v6=policy
			uci set mwan3.balanced_v6.last_resort='default'
			uci add_list mwan3.balanced_v6.use_member="$member"
		elif [ "$policy_type" = "failover" ]
		then
			#failover_v6
			uci set mwan3.failover_v6=policy
			uci set mwan3.failover_v6.last_resort='default'
			uci add_list mwan3.failover_v6.use_member="$member"
		fi
	else
		uci set mwan3."${mwaninterface}".family="ipv4"
		if [ "$policy_type" = "balanced" ]
		then
			#balanced_v4
			uci set mwan3.balanced_v4=policy
			uci set mwan3.balanced_v4.last_resort='default'
			uci add_list mwan3.balanced_v4.use_member="$member"
		elif [ "$policy_type" = "failover" ]
		then
			#failover_v4
			uci set mwan3.failover_v4=policy
			uci set mwan3.failover_v4.last_resort='default'
			uci add_list mwan3.failover_v4.use_member="$member"
		fi
	fi

	uci commit mwan3
}

policy_type=$(uci get mwan3config.general.select)
wifi1enable=$(uci get sysconfig.wificonfig.wifi1enable)
wifi1mode=$(uci get sysconfig.wificonfig.wifi1mode)
enablecellular=$(uci get sysconfig.sysconfig.enablecellular)
CellularOperationModelocal=$(uci get sysconfig.sysconfig.CellularOperationMode)
pdp=$(uci get sysconfig.sysconfig.pdp)
sim2pdp=$(uci get sysconfig.sysconfig.sim2pdp)
MwanConfigFile="/etc/config/mwan3config"

#Initialize the flag to 0, so it returns the value.
mwan3_restart_flag=0

# ---- argument checking: require one valid argument ----
if [ $# -lt 1 ]; then
    # Inform user on stderr, but return the restart flag (0) on stdout so callers don't restart
    echo "Usage: $0 {wireless|cellular}" >&2
    printf '%s\n' "$mwan3_restart_flag"
    exit 0
fi

if [ "$1" = "wireless" ]
then
	Wireless
else
	Cellular
fi

# Print only the restart flag so callers using command substitution can read it (return thingy).
printf '%s\n' "$mwan3_restart_flag"
exit 0
