#!/bin/sh

. /lib/functions.sh

ReadSystemConfigFile()
{
	#  Cellular
	CellularOperationModelocal=$(uci get sysconfig.sysconfig.CellularOperationMode)
	Pdp1=$(uci get sysconfig.sysconfig.pdp)
	sim2pdp=$(uci get sysconfig.sysconfig.sim2pdp)
	EnableCellular=$(uci get sysconfig.sysconfig.enablecellular)

	# Wifi
	wifi1enable=$(uci get sysconfig.wificonfig.wifi1enable)
	wifi1mode=$(uci get sysconfig.wificonfig.wifi1mode)
}

ReadMwanConfigFile()
{
	#Clear the contents of mwan3 config file.
	echo > /etc/config/mwan3
	
	#Write the globals config.
	uci set mwan3.globals=globals
	uci set mwan3.globals.enabled='1'
	uci set mwan3.globals.mmx_mask='0x3F00'
	uci set mwan3.globals.rtmon_interval='5'
	
	uci set mwan3.default_rule_v6=rule
	uci set mwan3.default_rule_v6.dest_ip='::/0'
	uci set mwan3.default_rule_v6.family='ipv6'
	
	uci set mwan3.default_rule_v4=rule
	uci set mwan3.default_rule_v4.dest_ip='0.0.0.0/0'
	uci set mwan3.default_rule_v4.family='ipv4'
	
	uci commit mwan3
	
	#Load /etc/config/mwan3config
	config_load "$MwanConfigFile"
	config_foreach UpdateMwanConfig redirect
	
	UpdateCellularMwan3Config
}

UpdateCellularMwan3Config()
{
	config_get NameWifiwan "$wifiwaninterface" name
	config_get WifiwanPriority "$wifiwaninterface" wanpriority
	config_get WifiwanWeight "$wifiwaninterface" wanweight
	config_get Wifiwanenabled "$wifiwaninterface" enabled
	config_get WifiwanTrackIp1 "$wifiwaninterface" trackIp1
	config_get WifiwanTrackIp2 "$wifiwaninterface" trackIp2
	config_get WifiwanTrackIp3 "$wifiwaninterface" trackIp3
	config_get WifiwanTrackIp4 "$wifiwaninterface" trackIp4
	config_get WifiwanReliability "$wifiwaninterface" reliability 
	config_get WifiwanCount "$wifiwaninterface" count
	config_get WifiwanUp "$wifiwaninterface" up
	config_get WifiwanDown "$wifiwaninterface" down
	config_get WifiwanValidtrackip "$wifiwaninterface" validtrackip
	config_get Wifiwantrackmethod "$wifiwaninterface" track_method
	config_get Wifiwanflush_conntrack "$wifiwaninterface" flush_conntrack
	config_get Wifiwaninitial_state "$wifiwaninterface" initial_state
	config_get Wifiwaninterval "$wifiwaninterface" interval
	config_get Wifiwantimeout "$wifiwaninterface" timeout
	config_get Wifiwancheck_quality "$wifiwaninterface" check_quality
	config_get Wifiwanfailure_latency "$wifiwaninterface" failure_latency
	config_get Wifiwanrecovery_latency "$wifiwaninterface" recovery_latency
	config_get Wifiwanfailure_loss "$wifiwaninterface" failure_loss
	config_get Wifiwanrecovery_loss "$wifiwaninterface" recovery_loss

	config_get NameCwan1 "$cellularwan1interface" name
	config_get Cwan1Priority "$cellularwan1interface" wanpriority
	config_get Cwan1Weight "$cellularwan1interface" wanweight
	config_get Cwan1enabled "$cellularwan1interface" enabled
	config_get Cwan1TrackIp1 "$cellularwan1interface" trackIp1
	config_get Cwan1TrackIp2 "$cellularwan1interface" trackIp2
	config_get Cwan1TrackIp3 "$cellularwan1interface" trackIp3
	config_get Cwan1TrackIp4 "$cellularwan1interface" trackIp4
	config_get Cwan1Reliability "$cellularwan1interface" reliability 
	config_get Cwan1Count "$cellularwan1interface" count
	config_get Cwan1Up "$cellularwan1interface" up
	config_get Cwan1Down "$cellularwan1interface" down
	config_get Cwan1Validtrackip "$cellularwan1interface" validtrackip
	config_get Cwan1trackmethod "$cellularwan1interface" track_method
	config_get Cwan1flush_conntrack "$cellularwan1interface" flush_conntrack
	config_get Cwan1interval "$cellularwan1interface" interval
	config_get Cwan1timeout "$cellularwan1interface" timeout
	config_get Cwan1check_quality "$cellularwan1interface" check_quality
	config_get Cwan1failure_latency "$cellularwan1interface" failure_latency
	config_get Cwan1recovery_latency "$cellularwan1interface" recovery_latency
	config_get Cwan1failure_loss "$cellularwan1interface" failure_loss
	config_get Cwan1recovery_loss "$cellularwan1interface" recovery_loss

	config_get NameCwan2 "$cellularwan2interface" name
	config_get Cwan2Priority "$cellularwan2interface" wanpriority
	config_get Cwan2Weight "$cellularwan2interface" wanweight
	config_get Cwan2enabled "$cellularwan2interface" enabled
	config_get Cwan2TrackIp1 "$cellularwan2interface" trackIp1
	config_get Cwan2TrackIp2 "$cellularwan2interface" trackIp2
	config_get Cwan2TrackIp3 "$cellularwan2interface" trackIp3
	config_get Cwan2TrackIp4 "$cellularwan2interface" trackIp4
	config_get Cwan2Reliability "$cellularwan2interface" reliability 
	config_get Cwan2Count "$cellularwan2interface" count
	config_get Cwan2Up "$cellularwan2interface" up
	config_get Cwan2Down "$cellularwan2interface" down
	config_get Cwan2Validtrackip "$cellularwan2interface" validtrackip
	config_get Cwan2trackmethod "$cellularwan2interface" track_method
	config_get Cwan2flush_conntrack "$cellularwan2interface" flush_conntrack
	config_get Cwan2interval "$cellularwan2interface" interval
	config_get Cwan2timeout "$cellularwan2interface" timeout
	config_get Cwan2check_quality "$cellularwan2interface" check_quality
	config_get Cwan2failure_latency "$cellularwan2interface" failure_latency
	config_get Cwan2recovery_latency "$cellularwan2interface" recovery_latency
	config_get Cwan2failure_loss "$cellularwan2interface" failure_loss
	config_get Cwan2recovery_loss "$cellularwan2interface" recovery_loss
	  
	config_get NameCwansim1 "$cellularwan1sim1interface" name
	config_get Cwan1sim1Priority "$cellularwan1sim1interface" wanpriority
	config_get Cwan1sim1Weight "$cellularwan1sim1interface" wanweight
	config_get Cwan1sim1enabled "$cellularwan1sim1interface" enabled
	config_get Cwan1sim1TrackIp1 "$cellularwan1sim1interface" trackIp1
	config_get Cwan1sim1TrackIp2 "$cellularwan1sim1interface" trackIp2
	config_get Cwan1sim1TrackIp3 "$cellularwan1sim1interface" trackIp3
	config_get Cwan1sim1TrackIp4 "$cellularwan1sim1interface" trackIp4
	config_get Cwan1sim1Reliability "$cellularwan1sim1interface" reliability 
	config_get Cwan1sim1Count "$cellularwan1sim1interface" count
	config_get Cwan1sim1Up "$cellularwan1sim1interface" up
	config_get Cwan1sim1Down "$cellularwan1sim1interface" down
	config_get Cwan1sim1Validtrackip "$cellularwan1sim1interface" validtrackip
	config_get Cwan1sim1trackmethod "$cellularwan1sim1interface" track_method
	config_get Cwan1sim1flush_conntrack "$cellularwan1sim1interface" flush_conntrack
	config_get Cwan1sim1interval "$cellularwan1sim1interface" interval
	config_get Cwan1sim1timeout "$cellularwan1sim1interface" timeout
	config_get Cwan1sim1interval "$cellularwan1sim1interface" interval
	config_get Cwan1sim1check_quality "$cellularwan1sim1interface" check_quality
	config_get Cwan1sim1failure_latency "$cellularwan1sim1interface" failure_latency
	config_get Cwan1sim1recovery_latency "$cellularwan1sim1interface" recovery_latency
	config_get Cwan1sim1failure_loss "$cellularwan1sim1interface" failure_loss
	config_get Cwan1sim1recovery_loss "$cellularwan1sim1interface" recovery_loss
	  
	config_get NameCwansim2 "$cellularwan1sim2interface" name
	config_get Cwan1sim2Priority "$cellularwan1sim2interface" wanpriority
	config_get Cwan1sim2Weight "$cellularwan1sim2interface" wanweight
	config_get Cwan1sim2enabled "$cellularwan1sim2interface" enabled
	config_get Cwan1sim2TrackIp1 "$cellularwan1sim2interface" trackIp1
	config_get Cwan1sim2TrackIp2 "$cellularwan1sim2interface" trackIp2
	config_get Cwan1sim2TrackIp3 "$cellularwan1sim2interface" trackIp3
	config_get Cwan1sim2TrackIp4 "$cellularwan1sim2interface" trackIp4
	config_get Cwan1sim2Reliability "$cellularwan1sim2interface" reliability 
	config_get Cwan1sim2Count "$cellularwan1sim2interface" count
	config_get Cwan1sim2Up "$cellularwan1sim2interface" up
	config_get Cwan1sim2Down "$cellularwan1sim2interface" down
	config_get Cwan1sim2Validtrackip "$cellularwan1sim2interface" validtrackip
	config_get Cwan1sim2trackmethod "$cellularwan1sim2interface" track_method
	config_get Cwan1sim2flush_conntrack "$cellularwan1sim2interface" flush_conntrack
	config_get Cwan1sim2interval "$cellularwan1sim2interface" interval
	config_get Cwan1sim2timeout "$cellularwan1sim2interface" timeout
	config_get Cwan1sim2check_quality "$cellularwan1sim2interface" check_quality
	config_get Cwan1sim2failure_latency "$cellularwan1sim2interface" failure_latency
	config_get Cwan1sim2recovery_latency "$cellularwan1sim2interface" recovery_latency
	config_get Cwan1sim2failure_loss "$cellularwan1sim2interface" failure_loss
	config_get Cwan1sim2recovery_loss "$cellularwan1sim2interface" recovery_loss
	 
	#IPV6 variables
	config_get NameCwan6_1 "$cellular1wan6interface" name
	config_get Cwan6_1Priority "$cellular1wan6interface" wanpriority
	config_get Cwan6_1Weight "$cellular1wan6interface" wanweight
	config_get Cwan6_1enabled "$cellular1wan6interface" enabled
	config_get Cwan6_1TrackIp1 "$cellular1wan6interface" trackIp1
	config_get Cwan6_1TrackIp2 "$cellular1wan6interface" trackIp2
	config_get Cwan6_1TrackIp3 "$cellular1wan6interface" trackIp3
	config_get Cwan6_1TrackIp4 "$cellular1wan6interface" trackIp4
	config_get Cwan6_1Reliability "$cellular1wan6interface" reliability
	config_get Cwan6_1Count "$cellular1wan6interface" count
	config_get Cwan6_1Up "$cellular1wan6interface" up
	config_get Cwan6_1Down "$cellular1wan6interface" down
	config_get Cwan6_1validtrackip "$cellular1wan6interface" validtrackip
	config_get Cwan6_1trackmethod "$cellular1wan6interface" track_method
	config_get Cwan6_1flush_conntrack "$cellular1wan6interface" flush_conntrack
	config_get Cwan6_1interval "$cellular1wan6interface" interval
	config_get Cwan6_1timeout "$cellular1wan6interface" timeout
	config_get Cwan6_1check_quality "$cellular1wan6interface" check_quality
	config_get Cwan6_1failure_latency "$cellular1wan6interface" failure_latency
	config_get Cwan6_1recovery_latency "$cellular1wan6interface" recovery_latency
	config_get Cwan6_1failure_loss "$cellular1wan6interface" failure_loss
	config_get Cwan6_1recovery_loss "$cellular1wan6interface" recovery_loss

	config_get NameCwan6_2 "$cellular2wan6interface" name
	config_get Cwan6_2Priority "$cellular2wan6interface" wanpriority
	config_get Cwan6_2Weight "$cellular2wan6interface" wanweight
	config_get Cwan6_2enabled "$cellular2wan6interface" enabled
	config_get Cwan6_2TrackIp1 "$cellular2wan6interface" trackIp1
	config_get Cwan6_2TrackIp2 "$cellular2wan6interface" trackIp2
	config_get Cwan6_2TrackIp3 "$cellular2wan6interface" trackIp3
	config_get Cwan6_2TrackIp4 "$cellular2wan6interface" trackIp4
	config_get Cwan6_2Reliability "$cellular2wan6interface" reliability
	config_get Cwan6_2Count "$cellular2wan6interface" count
	config_get Cwan6_2Up "$cellular2wan6interface" up
	config_get Cwan6_2Down "$cellular2wan6interface" down
	config_get Cwan6_2validtrackip "$cellular2wan6interface" validtrackip
	config_get Cwan6_2trackmethod "$cellular2wan6interface" track_method
	config_get Cwan6_2flush_conntrack "$cellular2wan6interface" flush_conntrack
	config_get Cwan6_2interval "$cellular2wan6interface" interval
	config_get Cwan6_2timeout "$cellular2wan6interface" timeout
	config_get Cwan6_2interval "$cellular2wan6interface" interval
	config_get Cwan6_2check_quality "$cellular2wan6interface" check_quality
	config_get Cwan6_2failure_latency "$cellular2wan6interface" failure_latency
	config_get Cwan6_2recovery_latency "$cellular2wan6interface" recovery_latency
	config_get Cwan6_2failure_loss "$cellular2wan6interface" failure_loss
	config_get Cwan6_2recovery_loss "$cellular2wan6interface" recovery_loss
  	
	#WIFI_WAN
	if [ "$wifi1enable" = "1" ]
	then 
		#apsta
		if [ "$wifi1mode" = "sta" ] ||  [ "$wifi1mode" = "apsta" ] 
		then
			uci delete mwan3.WIFI_WAN_member > /dev/null 2>&1
			uci set mwan3."${wifiwaninterface}"=interface

			#Check mwan3 enable/disable for individual interfaces
			if [ "$Wifiwanenabled" = "1" ]
			then
				uci set mwan3."${wifiwaninterface}".enabled="1"
			else
				uci set mwan3."${wifiwaninterface}".enabled="0"
			fi

			if [ "$WifiwanValidtrackip" =  "1" ]
			then 
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp1"
			fi
			if [ "$WifiwanValidtrackip" =  "2" ]
			then 
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp1"
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp2"
			fi
			if [ "$WifiwanValidtrackip" =  "3" ]
			then 
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp1"
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp2"
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp3"
			fi
			if [ "$WifiwanValidtrackip" =  "4" ]
			then 
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp1"
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp2"
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp3"
				uci add_list mwan3."${wifiwaninterface}".track_ip="$WifiwanTrackIp4"
			fi

			uci set mwan3."${wifiwaninterface}".family="ipv4"
			uci set mwan3."${wifiwaninterface}".reliability="$WifiwanReliability"
			uci set mwan3."${wifiwaninterface}".count="$WifiwanCount"
			uci set mwan3."${wifiwaninterface}".down="$WifiwanDown"
			uci set mwan3."${wifiwaninterface}".up="$WifiwanUp"
            uci set mwan3."${wifiwaninterface}".track_method="$Wifiwantrackmethod"
            uci set mwan3."${wifiwaninterface}".interval="$Wifiwaninterval"
            uci set mwan3."${wifiwaninterface}".timeout="$Wifiwantimeout"
			uci set mwan3."${wifiwaninterface}".check_quality="$Wifiwancheck_quality"
			if [ "$Wifiwancheck_quality" =  "1" ]
			then 
				uci set mwan3."${wifiwaninterface}".failure_latency="$Wifiwanfailure_latency"
				uci set mwan3."${wifiwaninterface}".recovery_latency="$Wifiwanrecovery_latency"
				uci set mwan3."${wifiwaninterface}".failure_loss="$Wifiwanfailure_loss"
				uci set mwan3."${wifiwaninterface}".recovery_loss="$Wifiwanrecovery_loss"
			else
				uci delete mwan3."${wifiwaninterface}".failure_latency
				uci delete mwan3."${wifiwaninterface}".recovery_latency
				uci delete mwan3."${wifiwaninterface}".failure_loss
				uci delete mwan3."${wifiwaninterface}".recovery_loss	
			fi
            
            if [ "$Wifiwanflush_conntrack" = "1" ]
            then
				uci add_list mwan3."${wifiwaninterface}".flush_conntrack="ifup"
				uci add_list mwan3."${wifiwaninterface}".flush_conntrack="ifdown"
				uci add_list mwan3."${wifiwaninterface}".flush_conntrack="connected"
				uci add_list mwan3."${wifiwaninterface}".flush_conntrack="disconnected"
            fi
            
            if [ "$Wifiwaninitial_state" = "1" ]
            then
				uci set mwan3."${wifiwaninterface}".initial_state="offline"
            fi

			#member
			uci set mwan3.WIFI_WAN_member=member
			uci set mwan3.WIFI_WAN_member.interface="${wifiwaninterface}"
			uci set mwan3.WIFI_WAN_member.metric="$WifiwanPriority"

			#Add weight only when policy is balanced.
			if [ "$policy_type" = "balanced" ]
			then
				uci set mwan3.WIFI_WAN_member.weight="$WifiwanWeight"
			fi

			if [ "$policy_type" = "balanced" ]
			then
				#balanced_v4
				uci add_list mwan3.balanced_v4.use_member="WIFI_WAN_member"
			elif [ "$policy_type" = "failover" ]
			then
				#failover_v4
				uci add_list mwan3.failover_v4.use_member="WIFI_WAN_member"
			fi

		else
			uci delete mwan3.WIFI_WAN_member > /dev/null 2>&1
		fi
	fi
	
	#Cellular
	if [ "$EnableCellular" = "1" ]
	then
		#dualcellularsinglesim
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then
			uci delete mwan3.cwan1sim1_member > /dev/null 2>&1
			uci delete mwan3.cwan1sim2_member > /dev/null 2>&1
			uci delete mwan3.cwan1_member > /dev/null 2>&1
			uci delete mwan3.cwan2_member > /dev/null 2>&1
			uci delete mwan3.cwan6_1_member > /dev/null 2>&1
			uci delete mwan3.cwan6_2_member > /dev/null 2>&1
			
			#CWAN1
			#If pdp1 is ipv4 or ipv4v6
			if [ "$Pdp1" = "1" ]  || [ "$Pdp1" = "3" ]
			then
				uci set mwan3."${cellularwan1interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan1enabled" = "1" ]
				then
					uci set mwan3."${cellularwan1interface}".enabled="1"
				else
					uci set mwan3."${cellularwan1interface}".enabled="0"
				fi

				if [ "$Cwan1Validtrackip" =  "1" ]
				then 
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan1TrackIp1"
				fi
				if [ "$Cwan1Validtrackip" =  "2" ]
				then 
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress2="$Cwan1TrackIp2"
				fi
				if [ "$Cwan1Validtrackip" =  "3" ]
				then 
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp3"
				fi
				if [ "$Cwan1Validtrackip" =  "4" ]
				then 
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp3"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp4"
				fi

				uci set mwan3."${cellularwan1interface}".family="ipv4"
				uci set mwan3."${cellularwan1interface}".reliability="$Cwan1Reliability"
				uci set mwan3."${cellularwan1interface}".count="$Cwan1Count"
				uci set mwan3."${cellularwan1interface}".timeout="2"
				uci set mwan3."${cellularwan1interface}".down="$Cwan1Down"
				uci set mwan3."${cellularwan1interface}".up="$Cwan1Up"
				uci set mwan3."${cellularwan1interface}".track_method="$Cwan1trackmethod"
				uci set mwan3."${cellularwan1interface}".interval="$Cwan1interval"
				uci set mwan3."${cellularwan1interface}".timeout="$Cwan1timeout"
				uci set mwan3."${cellularwan1interface}".check_quality="$Cwan1check_quality"
				if [ "$Cwan1check_quality" =  "1" ]
				then 
					uci set mwan3."${cellularwan1interface}".failure_latency="$Cwan1failure_latency"
					uci set mwan3."${cellularwan1interface}".recovery_latency="$Cwan1recovery_latency"
					uci set mwan3."${cellularwan1interface}".failure_loss="$Cwan1failure_loss"
					uci set mwan3."${cellularwan1interface}".recovery_loss="$Cwan1recovery_loss"
				else
					uci delete mwan3."${cellularwan1interface}".failure_latency
					uci delete mwan3."${cellularwan1interface}".recovery_latency
					uci delete mwan3."${cellularwan1interface}".failure_loss
					uci delete mwan3."${cellularwan1interface}".recovery_loss	
				fi
				
				if [ "$Cwan1flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellularwan1interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellularwan1interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellularwan1interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellularwan1interface}".flush_conntrack="disconnected"
				fi

				#member
				uci set mwan3.cwan1_member=member
				uci set mwan3.cwan1_member.interface="${cellularwan1interface}"
				uci set mwan3.cwan1_member.metric="$Cwan1Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan1_member.weight="$Cwan1Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v4
					uci add_list mwan3.balanced_v4.use_member="cwan1_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v4
					uci add_list mwan3.failover_v4.use_member="cwan1_member"
				fi
				
				########## IPV6 ################
				if [ "$Pdp1" = "3" ]
				then
				
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.balanced_v6=policy
						uci set mwan3.balanced_v6.last_resort='default'				
					elif [ "$policy_type" = "failover" ]
					then
						uci set mwan3.failover_v6=policy
						uci set mwan3.failover_v6.last_resort='default'
					fi
					
					uci set mwan3."${cellular1wan6interface}"=interface
					
					#Check mwan3 enable/disable for individual interfaces
					if [ "$Cwan6_1enabled" = "1" ]
					then
						uci set mwan3."${cellular1wan6interface}".enabled="1"
					else
						uci set mwan3."${cellular1wan6interface}".enabled="0"
					fi

					if [ "$Cwan6_1validtrackip" = "1" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan6_1TrackIp1"
					fi
					if [ "$Cwan6_1validtrackip" = "2" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan6_1TrackIp1"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress2="$Cwan6_1TrackIp2"
					fi
					if [ "$Cwan6_1validtrackip" = "3" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
					fi
					if [ "$Cwan6_1validtrackip" = "4" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp4"
					fi
					uci set mwan3."${cellular1wan6interface}".family="ipv6"
					uci set mwan3."${cellular1wan6interface}".reliability="$Cwan6_1Reliability"
					uci set mwan3."${cellular1wan6interface}".count="$Cwan6_1Count"
					uci set mwan3."${cellular1wan6interface}".timeout="2"
					uci set mwan3."${cellular1wan6interface}".down="$Cwan6_1Down"
					uci set mwan3."${cellular1wan6interface}".up="$Cwan6_1Up"
					uci set mwan3."${cellular1wan6interface}".track_method="$Cwan6_1trackmethod"
					uci set mwan3."${cellular1wan6interface}".interval="$Cwan6_1interval"
					uci set mwan3."${cellular1wan6interface}".timeout="$Cwan6_1timeout"
					uci set mwan3."${cellular1wan6interface}".check_quality="$Cwan6_1check_quality"
					if [ "$Cwan6_1check_quality" =  "1" ]
					then 
						uci set mwan3."${cellular1wan6interface}".failure_latency="$Cwan6_1failure_latency"
						uci set mwan3."${cellular1wan6interface}".recovery_latency="$Cwan6_1recovery_latency"
						uci set mwan3."${cellular1wan6interface}".failure_loss="$Cwan6_1failure_loss"
						uci set mwan3."${cellular1wan6interface}".recovery_loss="$Cwan6_1recovery_loss"
					else
						uci delete mwan3."${cellular1wan6interface}".failure_latency
						uci delete mwan3."${cellular1wan6interface}".recovery_latency
						uci delete mwan3."${cellular1wan6interface}".failure_loss
						uci delete mwan3."${cellular1wan6interface}".recovery_loss	
					fi
					
					if [ "$Cwan6_1flush_conntrack" = "1" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifup"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifdown"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="connected"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="disconnected"
					fi
					
					uci set mwan3.cwan6_1_member=member
					uci set mwan3.cwan6_1_member.interface="${cellular1wan6interface}"
					uci set mwan3.cwan6_1_member.metric="$Cwan6_1Priority"
					
					#Add weight only when policy is balanced.
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.cwan6_1_member.weight="$Cwan6_1Weight"
					fi

					if [ "$policy_type" = "balanced" ]
					then
						#balanced_v6
						uci add_list mwan3.balanced_v6.use_member="cwan6_1_member"
					elif [ "$policy_type" = "failover" ]
					then
						#failover_v6
						uci add_list mwan3.failover_v6.use_member="cwan6_1_member"
					fi
				fi
				################## IPV6 #####################
				
			fi
			
			#If pdp1 is ipv6
			if [ "$Pdp1" = "2" ]
			then
			
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.balanced_v6=policy
					uci set mwan3.balanced_v6.last_resort='default'				
				elif [ "$policy_type" = "failover" ]
				then
					uci set mwan3.failover_v6=policy
					uci set mwan3.failover_v6.last_resort='default'
				fi
				
				uci set mwan3."${cellular1wan6interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan6_1enabled" = "1" ]
				then
					uci set mwan3."${cellular1wan6interface}".enabled="1"
				else
					uci set mwan3."${cellular1wan6interface}".enabled="0"
				fi

				if [ "$Cwan6_1validtrackip" = "1" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan6_1TrackIp1"
				fi
				if [ "$Cwan6_1validtrackip" = "2" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan6_1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress2="$Cwan6_1TrackIp2"
				fi
				if [ "$Cwan6_1validtrackip" = "3" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
				fi
				if [ "$Cwan6_1validtrackip" = "4" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp4"
				fi
				uci set mwan3."${cellular1wan6interface}".family="ipv6"
				uci set mwan3."${cellular1wan6interface}".reliability="$Cwan6_1Reliability"
				uci set mwan3."${cellular1wan6interface}".count="$Cwan6_1Count"
				uci set mwan3."${cellular1wan6interface}".timeout="2"
				uci set mwan3."${cellular1wan6interface}".down="$Cwan6_1Down"
				uci set mwan3."${cellular1wan6interface}".up="$Cwan6_1Up"
                uci set mwan3."${cellular1wan6interface}".track_method="$Cwan6_1trackmethod"
                uci set mwan3."${cellular1wan6interface}".interval="$Cwan6_1interval"
                uci set mwan3."${cellular1wan6interface}".timeout="$Cwan6_1timeout"
				uci set mwan3."${cellular1wan6interface}".check_quality="$Cwan6_1check_quality"
				if [ "$Cwan6_1check_quality" =  "1" ]
				then 
					uci set mwan3."${cellular1wan6interface}".failure_latency="$Cwan6_1failure_latency"
					uci set mwan3."${cellular1wan6interface}".recovery_latency="$Cwan6_1recovery_latency"
					uci set mwan3."${cellular1wan6interface}".failure_loss="$Cwan6_1failure_loss"
					uci set mwan3."${cellular1wan6interface}".recovery_loss="$Cwan6_1recovery_loss"
				else
					uci delete mwan3."${cellular1wan6interface}".failure_latency
					uci delete mwan3."${cellular1wan6interface}".recovery_latency
					uci delete mwan3."${cellular1wan6interface}".failure_loss
					uci delete mwan3."${cellular1wan6interface}".recovery_loss	
				fi
                
                if [ "$Cwan6_1flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="disconnected"
				fi
				
				uci set mwan3.cwan6_1_member=member
				uci set mwan3.cwan6_1_member.interface="${cellular1wan6interface}"
				uci set mwan3.cwan6_1_member.metric="$Cwan6_1Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan6_1_member.weight="$Cwan6_1Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v6
					uci add_list mwan3.balanced_v6.use_member="cwan6_1_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v6
					uci add_list mwan3.failover_v6.use_member="cwan6_1_member"
				fi
			fi 
			
			#CWAN2
			if [ "$sim2pdp" = "1" ]  || [ "$sim2pdp" = "3" ]
			then
				uci set mwan3."${cellularwan2interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan2enabled" = "1" ]
				then
					uci set mwan3."${cellularwan2interface}".enabled="1"
				else
					uci set mwan3."${cellularwan2interface}".enabled="0"
				fi

				if [ "$Cwan2Validtrackip" =  "1" ]
				then 
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress1="$Cwan2TrackIp1"
					
				fi
				if [ "$Cwan2Validtrackip" =  "2" ]
				then 
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp1"
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress1="$Cwan2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress2="$Cwan2TrackIp2"
				fi
				if [ "$Cwan2Validtrackip" =  "3" ]
				then 
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp1"
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp2"
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp3"
				fi
				if [ "$Cwan2Validtrackip" =  "4" ]
				then 
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp1"
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp2"
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp3"
					uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp4"
				fi

				uci set mwan3."${cellularwan2interface}".family="ipv4"
				uci set mwan3."${cellularwan2interface}".reliability="$Cwan2Reliability"
				uci set mwan3."${cellularwan2interface}".count="$Cwan2Count"
				uci set mwan3."${cellularwan2interface}".timeout="2"
				uci set mwan3."${cellularwan2interface}".down="$Cwan2Down"
				uci set mwan3."${cellularwan2interface}".up="$Cwan2Up"
                uci set mwan3."${cellularwan2interface}".track_method="$Cwan2trackmethod"
                uci set mwan3."${cellularwan2interface}".interval="$Cwan2interval"
                uci set mwan3."${cellularwan2interface}".timeout="$Cwan2timeout"
				uci set mwan3."${cellularwan2interface}".check_quality="$Cwan2check_quality"
				if [ "$Cwan2check_quality" =  "1" ]
				then 
					uci set mwan3."${cellularwan2interface}".failure_latency="$Cwan2failure_latency"
					uci set mwan3."${cellularwan2interface}".recovery_latency="$Cwan2recovery_latency"
					uci set mwan3."${cellularwan2interface}".failure_loss="$Cwan2failure_loss"
					uci set mwan3."${cellularwan2interface}".recovery_loss="$Cwan2recovery_loss"
				else
					uci delete mwan3."${cellularwan2interface}".failure_latency
					uci delete mwan3."${cellularwan2interface}".recovery_latency
					uci delete mwan3."${cellularwan2interface}".failure_loss
					uci delete mwan3."${cellularwan2interface}".recovery_loss	
				fi
                
                if [ "$Cwan2flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellularwan2interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellularwan2interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellularwan2interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellularwan2interface}".flush_conntrack="disconnected"
				fi

				#member
				uci set mwan3.cwan2_member=member
				uci set mwan3.cwan2_member.interface="${cellularwan2interface}"
				uci set mwan3.cwan2_member.metric="$Cwan2Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan2_member.weight="$Cwan2Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v4
					uci add_list mwan3.balanced_v4.use_member="cwan2_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v4
					uci add_list mwan3.failover_v4.use_member="cwan2_member"
				fi
				
				########## IPV6 ###############
				if [ "$sim2pdp" = "3" ]
				then
				
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.balanced_v6=policy
						uci set mwan3.balanced_v6.last_resort='default'				
					elif [ "$policy_type" = "failover" ]
					then
						uci set mwan3.failover_v6=policy
						uci set mwan3.failover_v6.last_resort='default'
					fi
					
					uci set mwan3."${cellular2wan6interface}"=interface
					
					#Check mwan3 enable/disable for individual interfaces
					if [ "$Cwan6_2enabled" = "1" ]
					then
						uci set mwan3."${cellular2wan6interface}".enabled="1"
					else
						uci set mwan3."${cellular2wan6interface}".enabled="0"
					fi

					if [ "$Cwan6_2validtrackip" = "1" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress1="$Cwan6_2TrackIp1"
					fi
					if [ "$Cwan6_2validtrackip" = "2" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress1="$Cwan6_2TrackIp1"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress2="$Cwan6_2TrackIp2"
					fi
					if [ "$Cwan6_2validtrackip" = "3" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp3"
					fi
					if [ "$Cwan6_2validtrackip" = "4" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp3"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp4"
					fi
					uci set mwan3."${cellular2wan6interface}".family="ipv6"
					uci set mwan3."${cellular2wan6interface}".reliability="$Cwan6_2Reliability"
					uci set mwan3."${cellular2wan6interface}".count="$Cwan6_2Count"
					uci set mwan3."${cellular2wan6interface}".timeout="2"
					uci set mwan3."${cellular2wan6interface}".down="$Cwan6_2Down"
					uci set mwan3."${cellular2wan6interface}".up="$Cwan6_2Up"
					uci set mwan3."${cellular2wan6interface}".track_method="$Cwan6_2trackmethod"
					uci set mwan3."${cellular2wan6interface}".interval="$Cwan6_2interval"
					uci set mwan3."${cellular2wan6interface}".timeout="$Cwan6_2timeout"
					uci set mwan3."${cellular2wan6interface}".check_quality="$Cwan6_2check_quality"
					if [ "$Cwan6_2check_quality" =  "1" ]
					then 
						uci set mwan3."${cellular2wan6interface}".failure_latency="$Cwan6_2failure_latency"
						uci set mwan3."${cellular2wan6interface}".recovery_latency="$Cwan6_2recovery_latency"
						uci set mwan3."${cellular2wan6interface}".failure_loss="$Cwan6_2failure_loss"
						uci set mwan3."${cellular2wan6interface}".recovery_loss="$Cwan6_2recovery_loss"
					else
						uci delete mwan3."${cellular2wan6interface}".failure_latency
						uci delete mwan3."${cellular2wan6interface}".recovery_latency
						uci delete mwan3."${cellular2wan6interface}".failure_loss
						uci delete mwan3."${cellular2wan6interface}".recovery_loss	
					fi
					
					
					if [ "$Cwan6_2flush_conntrack" = "1" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="ifup"
						uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="ifdown"
						uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="connected"
						uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="disconnected"
					fi
					
					uci set mwan3.cwan6_2_member=member
					uci set mwan3.cwan6_2_member.interface="${cellular2wan6interface}"
					uci set mwan3.cwan6_2_member.metric="$Cwan6_2Priority"
					
					#Add weight only when policy is balanced.
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.cwan6_2_member.weight="$Cwan6_2Weight"
					fi

					if [ "$policy_type" = "balanced" ]
					then
						#balanced_v6
						uci add_list mwan3.balanced_v6.use_member="cwan6_2_member"
					elif [ "$policy_type" = "failover" ]
					then
						#failover_v6
						uci add_list mwan3.failover_v6.use_member="cwan6_2_member"
					fi
				fi
				########## IPV6 ###############
				
			fi
			
			#If pdp2 is ipv6
			if [ "$sim2pdp" = "2" ]
			then
				
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.balanced_v6=policy
					uci set mwan3.balanced_v6.last_resort='default'				
				elif [ "$policy_type" = "failover" ]
				then
					uci set mwan3.failover_v6=policy
					uci set mwan3.failover_v6.last_resort='default'
				fi
				
				uci set mwan3."${cellular2wan6interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan6_2enabled" = "1" ]
				then
					uci set mwan3."${cellular2wan6interface}".enabled="1"
				else
					uci set mwan3."${cellular2wan6interface}".enabled="0"
				fi

				if [ "$Cwan6_2validtrackip" = "1" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress1="$Cwan6_2TrackIp1"
				fi
				if [ "$Cwan6_2validtrackip" = "2" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress1="$Cwan6_2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem2.ipaddress2="$Cwan6_2TrackIp2"
				fi
				if [ "$Cwan6_2validtrackip" = "3" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp3"
				fi
				if [ "$Cwan6_2validtrackip" = "4" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp3"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp4"
				fi
				uci set mwan3."${cellular2wan6interface}".family="ipv6"
				uci set mwan3."${cellular2wan6interface}".reliability="$Cwan6_2Reliability"
				uci set mwan3."${cellular2wan6interface}".count="$Cwan6_2Count"
				uci set mwan3."${cellular2wan6interface}".timeout="2"
				uci set mwan3."${cellular2wan6interface}".down="$Cwan6_2Down"
				uci set mwan3."${cellular2wan6interface}".up="$Cwan6_2Up"
                uci set mwan3."${cellular2wan6interface}".track_method="$Cwan6_2trackmethod"
                uci set mwan3."${cellular2wan6interface}".interval="$Cwan6_2interval"
                uci set mwan3."${cellular2wan6interface}".timeout="$Cwan6_2timeout"
				uci set mwan3."${cellular2wan6interface}".check_quality="$Cwan6_2check_quality"
				if [ "$Cwan6_2check_quality" =  "1" ]
				then 
					uci set mwan3."${cellular2wan6interface}".failure_latency="$Cwan6_2failure_latency"
					uci set mwan3."${cellular2wan6interface}".recovery_latency="$Cwan6_2recovery_latency"
					uci set mwan3."${cellular2wan6interface}".failure_loss="$Cwan6_2failure_loss"
					uci set mwan3."${cellular2wan6interface}".recovery_loss="$Cwan6_2recovery_loss"
				else
					uci delete mwan3."${cellular2wan6interface}".failure_latency
					uci delete mwan3."${cellular2wan6interface}".recovery_latency
					uci delete mwan3."${cellular2wan6interface}".failure_loss
					uci delete mwan3."${cellular2wan6interface}".recovery_loss	
				fi
                
                
                if [ "$Cwan6_2flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="disconnected"
				fi
				
				uci set mwan3.cwan6_2_member=member
				uci set mwan3.cwan6_2_member.interface="${cellular2wan6interface}"
				uci set mwan3.cwan6_2_member.metric="$Cwan6_2Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan6_2_member.weight="$Cwan6_2Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v6
					uci add_list mwan3.balanced_v6.use_member="cwan6_2_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v6
					uci add_list mwan3.failover_v6.use_member="cwan6_2_member"
				fi
			fi 
		
		#singlecellulardualsim
		#One Variable we are using to update the routerapplicationconfig file. 
		#Since sim2 IPaddresses are replaced by sim1 IPaddresses,
		#we have added editing the file routerapplicationconfig in Modem1RouterlocalpingTestApp.sh script itself
		#(So adding ipaddresses to the routerapplicationconfig file is removed in this section).
		elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		
			#Don't delete CWAN1_0 & CWAN1_1 as we did earlier & no need to check if it's CWAN1_0 or CWAN1_1.
			#We need both CWAN1_0 and CWAN1_1 in mwan3 interfaces, else, incase of simswitch utility, 
			#systemstart.sh won't be executed and mwan3 interfaces wont be updated.
			uci delete mwan3.cwan1_member > /dev/null 2>&1
			uci delete mwan3.cwan2_member > /dev/null 2>&1
			uci delete mwan3.cwan6_1_member > /dev/null 2>&1
			uci delete mwan3.cwan6_2_member > /dev/null 2>&1
			
			#CWAN1_0
			#If pdp1 is ipv4 or ipv4v6
			if [ "$Pdp1" = "1" ]  || [ "$Pdp1" = "3" ]
			then

				uci set mwan3."${cellularwan1sim1interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan1sim1enabled" = "1" ]
				then
					uci set mwan3."${cellularwan1sim1interface}".enabled="1"
				else
					uci set mwan3."${cellularwan1sim1interface}".enabled="0"
				fi

				if [ "$Cwan1sim1Validtrackip" =  "1" ]
				then 
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp1"
				fi
				if [ "$Cwan1sim1Validtrackip" =  "2" ]
				then 
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp1"
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp2"
				fi
				if [ "$Cwan1sim1Validtrackip" =  "3" ]
				then 
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp1"
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp2"
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp3"
				fi
				if [ "$Cwan1sim1Validtrackip" =  "4" ]
				then 
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp1"
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp2"
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp3"
					uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp4"
				fi
			
				uci set mwan3."${cellularwan1sim1interface}".family="ipv4"
				uci set mwan3."${cellularwan1sim1interface}".reliability="$Cwan1sim1Reliability"
				uci set mwan3."${cellularwan1sim1interface}".count="$Cwan1sim1Count"
				uci set mwan3."${cellularwan1sim1interface}".timeout="2"
				uci set mwan3."${cellularwan1sim1interface}".down="$Cwan1sim1Down"
				uci set mwan3."${cellularwan1sim1interface}".up="$Cwan1sim1Up"
                uci set mwan3."${cellularwan1sim1interface}".track_method="$Cwan1sim1trackmethod"
                uci set mwan3."${cellularwan1sim1interface}".interval="$Cwan1interval"
                uci set mwan3."${cellularwan1sim1interface}".timeout="$Cwan1timeout"
				uci set mwan3."${cellularwan1sim1interface}".check_quality="$Cwan1check_quality"
				if [ "$Cwan6_2check_quality" =  "1" ]
				then 
					uci set mwan3."${cellularwan1sim1interface}".failure_latency="$Cwan1failure_latency"
					uci set mwan3."${cellularwan1sim1interface}".recovery_latency="$Cwan1recovery_latency"
					uci set mwan3."${cellularwan1sim1interface}".failure_loss="$Cwan1failure_loss"
					uci set mwan3."${cellularwan1sim1interface}".recovery_loss="$Cwan1recovery_loss"
				else
					uci delete mwan3."${cellularwan1sim1interface}".failure_latency
					uci delete mwan3."${cellularwan1sim1interface}".recovery_latency
					uci delete mwan3."${cellularwan1sim1interface}".failure_loss
					uci delete mwan3."${cellularwan1sim1interface}".recovery_loss	
				fi
                		
                if [ "$Cwan1sim1flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellularwan1sim1interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellularwan1sim1interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellularwan1sim1interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellularwan1sim1interface}".flush_conntrack="disconnected"
				fi

				#member
				uci set mwan3.cwan1sim1_member=member
				uci set mwan3.cwan1sim1_member.interface="${cellularwan1sim1interface}"
				uci set mwan3.cwan1sim1_member.metric="$Cwan1sim1Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan1sim1_member.weight="$Cwan1sim1Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v4
					uci add_list mwan3.balanced_v4.use_member="cwan1sim1_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v4
					uci add_list mwan3.failover_v4.use_member="cwan1sim1_member"
				fi
				
				############# IPV6 ################
				if [ "$Pdp1" = "3" ]
				then
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.balanced_v6=policy
						uci set mwan3.balanced_v6.last_resort='default'				
					elif [ "$policy_type" = "failover" ]
					then
						uci set mwan3.failover_v6=policy
						uci set mwan3.failover_v6.last_resort='default'
					fi
					
					uci set mwan3."${cellular1wan6interface}"=interface
					
					#Check mwan3 enable/disable for individual interfaces
					if [ "$Cwan6_1enabled" = "1" ]
					then
						uci set mwan3."${cellular1wan6interface}".enabled="1"
					else
						uci set mwan3."${cellular1wan6interface}".enabled="0"
					fi
					
					if [ "$Cwan6_1validtrackip" = "1" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					fi
					if [ "$Cwan6_1validtrackip" = "2" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					fi
					if [ "$Cwan6_1validtrackip" = "3" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
					fi
					if [ "$Cwan6_1validtrackip" = "4" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp4"
					fi
					uci set mwan3."${cellular1wan6interface}".family="ipv6"
					uci set mwan3."${cellular1wan6interface}".reliability="$Cwan6_1Reliability"
					uci set mwan3."${cellular1wan6interface}".count="$Cwan6_1Count"
					uci set mwan3."${cellular1wan6interface}".timeout="2"
					uci set mwan3."${cellular1wan6interface}".down="$Cwan6_1Down"
					uci set mwan3."${cellular1wan6interface}".up="$Cwan6_1Up"
					uci set mwan3."${cellular1wan6interface}".track_method="$Cwan6_1trackmethod"
					uci set mwan3."${cellular1wan6interface}".interval="$Cwan6_1interval"
					uci set mwan3."${cellular1wan6interface}".timeout="$Cwan6_1timeout"
					uci set mwan3."${cellular1wan6interface}".check_quality="$Cwan6_1check_quality"
					if [ "$Cwan6_1check_quality" =  "1" ]
					then 
						uci set mwan3."${cellular1wan6interface}".failure_latency="$Cwan6_1failure_latency"
						uci set mwan3."${cellular1wan6interface}".recovery_latency="$Cwan6_1recovery_latency"
						uci set mwan3."${cellular1wan6interface}".failure_loss="$Cwan6_1failure_loss"
						uci set mwan3."${cellular1wan6interface}".recovery_loss="$Cwan6_1recovery_loss"
					else
						uci delete mwan3."${cellular1wan6interface}".failure_latency
						uci delete mwan3."${cellular1wan6interface}".recovery_latency
						uci delete mwan3."${cellular1wan6interface}".failure_loss
						uci delete mwan3."${cellular1wan6interface}".recovery_loss	
					fi
							
					if [ "$Cwan6_1flush_conntrack" = "1" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifup"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifdown"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="connected"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="disconnected"
					fi
					
					uci set mwan3.cwan6_1_member=member
					uci set mwan3.cwan6_1_member.interface="${cellular1wan6interface}"
					uci set mwan3.cwan6_1_member.metric="$Cwan6_1Priority"
					
					#Add weight only when policy is balanced.
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.cwan6_1_member.weight="$Cwan6_1Weight"
					fi

					if [ "$policy_type" = "balanced" ]
					then
						#balanced_v6
						uci add_list mwan3.balanced_v6.use_member="cwan6_1_member"
					elif [ "$policy_type" = "failover" ]
					then
						#failover_v6
						uci add_list mwan3.failover_v6.use_member="cwan6_1_member"
					fi
				fi
				############# IPV6 #################
			fi
			
			#If pdp1 is ipv6
			if [ "$Pdp1" = "2" ]
			then
				
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.balanced_v6=policy
					uci set mwan3.balanced_v6.last_resort='default'				
				elif [ "$policy_type" = "failover" ]
				then
					uci set mwan3.failover_v6=policy
					uci set mwan3.failover_v6.last_resort='default'
				fi
				
				uci set mwan3."${cellular1wan6interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan6_1enabled" = "1" ]
				then
					uci set mwan3."${cellular1wan6interface}".enabled="1"
				else
					uci set mwan3."${cellular1wan6interface}".enabled="0"
				fi
				
				if [ "$Cwan6_1validtrackip" = "1" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
				fi
				if [ "$Cwan6_1validtrackip" = "2" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
				fi
				if [ "$Cwan6_1validtrackip" = "3" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
				fi
				if [ "$Cwan6_1validtrackip" = "4" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp4"
				fi
				uci set mwan3."${cellular1wan6interface}".family="ipv6"
				uci set mwan3."${cellular1wan6interface}".reliability="$Cwan6_1Reliability"
				uci set mwan3."${cellular1wan6interface}".count="$Cwan6_1Count"
				uci set mwan3."${cellular1wan6interface}".timeout="2"
				uci set mwan3."${cellular1wan6interface}".down="$Cwan6_1Down"
				uci set mwan3."${cellular1wan6interface}".up="$Cwan6_1Up"
                uci set mwan3."${cellular1wan6interface}".track_method="$Cwan6_1trackmethod"
                uci set mwan3."${cellular1wan6interface}".interval="$Cwan6_1interval"
                uci set mwan3."${cellular1wan6interface}".timeout="$Cwan6_1timeout"
				uci set mwan3."${cellular1wan6interface}".check_quality="$Cwan6_1check_quality"
				if [ "$Cwan6_1check_quality" =  "1" ]
				then 
					uci set mwan3."${cellular1wan6interface}".failure_latency="$Cwan6_1failure_latency"
					uci set mwan3."${cellular1wan6interface}".recovery_latency="$Cwan6_1recovery_latency"
					uci set mwan3."${cellular1wan6interface}".failure_loss="$Cwan6_1failure_loss"
					uci set mwan3."${cellular1wan6interface}".recovery_loss="$Cwan6_1recovery_loss"
				else
					uci delete mwan3."${cellular1wan6interface}".failure_latency
					uci delete mwan3."${cellular1wan6interface}".recovery_latency
					uci delete mwan3."${cellular1wan6interface}".failure_loss
					uci delete mwan3."${cellular1wan6interface}".recovery_loss	
				fi
                		
                if [ "$Cwan6_1flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="disconnected"
				fi
				
				uci set mwan3.cwan6_1_member=member
				uci set mwan3.cwan6_1_member.interface="${cellular1wan6interface}"
				uci set mwan3.cwan6_1_member.metric="$Cwan6_1Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan6_1_member.weight="$Cwan6_1Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v6
					uci add_list mwan3.balanced_v6.use_member="cwan6_1_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v6
					uci add_list mwan3.failover_v6.use_member="cwan6_1_member"
				fi
			fi 

			#CWAN1_1
			#If pdp2 is ipv4 or ipv4v6
			if [ "$sim2pdp" = "1" ]  || [ "$sim2pdp" = "3" ]
			then
				uci set mwan3."${cellularwan1sim2interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan1sim2enabled" = "1" ]
				then
					uci set mwan3."${cellularwan1sim2interface}".enabled="1"
				else
					uci set mwan3."${cellularwan1sim2interface}".enabled="0"
				fi
				
				if [ "$Cwan1sim2Validtrackip" =  "1" ]
				then 
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp1"
				fi
				if [ "$Cwan1sim2Validtrackip" =  "2" ]
				then 
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp1"
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp2"
				fi
				if [ "$Cwan1sim2Validtrackip" =  "3" ]
				then 
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp1"
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp2"
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp3"
				fi
				if [ "$Cwan1sim2Validtrackip" =  "4" ]
				then 
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp1"
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp2"
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp3"
					uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp4"
				fi

				uci set mwan3."${cellularwan1sim2interface}".family="ipv4"
				uci set mwan3."${cellularwan1sim2interface}".reliability="$Cwan1sim2Reliability"
				uci set mwan3."${cellularwan1sim2interface}".count="$Cwan1sim2Count"
				uci set mwan3."${cellularwan1sim2interface}".timeout="2"
				uci set mwan3."${cellularwan1sim2interface}".down="$Cwan1sim2Down"
				uci set mwan3."${cellularwan1sim2interface}".up="$Cwan1sim2Up"
                uci set mwan3."${cellularwan1sim2interface}".track_method="$Cwan1sim2trackmethod"
                uci set mwan3."${cellularwan1sim2interface}".interval="$Cwan1sim2interval"
                uci set mwan3."${cellularwan1sim2interface}".timeout="$Cwan1sim2timeout"
				uci set mwan3."${cellularwan1sim2interface}".check_quality="$Cwan1sim2check_quality"
				if [ "$Cwan1sim2check_quality" =  "1" ]
				then 
					uci set mwan3."${cellularwan1sim2interface}".failure_latency="$Cwan1sim2failure_latency"
					uci set mwan3."${cellularwan1sim2interface}".recovery_latency="$Cwan1sim2recovery_latency"
					uci set mwan3."${cellularwan1sim2interface}".failure_loss="$Cwan1sim2failure_loss"
					uci set mwan3."${cellularwan1sim2interface}".recovery_loss="$Cwan1sim2recovery_loss"
				else
					uci delete mwan3."${cellularwan1sim2interface}".failure_latency
					uci delete mwan3."${cellularwan1sim2interface}".recovery_latency
					uci delete mwan3."${cellularwan1sim2interface}".failure_loss
					uci delete mwan3."${cellularwan1sim2interface}".recovery_loss	
				fi
                		
                if [ "$Cwan1sim2flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellularwan1sim2interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellularwan1sim2interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellularwan1sim2interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellularwan1sim2interface}".flush_conntrack="disconnected"
				fi

				#member
				uci set mwan3.cwan1sim2_member=member
				uci set mwan3.cwan1sim2_member.interface="${cellularwan1sim2interface}"
				uci set mwan3.cwan1sim2_member.metric="$Cwan1sim2Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan1sim2_member.weight="$Cwan1sim2Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v4
					uci add_list mwan3.balanced_v4.use_member="cwan1sim2_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v4
					uci add_list mwan3.failover_v4.use_member="cwan1sim2_member"
				fi		
				
				################## IPV6 #####################
				if [ "$sim2pdp" = "3" ]
				then
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.balanced_v6=policy
						uci set mwan3.balanced_v6.last_resort='default'				
					elif [ "$policy_type" = "failover" ]
					then
						uci set mwan3.failover_v6=policy
						uci set mwan3.failover_v6.last_resort='default'
					fi
					
					uci set mwan3."${cellular2wan6interface}"=interface
					
					#Check mwan3 enable/disable for individual interfaces
					if [ "$Cwan6_2enabled" = "1" ]
					then
						uci set mwan3."${cellular2wan6interface}".enabled="1"
					else
						uci set mwan3."${cellular2wan6interface}".enabled="0"
					fi
					
					if [ "$Cwan6_2validtrackip" = "1" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
					fi
					if [ "$Cwan6_2validtrackip" = "2" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
					fi
					if [ "$Cwan6_2validtrackip" = "3" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp3"
					fi
					if [ "$Cwan6_2validtrackip" = "4" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp3"
						uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp4"
					fi
					uci set mwan3."${cellular2wan6interface}".family="ipv6"
					uci set mwan3."${cellular2wan6interface}".reliability="$Cwan6_2Reliability"
					uci set mwan3."${cellular2wan6interface}".count="$Cwan6_2Count"
					uci set mwan3."${cellular2wan6interface}".timeout="2"
					uci set mwan3."${cellular2wan6interface}".down="$Cwan6_2Down"
					uci set mwan3."${cellular2wan6interface}".up="$Cwan6_2Up"
					uci set mwan3."${cellular2wan6interface}".track_method="$Cwan6_2trackmethod"
					uci set mwan3."${cellular2wan6interface}".interval="$Cwan6_2interval"
					uci set mwan3."${cellular2wan6interface}".timeout="$Cwan1sim2timeout"
					uci set mwan3."${cellular2wan6interface}".check_quality="$Cwan1sim2check_quality"
					if [ "$Cwan6_2check_quality" =  "1" ]
					then 
						uci set mwan3."${cellular2wan6interface}".failure_latency="$Cwan6_2failure_latency"
						uci set mwan3."${cellular2wan6interface}".recovery_latency="$Cwan6_2recovery_latency"
						uci set mwan3."${cellular2wan6interface}".failure_loss="$Cwan6_2failure_loss"
						uci set mwan3."${cellular2wan6interface}".recovery_loss="$Cwan6_2recovery_loss"
					else
						uci delete mwan3."${cellular2wan6interface}".failure_latency
						uci delete mwan3."${cellular2wan6interface}".recovery_latency
						uci delete mwan3."${cellular2wan6interface}".failure_loss
						uci delete mwan3."${cellular2wan6interface}".recovery_loss	
					fi
							
					if [ "$Cwan6_2flush_conntrack" = "1" ]
					then
						uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="ifup"
						uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="ifdown"
						uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="connected"
						uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="disconnected"
					fi
					
					uci set mwan3.cwan6_2_member=member
					uci set mwan3.cwan6_2_member.interface="${cellular2wan6interface}"
					uci set mwan3.cwan6_2_member.metric="$Cwan6_2Priority"
					
					#Add weight only when policy is balanced.
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.cwan6_2_member.weight="$Cwan6_2Weight"
					fi

					if [ "$policy_type" = "balanced" ]
					then
						#balanced_v6
						uci add_list mwan3.balanced_v6.use_member="cwan6_2_member"
					elif [ "$policy_type" = "failover" ]
					then
						#failover_v6
						uci add_list mwan3.failover_v6.use_member="cwan6_2_member"
					fi
				fi		
				################ IPV6 #####################		
			fi
			
			#If pdp2 is ipv6
			if [ "$sim2pdp" = "2" ]
			then
				
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.balanced_v6=policy
					uci set mwan3.balanced_v6.last_resort='default'				
				elif [ "$policy_type" = "failover" ]
				then
					uci set mwan3.failover_v6=policy
					uci set mwan3.failover_v6.last_resort='default'
				fi
				
				uci set mwan3."${cellular2wan6interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan6_2enabled" = "1" ]
				then
					uci set mwan3."${cellular2wan6interface}".enabled="1"
				else
					uci set mwan3."${cellular2wan6interface}".enabled="0"
				fi
				
				if [ "$Cwan6_2validtrackip" = "1" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
				fi
				if [ "$Cwan6_2validtrackip" = "2" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
				fi
				if [ "$Cwan6_2validtrackip" = "3" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp3"
				fi
				if [ "$Cwan6_2validtrackip" = "4" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp1"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp2"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp3"
					uci add_list mwan3."${cellular2wan6interface}".track_ip="$Cwan6_2TrackIp4"
				fi
				uci set mwan3."${cellular2wan6interface}".family="ipv6"
				uci set mwan3."${cellular2wan6interface}".reliability="$Cwan6_2Reliability"
				uci set mwan3."${cellular2wan6interface}".count="$Cwan6_2Count"
				uci set mwan3."${cellular2wan6interface}".timeout="2"
				uci set mwan3."${cellular2wan6interface}".down="$Cwan6_2Down"
				uci set mwan3."${cellular2wan6interface}".up="$Cwan6_2Up"
                uci set mwan3."${cellular2wan6interface}".track_method="$Cwan6_2trackmethod"
                uci set mwan3."${cellular2wan6interface}".interval="$Cwan6_2interval"
                uci set mwan3."${cellular2wan6interface}".timeout="$Cwan6_2timeout"
				uci set mwan3."${cellular2wan6interface}".check_quality="$Cwan6_2check_quality"
				if [ "$Cwan6_2check_quality" =  "1" ]
				then 
					uci set mwan3."${cellular2wan6interface}".failure_latency="$Cwan6_2failure_latency"
					uci set mwan3."${cellular2wan6interface}".recovery_latency="$Cwan6_2recovery_latency"
					uci set mwan3."${cellular2wan6interface}".failure_loss="$Cwan6_2failure_loss"
					uci set mwan3."${cellular2wan6interface}".recovery_loss="$Cwan6_2recovery_loss"
				else
					uci delete mwan3."${cellular2wan6interface}".failure_latency
					uci delete mwan3."${cellular2wan6interface}".recovery_latency
					uci delete mwan3."${cellular2wan6interface}".failure_loss
					uci delete mwan3."${cellular2wan6interface}".recovery_loss	
				fi
                		
                if [ "$Cwan6_2flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellular2wan6interface}".flush_conntrack="disconnected"
				fi
				
				uci set mwan3.cwan6_2_member=member
				uci set mwan3.cwan6_2_member.interface="${cellular2wan6interface}"
				uci set mwan3.cwan6_2_member.metric="$Cwan6_2Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan6_2_member.weight="$Cwan6_2Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v6
					uci add_list mwan3.balanced_v6.use_member="cwan6_2_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v6
					uci add_list mwan3.failover_v6.use_member="cwan6_2_member"
				fi
			fi 
		
		#singlecellularsinglesim
		else
			uci delete mwan3.cwan1_member > /dev/null 2>&1
			uci delete mwan3.cwan6_1_member > /dev/null 2>&1
			uci delete mwan3.cwan6_2_member > /dev/null 2>&1
			
			#CWAN1
			#If pdp1 is ipv4 or ipv4v6
			if [ "$Pdp1" = "1" ]  || [ "$Pdp1" = "3" ]
			then
				uci set mwan3."${cellularwan1interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan1enabled" = "1" ]
				then
					uci set mwan3."${cellularwan1interface}".enabled="1"
				else
					uci set mwan3."${cellularwan1interface}".enabled="0"
				fi

				if [ "$Cwan1Validtrackip" =  "1" ]
				then 
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan1TrackIp1"
				fi
				if [ "$Cwan1Validtrackip" =  "2" ]
				then 
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress2="$Cwan1TrackIp2"
				fi
				if [ "$Cwan1Validtrackip" =  "3" ]
				then 
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp3"
				fi
				if [ "$Cwan1Validtrackip" =  "4" ]
				then 
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp3"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp4"
				fi

				uci set mwan3."${cellularwan1interface}".family="ipv4"
				uci set mwan3."${cellularwan1interface}".reliability="$Cwan1Reliability"
				uci set mwan3."${cellularwan1interface}".count="$Cwan1Count"
				uci set mwan3."${cellularwan1interface}".timeout="2"
				uci set mwan3."${cellularwan1interface}".down="$Cwan1Down"
				uci set mwan3."${cellularwan1interface}".up="$Cwan1Up"
               	uci set mwan3."${cellularwan1interface}".track_method="$Cwan1trackmethod"
               	uci set mwan3."${cellularwan1interface}".interval="$Cwan1interval"
               	uci set mwan3."${cellularwan1interface}".timeout="$Cwan1timeout"
				uci set mwan3."${cellularwan1interface}".check_quality="$Cwan1check_quality"
				if [ "$Cwan1check_quality" =  "1" ]
				then 
					uci set mwan3."${cellularwan1interface}".failure_latency="$Cwan1failure_latency"
					uci set mwan3."${cellularwan1interface}".recovery_latency="$Cwan1recovery_latency"
					uci set mwan3."${cellularwan1interface}".failure_loss="$Cwan1failure_loss"
					uci set mwan3."${cellularwan1interface}".recovery_loss="$Cwan1recovery_loss"
				else
					uci delete mwan3."${cellularwan1interface}".failure_latency
					uci delete mwan3."${cellularwan1interface}".recovery_latency
					uci delete mwan3."${cellularwan1interface}".failure_loss
					uci delete mwan3."${cellularwan1interface}".recovery_loss	
				fi
               			
               	if [ "$Cwan1flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellularwan1interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellularwan1interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellularwan1interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellularwan1interface}".flush_conntrack="disconnected"
				fi

				#member
				uci set mwan3.cwan1_member=member
				uci set mwan3.cwan1_member.interface="${cellularwan1interface}"
				uci set mwan3.cwan1_member.metric="$Cwan1Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan1_member.weight="$Cwan1Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v4
					uci add_list mwan3.balanced_v4.use_member="cwan1_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v4
					uci add_list mwan3.failover_v4.use_member="cwan1_member"
				fi
				
				############# IPV6 ########################
				if [ "$Pdp1" = "3" ]
				then
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.balanced_v6=policy
						uci set mwan3.balanced_v6.last_resort='default'				
					elif [ "$policy_type" = "failover" ]
					then
						uci set mwan3.failover_v6=policy
						uci set mwan3.failover_v6.last_resort='default'
					fi
					
					uci set mwan3."${cellular1wan6interface}"=interface
					
					#Check mwan3 enable/disable for individual interfaces
					if [ "$Cwan6_1enabled" = "1" ]
					then
						uci set mwan3."${cellular1wan6interface}".enabled="1"
					else
						uci set mwan3."${cellular1wan6interface}".enabled="0"
					fi
					
					if [ "$Cwan6_1validtrackip" = "1" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan6_1TrackIp1"
					fi
					if [ "$Cwan6_1validtrackip" = "2" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan6_1TrackIp1"
						uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress2="$Cwan6_1TrackIp2"
					fi
					if [ "$Cwan6_1validtrackip" = "3" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
					fi
					if [ "$Cwan6_1validtrackip" = "4" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
						uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp4"
					fi
					uci set mwan3."${cellular1wan6interface}".family="ipv6"
					uci set mwan3."${cellular1wan6interface}".reliability="$Cwan6_1Reliability"
					uci set mwan3."${cellular1wan6interface}".count="$Cwan6_1Count"
					uci set mwan3."${cellular1wan6interface}".timeout="2"
					uci set mwan3."${cellular1wan6interface}".down="$Cwan6_1Down"
					uci set mwan3."${cellular1wan6interface}".up="$Cwan6_1Up"
					uci set mwan3."${cellular1wan6interface}".track_method="$Cwan6_1trackmethod"
					uci set mwan3."${cellular1wan6interface}".interval="$Cwan6_1interval"
					uci set mwan3."${cellular1wan6interface}".timeout="$Cwan6_1timeout"
					uci set mwan3."${cellular1wan6interface}".check_quality="$Cwan6_1check_quality"
					if [ "$Cwan6_1check_quality" =  "1" ]
					then 
						uci set mwan3."${cellular1wan6interface}".failure_latency="$Cwan6_1failure_latency"
						uci set mwan3."${cellular1wan6interface}".recovery_latency="$Cwan6_1recovery_latency"
						uci set mwan3."${cellular1wan6interface}".failure_loss="$Cwan6_1failure_loss"
						uci set mwan3."${cellular1wan6interface}".recovery_loss="$Cwan6_1recovery_loss"
					else
						uci delete mwan3."${cellular1wan6interface}".failure_latency
						uci delete mwan3."${cellular1wan6interface}".recovery_latency
						uci delete mwan3."${cellular1wan6interface}".failure_loss
						uci delete mwan3."${cellular1wan6interface}".recovery_loss	
					fi
					
					if [ "$Cwan6_1flush_conntrack" = "1" ]
					then
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifup"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifdown"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="connected"
						uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="disconnected"
					fi
					
					uci set mwan3.cwan6_1_member=member
					uci set mwan3.cwan6_1_member.interface="${cellular1wan6interface}"
					uci set mwan3.cwan6_1_member.metric="$Cwan6_1Priority"
					
					#Add weight only when policy is balanced.
					if [ "$policy_type" = "balanced" ]
					then
						uci set mwan3.cwan6_1_member.weight="$Cwan6_1Weight"
					fi

					if [ "$policy_type" = "balanced" ]
					then
						#balanced_v6
						uci add_list mwan3.balanced_v6.use_member="cwan6_1_member"
					elif [ "$policy_type" = "failover" ]
					then
						#failover_v6
						uci add_list mwan3.failover_v6.use_member="cwan6_1_member"
					fi
				fi
				############## IPV6 ###################
			fi
			
			#If pdp1 is ipv6
			if [ "$Pdp1" = "2" ]
			then
				
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.balanced_v6=policy
					uci set mwan3.balanced_v6.last_resort='default'				
				elif [ "$policy_type" = "failover" ]
				then
					uci set mwan3.failover_v6=policy
					uci set mwan3.failover_v6.last_resort='default'
				fi
				
				uci set mwan3."${cellular1wan6interface}"=interface
				
				#Check mwan3 enable/disable for individual interfaces
				if [ "$Cwan6_1enabled" = "1" ]
				then
					uci set mwan3."${cellular1wan6interface}".enabled="1"
				else
					uci set mwan3."${cellular1wan6interface}".enabled="0"
				fi
				
				if [ "$Cwan6_1validtrackip" = "1" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan6_1TrackIp1"
				fi
				if [ "$Cwan6_1validtrackip" = "2" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress1="$Cwan6_1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfigModem1.ipaddress2="$Cwan6_1TrackIp2"
				fi
				if [ "$Cwan6_1validtrackip" = "3" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
				fi
				if [ "$Cwan6_1validtrackip" = "4" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp1"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp2"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp3"
					uci add_list mwan3."${cellular1wan6interface}".track_ip="$Cwan6_1TrackIp4"
				fi
				uci set mwan3."${cellular1wan6interface}".family="ipv6"
				uci set mwan3."${cellular1wan6interface}".reliability="$Cwan6_1Reliability"
				uci set mwan3."${cellular1wan6interface}".count="$Cwan6_1Count"
				uci set mwan3."${cellular1wan6interface}".timeout="2"
				uci set mwan3."${cellular1wan6interface}".down="$Cwan6_1Down"
				uci set mwan3."${cellular1wan6interface}".up="$Cwan6_1Up"
                uci set mwan3."${cellular1wan6interface}".track_method="$Cwan6_1trackmethod"
                uci set mwan3."${cellular1wan6interface}".interval="$Cwan6_1interval"
                uci set mwan3."${cellular1wan6interface}".timeout="$Cwan6_1timeout"
				uci set mwan3."${cellular1wan6interface}".check_quality="$Cwan6_1check_quality"
				if [ "$Cwan6_1check_quality" =  "1" ]
				then 
					uci set mwan3."${cellular1wan6interface}".failure_latency="$Cwan6_1failure_latency"
					uci set mwan3."${cellular1wan6interface}".recovery_latency="$Cwan6_1recovery_latency"
					uci set mwan3."${cellular1wan6interface}".failure_loss="$Cwan6_1failure_loss"
					uci set mwan3."${cellular1wan6interface}".recovery_loss="$Cwan6_1recovery_loss"
				else
					uci delete mwan3."${cellular1wan6interface}".failure_latency
					uci delete mwan3."${cellular1wan6interface}".recovery_latency
					uci delete mwan3."${cellular1wan6interface}".failure_loss
					uci delete mwan3."${cellular1wan6interface}".recovery_loss	
				fi
                
                if [ "$Cwan6_1flush_conntrack" = "1" ]
				then
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifup"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="ifdown"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="connected"
					uci add_list mwan3."${cellular1wan6interface}".flush_conntrack="disconnected"
				fi
				
				uci set mwan3.cwan6_1_member=member
				uci set mwan3.cwan6_1_member.interface="${cellular1wan6interface}"
				uci set mwan3.cwan6_1_member.metric="$Cwan6_1Priority"
				
				#Add weight only when policy is balanced.
				if [ "$policy_type" = "balanced" ]
				then
					uci set mwan3.cwan6_1_member.weight="$Cwan6_1Weight"
				fi

				if [ "$policy_type" = "balanced" ]
				then
					#balanced_v6
					uci add_list mwan3.balanced_v6.use_member="cwan6_1_member"
				elif [ "$policy_type" = "failover" ]
				then
					#failover_v6
					uci add_list mwan3.failover_v6.use_member="cwan6_1_member"
				fi
			fi			
		fi
	
	#If EnableCellular is 0.
	else
		uci delete mwan3.cwan1sim1_member > /dev/null 2>&1
		uci delete mwan3.cwan1sim2_member > /dev/null 2>&1
		uci delete mwan3.cwan1_member > /dev/null 2>&1
		uci delete mwan3.cwan2_member > /dev/null 2>&1
		uci delete mwan3.cwan6_1_member > /dev/null 2>&1
		uci delete mwan3.cwan6_2_member > /dev/null 2>&1
		uci delete mwan3."${cellularwan1interface}"
		uci delete mwan3."${cellularwan1sim1interface}"
		uci delete mwan3."${cellularwan1sim2interface}"
		uci delete mwan3."${cellularwan2interface}"
		uci delete mwan3."${cellular1wan6interface}"
		uci delete mwan3."${cellular2wan6interface}"
	fi
	uci commit mwan3
	uci commit routerapplicationconfig	
}

UpdateMwanConfig()
{
	read_interface="$1"
	
	if [ "$read_interface" != "CWAN1" ] && [ "$read_interface" != "CWAN2" ] && [ "$read_interface" != "CWAN1_0" ] && [ "$read_interface" != "CWAN1_1" ] && [ "$read_interface" != "WIFI_WAN" ] && [ "$read_interface" != "wan6c1" ] && [ "$read_interface" != "wan6c2" ]
	then
		config_get name "$read_interface" name
		config_get wanpriority "$read_interface" wanpriority
		config_get wanweight "$read_interface" wanweight
		config_get enabled "$read_interface" enabled
	    config_get wantrackmethod "$read_interface" track_method
		config_get trackIp1 "$read_interface" trackIp1
		config_get trackIp2 "$read_interface" trackIp2
		config_get trackIp3 "$read_interface" trackIp3
		config_get trackIp4 "$read_interface" trackIp4
		config_get reliability "$read_interface" reliability 
		config_get count "$read_interface" count
		config_get up "$read_interface" up
		config_get down "$read_interface" down
		config_get validtrackip "$read_interface" validtrackip
		config_get flush_conntrack "$read_interface" flush_conntrack
		config_get initial_state "$read_interface" initial_state
		config_get interval "$read_interface" interval
		config_get timeout "$read_interface" timeout
		config_get check_quality "$read_interface" check_quality
		config_get failure_latency "$read_interface" failure_latency
		config_get recovery_latency "$read_interface" recovery_latency
		config_get failure_loss "$read_interface" failure_loss
		config_get recovery_loss "$read_interface" recovery_loss
		
		#Add weight only when policy is balanced.
		if [ "$policy_type" = "balanced" ]
		then
			uci set mwan3.balanced_v4=policy
			uci set mwan3.balanced_v4.last_resort='default'
			#change default_rule as well
			uci set mwan3.default_rule_v4.use_policy='balanced_v4'
			uci set mwan3.default_rule_v6.use_policy='balanced_v6'
		elif [ "$policy_type" = "failover" ]
		then
			#Now create all depending on the user input.
			uci set mwan3.failover_v4=policy
			uci set mwan3.failover_v4.last_resort='default'
			#change default_rule as well
			uci set mwan3.default_rule_v4.use_policy='failover_v4'
			uci set mwan3.default_rule_v6.use_policy='failover_v6'
		fi
		
		uci set mwan3."${name}"=interface
		
		#Check mwan3 enable/disable for individual interfaces
		if [ "$enabled" = "1" ]
		then
			uci set mwan3."${name}".enabled="1"
		else
			uci set mwan3."${name}".enabled="0"
		fi
		
		#Check for validtrackip.
		if [ "$validtrackip" =  "1" ]
		then 
			uci add_list mwan3."${name}".track_ip="$trackIp1"
		fi
		if [ "$validtrackip" =  "2" ]
		then 
			uci add_list mwan3."${name}".track_ip="$trackIp1"
			uci add_list mwan3."${name}".track_ip="$trackIp2"
		fi
		if [ "$validtrackip" =  "3" ]
		then 
			uci add_list mwan3."${name}".track_ip="$trackIp1"
			uci add_list mwan3."${name}".track_ip="$trackIp2"
			uci add_list mwan3."${name}".track_ip="$trackIp3"
		fi
		if [ "$validtrackip" =  "4" ]
		then 
			uci add_list mwan3."${name}".track_ip="$trackIp1"
			uci add_list mwan3."${name}".track_ip="$trackIp2"
			uci add_list mwan3."${name}".track_ip="$trackIp3"
			uci add_list mwan3."${name}".track_ip="$trackIp4"
		fi
		
		uci set mwan3."${name}".family="ipv4"
		uci set mwan3."${name}".reliability="$reliability"
		uci set mwan3."${name}".count="$count"
		uci set mwan3."${name}".timeout="2"
		uci set mwan3."${name}".down="$down"
		uci set mwan3."${name}".up="$up"
		uci set mwan3."${name}".track_method="$wantrackmethod"
		uci set mwan3."${name}".interval="$interval"
		uci set mwan3."${name}".timeout="$timeout"
		uci set mwan3."${name}".check_quality="$check_quality"
		if [ "$check_quality" =  "1" ]
		then 
			uci set mwan3."${name}".failure_latency="$failure_latency"
			uci set mwan3."${name}".recovery_latency="$recovery_latency"
			uci set mwan3."${name}".failure_loss="$failure_loss"
			uci set mwan3."${name}".recovery_loss="$recovery_loss"
		else
			uci delete mwan3."${name}".failure_latency
			uci delete mwan3."${name}".recovery_latency
			uci delete mwan3."${name}".failure_loss
			uci delete mwan3."${name}".recovery_loss	
		fi
       	
		if [ "$flush_conntrack" = "1" ]
		then
			uci add_list mwan3."${name}".flush_conntrack="ifup"
			uci add_list mwan3."${name}".flush_conntrack="ifdown"
			uci add_list mwan3."${name}".flush_conntrack="connected"
			uci add_list mwan3."${name}".flush_conntrack="disconnected"
		fi
		
		if [ "$initial_state" = "1" ]
		then
			uci set mwan3."${name}".initial_state="offline"
		fi
		
		#member
		uci set mwan3.${name}_member=member
		uci set mwan3.${name}_member.interface="${name}"
		
		#Add weight only when policy is balanced.
		if [ "$policy_type" = "balanced" ]
		then
			uci set mwan3.${name}_member.metric="1"
			uci set mwan3.${name}_member.weight="$wanweight"
		else
			uci set mwan3.${name}_member.metric="$wanpriority"
		fi
		
		if [ "$policy_type" = "balanced" ]
		then
			#balanced_v4
			uci add_list mwan3.balanced_v4.use_member="${name}_member"
		elif [ "$policy_type" = "failover" ]
		then
			#failover_v4
			uci add_list mwan3.failover_v4.use_member="${name}_member"
		fi
	
	fi
	
	uci commit mwan3
	
	#For Eth, update the metric to network file as well. This is required for static.
	metric_value=$(uci get mwan3.${name}_member.metric)
	uci set network."${name}".metric="$metric_value"
	uci commit network
	ubus call network reload
}

UpdateCellular_WIFI_ModemConfig()
{
	
	#failover/balanced policy for mwan3.
	policy_type=$(uci get mwan3config.general.select)
	
	Cwan1Priority=$(uci get mwan3config."${cellularwan1interface}".wanpriority)
	Cwan2Priority=$(uci get mwan3config."${cellularwan2interface}".wanpriority)
	Cwan1sim1Priority=$(uci get mwan3config."${cellularwan1sim1interface}".wanpriority)
	Cwan1sim2Priority=$(uci get mwan3config."${cellularwan1sim2interface}".wanpriority)
	
	WifiwanPriority=$(uci get mwan3config."${wifiwaninterface}".wanpriority)
	
	#CELLULAR
	if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
	then	
		if [ "$policy_type" = "balanced" ]
		then
			uci set modem."${cellularwan1interface}".metric="1"
			uci set modem."${cellularwan2interface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set modem."${cellularwan1interface}".metric="$Cwan1Priority"
			uci set modem."${cellularwan2interface}".metric="$Cwan2Priority"
		fi		
	elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
    then  	
		if [ "$policy_type" = "balanced" ]
		then
			uci set modem."${cellularwan1sim1interface}".metric="1"
			uci set modem."${cellularwan1sim2interface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set modem."${cellularwan1sim1interface}".metric="$Cwan1sim1Priority"
			uci set modem."${cellularwan1sim2interface}".metric="$Cwan1sim2Priority"
		fi	
	else   
		if [ "$policy_type" = "balanced" ]
		then
			uci set modem."${cellularwan1interface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set modem."${cellularwan1interface}".metric="$Cwan1Priority"
		fi
	fi
	
	uci commit modem
	ubus call modem reload
	
	#WIFI
	if [ "$wifi1mode" =  "sta" ] || [ "$wifi1mode" =  "apsta" ]
	then
		if [ "$policy_type" = "balanced" ]
		then
			uci set network."${wifiwaninterface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set network."${wifiwaninterface}".metric="$WifiwanPriority"
		fi
		
		uci commit network
		ubus call network reload
	fi
	
}

UpdateCellularNetworkConfig()
{
	Cwan1metric=$(uci get modem."${cellularwan1interface}".metric)
	Cwan2metric=$(uci get modem."${cellularwan2interface}".metric)
	Cwan1sim1metric=$(uci get modem."${cellularwan1sim1interface}".metric)
	Cwan1sim2metric=$(uci get modem."${cellularwan1sim2interface}".metric)
	
	#Cellular
	if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
	then
		uci set network."${cellularwan1interface}".metric="$Cwan1metric"
		uci set network."${cellularwan2interface}".metric="$Cwan2metric"	
	elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
    then
		uci set network."${cellularwan1sim1interface}".metric="$Cwan1sim1metric"
		uci set network."${cellularwan1sim2interface}".metric="$Cwan1sim2metric"
	else
		uci set network."${cellularwan1interface}".metric="$Cwan1metric"
	fi

	uci commit network
	ubus call network reload
}

cellularwan1interface="CWAN1"
cellularwan2interface="CWAN2"
cellularwan3interface="CWAN3"
cellularwan1sim1interface="CWAN1_0"
cellularwan1sim2interface="CWAN1_1"

#IPV6 Variables 
cellular1wan6interface="wan6c1"
cellular2wan6interface="wan6c2"

wifiinterface="ra0"
wifi5interface="rai0"
wifiap="ra0_ap"
wifi5ap="rai0_ap"
wifista="sta"
wifiwaninterface="WIFI_WAN"

#To change guest name -- 
wifiap1="ra1"
wifiap51="rai1"

MwanConfigFile="/etc/config/mwan3config"
simtmpfile="/tmp/simnumfile"

sleep 1

rm -rf /var/run/mwan3.lock

sleep 1

/etc/init.d/mwan3 stop 2>&1

sleep 5

rm -rf /var/run/mwan3.lock

sleep 1

pids=$(ps w | grep -i "mwan3" | grep -v grep | awk '{print $1}')
kill -9 $pids

sleep 1

#failover/balanced policy for mwan3.
policy_type=$(uci get mwan3config.general.select)

#Calls sysconfig.
ReadSystemConfigFile

#Calls UpdateMwanConfig & UpdateCellularMwan3Config.
ReadMwanConfigFile

#Gets metric from mwan3config & updates to modem
UpdateCellular_WIFI_ModemConfig

#Gets metric from modem & updates to network
UpdateCellularNetworkConfig

#Call this bin, so that it updates the cfg files according to the trackips from mwan3 for router ping application.
/bin/UpdateConfigurationsRouterApp ucitoappcfg

sleep 1

#MWAN3
rm -rf /var/run/mwan3.lock

sleep 1

/usr/sbin/mwan3 restart

/bin/sleep 2

rm -rf /var/run/mwan3.lock

sleep 1

exit 0
