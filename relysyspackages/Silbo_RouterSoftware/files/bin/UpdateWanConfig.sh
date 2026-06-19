#!/bin/sh
. /lib/functions.sh


sysconfigUCIPath=/etc/config/sysconfig
sysconfigsection="sysconfig"
wificonfigsection="wificonfig"
loopbackconfigsection="loopback"
validatescript="/bin/validate.sh"
wanstatusupdatescript="/bin/mwan3statusupdate.sh"
cellulardatausagemanagerscript="/bin/cellulardatausagemanagerscript.sh"

wanconfigname3="CWAN1"
wanconfigname4="CWAN2"
wanconfigname5="CWAN1_0"
wanconfigname6="CWAN1_1"
wanconfigname7="WIFI_WAN"

wan6configname1="CWAN1"
wan6configname2="CWAN2"
wan6configname3="wan6c1"
wan6configname4="wan6c2"

Select=$(uci get mwan3config.general.select)

ReadOldPriority_Failover()
{
 
 #if [ "$Select" =  "failover" ]
 #then	
	
  config=$1
  config_get WanPriority "$config" wanpriority
  config_get enabled_failover "$config" enabled
  config_get track_method_failover "$config" track_method
  echo $track_method 
  config_get validtrackip_failover "$config" validtrackip
  config_get trackIp1_failover "$config" trackIp1
  config_get trackIp2_failover "$config" trackIp2
  config_get trackIp3_failover "$config" trackIp3
  config_get trackIp4_failover "$config" trackIp4
  config_get reliability_failover "$config" reliability
  config_get count_failover "$config" count
  config_get up_failover "$config" up
  config_get down_failover "$config" down
  config_get timeout_failover "$config" timeout
  config_get flush_conntrack_failover "$config" flush_conntrack

  config_get interval_failover "$config" interval
  config_get check_quality_failover "$config" check_quality
  config_get failure_latency_failover "$config" failure_latency
  config_get recovery_latency_failover "$config" recovery_latency
  config_get failure_loss_failover "$config" failure_loss
  config_get recovery_loss_failover "$config" recovery_loss
  config_get initial_state_failover "$config" initial_state
  
  case "$config" in
   "CWAN1") 
			CWAN1priority_failover=$WanPriority
			CWAN1validtrackip_failover=$validtrackip_failover
			CWAN1enabled_failover=$enabled_failover
            CWAN1trackmethod_failover=$track_method_failover
            CWAN1flush_conntrack_failover=$flush_conntrack_failover

            CWAN1timeout_failover=$timeout_failover
            CWAN1interval_failover=$interval_failover
            CWAN1check_quality_failover=$check_quality_failover
            CWAN1failure_latency_failover=$failure_latency_failover
            CWAN1recovery_latency_failover=$recovery_latency_failover
            CWAN1failure_loss_failover=$failure_loss_failover
            CWAN1recovery_loss_failover=$recovery_loss_failover
            echo $CWAN1trackmethod_failover 
				if [ $CWAN1validtrackip_failover = "1" ]
				then
					CWAN1trackIp1_failover=$trackIp1_failover
				fi
				if [ $CWAN1validtrackip_failover = "2" ]
				then
					CWAN1trackIp1_failover=$trackIp1_failover
					CWAN1trackIp2_failover=$trackIp2_failover
				fi
				if [ $CWAN1validtrackip_failover = "3" ]
				then
					CWAN1trackIp1_failover=$trackIp1_failover
					CWAN1trackIp2_failover=$trackIp2_failover
					CWAN1trackIp3_failover=$trackIp3_failover
				fi
				if [ $CWAN1validtrackip_failover = "4" ]
				then
					CWAN1trackIp1_failover=$trackIp1_failover
					CWAN1trackIp2_failover=$trackIp2_failover
					CWAN1trackIp3_failover=$trackIp3_failover
					CWAN1trackIp4_failover=$trackIp4_failover
				fi
				CWAN1up_failover=$up_failover
				CWAN1down_failover=$down_failover
				CWAN1reliability_failover=$reliability_failover
				CWAN1count_failover=$count_failover       		
			;;
	"wan6c1")		         
			CWAN1V6_0priority_failover=$WanPriority
			CWAN1V6_0validtrackip_failover=$validtrackip_failover
			CWAN1V6_0enabled_failover=$enabled_failover
            CWAN1V6_0trackmethod_failover=$track_method_failover
            CWAN1V6_0flush_conntrack_failover=$flush_conntrack_failover

            CWAN1V6_0timeout_failover=$timeout_failover
            CWAN1V6_0interval_failover=$interval_failover
            CWAN1V6_0check_quality_failover=$check_quality_failover
            CWAN1V6_0failure_latency_failover=$failure_latency_failover
            CWAN1V6_0frecovery_latency_failover=$recovery_latency_failover
            CWAN1V6_0failure_loss_failover=$failure_loss_failover
            CWAN1V6_0recovery_loss_failover=$recovery_loss_failover			
			if [ $CWAN1V6_0validtrackip_failover = "1" ]
			then
				CWAN1V6_0trackIp1_failover=$trackIp1_failover
			fi
			if [ $CWAN1V6_0validtrackip_failover = "2" ]
			then
				CWAN1V6_0trackIp1_failover=$trackIp1_failover
				CWAN1V6_0trackIp2_failover=$trackIp2_failover
			fi
			if [ $CWAN1V6_0validtrackip_failover = "3" ]
			then
				CWAN1V6_0trackIp1_failover=$trackIp1_failover
				CWAN1V6_0trackIp2_failover=$trackIp2_failover
				CWAN1V6_0trackIp3_failover=$trackIp3_failover
			fi
			if [ $CWAN1V6_0validtrackip_failover = "4" ]
			then
				CWAN1V6_0trackIp1_failover=$trackIp1_failover
				CWAN1V6_0trackIp2_failover=$trackIp2_failover
				CWAN1V6_0trackIp3_failover=$trackIp3_failover
				CWAN1V6_0trackIp4_failover=$trackIp4_failover
			fi
					CWAN1V6_0up_failover=$up_failover
					CWAN1V6_0down_failover=$down_failover
					CWAN1V6_0reliability_failover=$reliability_failover
					CWAN1V6_0count_failover=$count_failover
					echo "CWAN1V6_0trackIp1 is $CWAN1V6_0trackIp1,$CWAN1V6_0trackIp2"				
			;;
   "CWAN2") 
			CWAN2priority_failover=$WanPriority
			CWAN2enabled_failover=$enabled_failover
            CWAN2trackmethod_failover=$track_method_failover
			CWAN2trackIp1_failover=$trackIp1_failover
			CWAN2trackIp2_failover=$trackIp2_failover
			CWAN2trackIp3_failover=$trackIp3_failover
			CWAN2trackIp4_failover=$trackIp4_failover
			CWAN2flush_conntrack_failover=$flush_conntrack_failover

            CWAN2timeout_failover=$timeout_failover
            CWAN2interval_failover=$interval_failover
            CWAN2check_quality_failover=$check_quality_failover
            CWAN2failure_latency_failover=$failure_latency_failover
            CWAN2frecovery_latency_failover=$recovery_latency_failover
            CWAN2failure_loss_failover=$failure_loss_failover
            CWAN2recovery_loss_failover=$recovery_loss_failover
			;;
   "CWAN1_0") 
			CWAN1_0priority_failover=$WanPriority
			CWAN1_0enabled_failover=$enabled_failover
			CWAN1_0validtrackip_failover=$validtrackip_failover
			CWAN1_0trackmethod_failover=$track_method_failover
			CWAN1_0flush_conntrack_failover=$flush_conntrack_failover  

            CWAN1_0timeout_failover=$timeout_failover
            CWAN1_0interval_failover=$interval_failover
            CWAN1_0check_quality_failover=$check_quality_failover
            CWAN1_0failure_latency_failover=$failure_latency_failover
            CWAN1_0recovery_latency_failover=$recovery_latency_failover
            CWAN1_0failure_loss_failover=$failure_loss_failover
            CWAN1_0recovery_loss_failover=$recovery_loss_failover              
				if [ $CWAN1_0validtrackip_failover = "1" ]
				then
					CWAN1_0trackIp1_failover=$trackIp1_failover
				fi
				if [ $CWAN1_0validtrackip_failover = "2" ]
				then
					CWAN1_0trackIp1_failover=$trackIp1_failover
					CWAN1_0trackIp2_failover=$trackIp2_failover
				fi
				if [ $CWAN1_0validtrackip_failover = "3" ]
				then
					CWAN1_0trackIp1_failover=$trackIp1_failover
					CWAN1_0trackIp2_failover=$trackIp2_failover
					CWAN1_0trackIp3_failover=$trackIp3_failover
				fi
				if [ $CWAN1_0validtrackip_failover = "4" ]
				then
					CWAN1_0trackIp1_failover=$trackIp1_failover
					CWAN1_0trackIp2_failover=$trackIp2_failover
					CWAN1_0trackIp3_failover=$trackIp3_failover
					CWAN1_0trackIp4_failover=$trackIp4_failover
				fi
				CWAN1_0up_failover=$up_failover
				CWAN1_0down_failover=$down_failover
				CWAN1_0reliability_failover=$reliability_failover
				CWAN1_0count_failover=$count_failover
				;;
	"wan6c2")			
			CWAN1V6_1priority_failover=$WanPriority
			CWAN1V6_1validtrackip_failover=$validtrackip_failover
			CWAN1V6_1enabled_failover=$enabled_failover
            CWAN1V6_1trackmethod_failover=$track_method_failover
            CWAN1V6_1flush_conntrack_failover=$flush_conntrack_failover

            CWAN1V6_1timeout_failover=$timeout_failover
            CWAN1V6_1interval_failover=$interval_failover
            CWAN1V6_1check_quality_failover=$check_quality_failover
            CWAN1V6_1failure_latency_failover=$failure_latency_failover
            CWAN1V6_1recovery_latency_failover=$recovery_latency_failover
            CWAN1V6_1failure_loss_failover=$failure_loss_failover
            CWAN1V6_1recovery_loss_failover=$recovery_loss_failover	
				if [ $CWAN1V6_1validtrackip_failover = "1" ]
				then
					CWAN1V6_1trackIp1_failover=$trackIp1_failover
				fi
				if [ $CWAN1V6_1validtrackip _failover= "2" ]
				then
					CWAN1V6_1trackIp1_failover=$trackIp1_failover
					CWAN1V6_1trackIp2_failover=$trackIp2_failover
				fi
				if [ $CWAN1_0validtrackip_failover = "3" ]
				then
					CWAN1V6_1trackIp1_failover=$trackIp1_failover
					CWAN1V6_1trackIp2_failover=$trackIp2_failover
					CWAN1V6_1trackIp3_failover=$trackIp3_failover
				fi
				if [ $CWAN1V6_1validtrackip_failover = "4" ]
				then
					CWAN1V6_1trackIp1_failover=$trackIp1_failover
					CWAN1V6_1trackIp2_failover=$trackIp2_failover
					CWAN1V6_1trackIp3_failover=$trackIp3_failover
					CWAN1V6_1trackIp4_failover=$trackIp4_failover
				fi
				CWAN1V6_1up_failover=$up_failover
				CWAN1V6_1down_failover=$down_failover
				CWAN1V6_1reliability_failover=$reliability_failover
				CWAN1V6_1count_failover=$count_failover
		  
			;;
   "CWAN1_1") 
			CWAN1_1priority_failover=$WanPriority
			CWAN1_1validtrackip_failover=$validtrackip_failover
			CWAN1_1enabled_failover=$enabled_failover  
            CWAN1_1trackmethod_failover=$track_method_failover 
            CWAN1_1flush_conntrack_failover=$flush_conntrack_failover  

            CWAN1_1timeout_failover=$timeout_failover
            CWAN1_1interval_failover=$interval_failover
            CWAN1_1check_quality_failover=$check_quality_failover
            CWAN1_1failure_latency_failover=$failure_latency_failover
            CWAN1_1recovery_latency_failover=$recovery_latency_failover
            CWAN1_1failure_loss_failover=$failure_loss_failover
            CWAN1_1recovery_loss_failover=$recovery_loss_failover         
			if [ $CWAN1_1validtrackip_failover = "1" ]
			then
				CWAN1_1trackIp1_failover=$trackIp1_failover
			fi
			if [ $CWAN1_1validtrackip_failover = "2" ]
			then
				CWAN1_1trackIp1_failover=$trackIp1_failover
				CWAN1_1trackIp2_failover=$trackIp2_failover
			fi
			if [ $CWAN1_1validtrackip_failover = "3" ]
			then
				CWAN1_1trackIp1_failover=$trackIp1_failover
				CWAN1_1trackIp2_failover=$trackIp2_failover
				CWAN1_1trackIp3_failover=$trackIp3_failover
			fi
			if [ $CWAN1_0validtrackip_failover = "4" ]
			then
				CWAN1_1trackIp1_failover=$trackIp1_failover
				CWAN1_1trackIp2_failover=$trackIp2_failover
				CWAN1_1trackIp3_failover=$trackIp3_failover
				CWAN1_1trackIp4_failover=$trackIp4_failover
			fi
			CWAN1_1up_failover=$up_failover
			CWAN1_1down_failover=$down_failover
			CWAN1_1reliability_failover=$reliability_failover
			CWAN1_1count_failover=$count_failover
			;;
   "WIFI_WAN")                  
				WIFIpriority_failover=$WanPriority
				WIFIvalidtrackip_failover=$validtrackip_failover
				WIFIenabled_failover=$enabled_failover  
                WIFItrackmethod_failover=$track_method_failover
                WIFIflush_conntrack_failover=$flush_conntrack_failover

				WIFItimeout_failover=$timeout_failover
				WIFIinterval_failover=$interval_failover
				WIFIcheck_quality_failover=$check_quality_failover
				WIFIfailure_latency_failover=$failure_latency_failover
				WIFIrecovery_latency_failover=$recovery_latency_failover
				WIFIfailure_loss_failover=$failure_loss_failover
				WIFIrecovery_loss_failover=$recovery_loss_failover 
				WIFIinitial_state_failover=$initial_state_failover 
				if [ $WIFIvalidtrackip_failover = "1" ]
				then
					WIFItrackIp1_failover=$trackIp1_failover
				fi
				if [ $WIFIvalidtrackip_failover = "2" ]
				then
					WIFItrackIp1_failover=$trackIp1_failover
					WIFItrackIp2_failover=$trackIp2_failover
				fi
				if [ $WIFIvalidtrackip_failover = "3" ]
				then
					WIFItrackIp1_failover=$trackIp1_failover
					WIFItrackIp2_failover=$trackIp2_failover
					WIFItrackIp3_failover=$trackIp3_failover
				fi
				if [ $WIFIvalidtrackip_failover = "4" ]
				then
					WIFItrackIp1_failover=$trackIp1_failover
					WIFItrackIp2_failover=$trackIp2_failover
					WIFItrackIp3_failover=$trackIp3_failover
					WIFItrackIp4_failover=$trackIp4_failover
				fi
				WIFIup_failover=$up_failover
				WIFIdown_failover=$down_failover
				WIFIreliability_failover=$reliability_failover
				WIFIcount_failover=$count_failover
					;;
esac

echo "CWAN1priority=$CWAN1priority"
echo "CWAN2priority=$CWAN2priority"
echo "CWAN1_0priority=$CWAN1_0priority"
echo "CWAN1_1priority=$CWAN1_1priority"
echo "WIFIpriority=$WIFIpriority"

#fi

}

SetPriority_Failover()
{  
	#if [ "$Select" =  "failover" ]
    #then
	echo $CellularOperationMode 
	if [ "$enablecellular" = "1" ]
	then    
		echo $CellularOperationMode 
		 if [ "$CellularOperationMode" = "dualcellularsinglesim" ]
		 then
			uci set mwan3config."$wanconfigname3"=mwan3config
			uci set mwan3config.$wanconfigname3.name=$wanconfigname3
            uci set mwan3config.$wanconfigname3.track_method=$CWAN1trackmethod_failover
            uci set mwan3config.$wanconfigname3.flush_conntrack=$CWAN1flush_conntrack_failover

			uci set mwan3config.$wanconfigname3.timeout=$CWAN1timeout_failover
			uci set mwan3config.$wanconfigname3.interval=$CWAN1interval_failover
			uci set mwan3config.$wanconfigname3.check_quality=$CWAN1check_quality_failover
			uci set mwan3config.$wanconfigname3.failure_latency=$CWAN1failure_latency_failover
			uci set mwan3config.$wanconfigname3.recovery_latency=$CWAN1recovery_latency_failover
			uci set mwan3config.$wanconfigname3.failure_loss=$CWAN1failure_loss_failover
			uci set mwan3config.$wanconfigname3.recovery_loss=$CWAN1recovery_loss_failover
			if [[ $CWAN1priority != 0 ]]
			then
				uci set mwan3config.$wanconfigname3.enabled=$CWAN1enabled_failover
				uci set mwan3config.$wanconfigname3.wanpriority=$CWAN1priority_failover
				uci set mwan3config.$wanconfigname3.trackIp1=$CWAN1trackIp1_failover
				uci set mwan3config.$wanconfigname3.trackIp2=$CWAN1trackIp2_failover
				uci set mwan3config.$wanconfigname3.trackIp3=$CWAN1trackIp3_failover
				uci set mwan3config.$wanconfigname3.trackIp4=$CWAN1trackIp4_failover
			else    
				uci set mwan3config.$wanconfigname3.enabled=1
				uci set mwan3config.$wanconfigname3.wanpriority=2
				uci set mwan3config.$wanconfigname3.trackIp1=8.8.8.8
				uci set mwan3config.$wanconfigname3.trackIp2=8.8.4.4
				uci set mwan3config.$wanconfigname3.trackIp3=208.67.220.220
				uci set mwan3config.$wanconfigname3.trackIp4=208.67.222.222
				uci set mwan3config.$wanconfigname3.flush_conntrack=1
				uci set mwan3config.$wanconfigname3.timeout=2
				uci set mwan3config.$wanconfigname3.interval=2
			fi                   
				count=$((count + 1))
				echo "Count = $count"
				
				uci set mwan3config."$wanconfigname4"=mwan3config
				uci set mwan3config.$wanconfigname4.name=$wanconfigname4
                uci set mwan3config.$wanconfigname4.track_method=$CWAN2trackmethod_failover
                                
				if [[ $CWAN2priority_failover != 0 ]]
				then
				    uci set mwan3config.$wanconfigname4.enabled=$CWAN2enabled_failover
					uci set mwan3config.$wanconfigname4.wanpriority=$CWAN2priority_failover
					uci set mwan3config.$wanconfigname4.trackIp1=$CWAN2trackIp1_failover
					uci set mwan3config.$wanconfigname4.trackIp2=$CWAN2trackIp2_failover
					uci set mwan3config.$wanconfigname4.trackIp3=$CWAN2trackIp3_failover
					uci set mwan3config.$wanconfigname4.trackIp4=$CWAN2trackIp4_failover
					uci set mwan3config.$wanconfigname4.flush_conntrack=$CWAN2flush_conntrack_failover
					uci set mwan3config.$wanconfigname4.interval=$CWAN2interval_failover
					uci set mwan3config.$wanconfigname4.timeout=$CWAN2timeout_failover
					uci set mwan3config.$wanconfigname4.check_quality=$CWAN2check_quality_failover
					uci set mwan3config.$wanconfigname4.failure_latency=$CWAN2failure_latency_failover
					uci set mwan3config.$wanconfigname4.recovery_latency=$CWAN2recovery_latency_failover
					uci set mwan3config.$wanconfigname4.failure_loss=$CWAN2failure_loss_failover
					uci set mwan3config.$wanconfigname4.recovery_loss=$CWAN2recovery_loss_failover
				else    
					uci set mwan3config.$wanconfigname4.enabled=1
					uci set mwan3config.$wanconfigname4.wanpriority=3                 
					uci set mwan3config.$wanconfigname4.trackIp1=8.8.8.8
					uci set mwan3config.$wanconfigname4.trackIp2=8.8.4.4
					uci set mwan3config.$wanconfigname4.trackIp3=208.67.220.220
					uci set mwan3config.$wanconfigname4.trackIp4=208.67.222.222
					uci set mwan3config.$wanconfigname4.flush_conntrack=1
					uci set mwan3config.$wanconfigname4.timeout=2
					uci set mwan3config.$wanconfigname4.interval=2
				fi
				count=$((count + 1))
				echo "Count = $count"
		fi
			 
		if [ "$CellularOperationMode" = "singlecellulardualsim" ]
		then
		    if [ "$PDP1" = "IPV4" ] || [ "$PDP1" = "IPV4V6" ]
			then
				uci set mwan3config."$wanconfigname5"=mwan3config
				uci set mwan3config.$wanconfigname5.name=$wanconfigname5
                uci set mwan3config.$wanconfigname5.track_method=$CWAN1_0trackmethod_failover
                
				if [[ $CWAN1_0priority_failover != 0 ]]
				then
					uci set mwan3config.$wanconfigname5.enabled=$CWAN1_0enabled_failover
					uci set mwan3config.$wanconfigname5.wanpriority=$CWAN1_0priority_failover
					uci set mwan3config.$wanconfigname5.validtrackip=$CWAN1_0validtrackip_failover
					uci set mwan3config.$wanconfigname5.flush_conntrack=$CWAN1_0flush_conntrack_failover
					uci set mwan3config.$wanconfigname5.timeout=$CWAN1_0timeout_failover
					uci set mwan3config.$wanconfigname5.interval=$CWAN1_0interval_failover
					uci set mwan3config.$wanconfigname5.check_quality=$CWAN1_0check_quality_failover
					uci set mwan3config.$wanconfigname5.failure_latency=$CWAN1_0failure_latency_failover
					uci set mwan3config.$wanconfigname5.recovery_latency=$CWAN1_0recovery_latency_failover
					uci set mwan3config.$wanconfigname5.failure_loss=$CWAN1_0failure_loss_failover
					uci set mwan3config.$wanconfigname5.recovery_loss=$CWAN1_0recovery_loss_failover  
				
					if [ "$CWAN1_0validtrackip_failover" =  "1" ]
					then 
						uci set mwan3config.$wanconfigname5.trackIp1="$CWAN1_0trackIp1_failover"
					fi
					if [ "$CWAN1_0validtrackip_failover" =  "2" ]
					then 
						uci set mwan3config.$wanconfigname5.trackIp1="$CWAN1_0trackIp1_failover"
						uci set mwan3config.$wanconfigname5.trackIp2="$CWAN1_0trackIp2_failover"
					fi
			
					if [ "$CWAN1_0validtrackip_failover" =  "3" ]
					then 
						uci set mwan3config.$wanconfigname5.trackIp1="$CWAN1_0trackIp1_failover"
						uci set mwan3config.$wanconfigname5.trackIp2="$CWAN1_0trackIp2_failover"
						uci set mwan3config.$wanconfigname5.trackIp3="$CWAN1_0trackIp3_failover"
					fi
					if [ "$CWAN1_0validtrackip_failover" =  "4" ]
					then            
						uci set mwan3config.$wanconfigname5.trackIp1="$CWAN1_0trackIp1_failover"
						uci set mwan3config.$wanconfigname5.trackIp2="$CWAN1_0trackIp2_failover"
						uci set mwan3config.$wanconfigname5.trackIp3="$CWAN1_0trackIp3_failover"
						uci set mwan3config.$wanconfigname5.trackIp4="$CWAN1_0trackIp4_failover"
					fi
					uci set mwan3config.$wanconfigname5.reliability="$CWAN1_0reliability_failover"
					uci set mwan3config.$wanconfigname5.count="$CWAN1_0count_failover"
					uci set mwan3config.$wanconfigname5.up="$CWAN1_0up_failover"
					uci set mwan3config.$wanconfigname5.down="$CWAN1_0down_failover"
				else  
					uci set mwan3config.$wanconfigname5.enabled=1
					uci set mwan3config.$wanconfigname5.wanpriority=2
					uci set mwan3config.$wanconfigname5.track_method="ping"
					uci set mwan3config.$wanconfigname5.validtrackip=2
					uci set mwan3config.$wanconfigname5.trackIp1=8.8.8.8
					uci set mwan3config.$wanconfigname5.trackIp2=8.8.4.4
					uci set mwan3config.$wanconfigname5.reliability=1
					uci set mwan3config.$wanconfigname5.count=3
					uci set mwan3config.$wanconfigname5.up=3
					uci set mwan3config.$wanconfigname5.down=3
					uci set mwan3config.$wanconfigname5.flush_conntrack=1
					uci set mwan3config.$wanconfigname5.timeout=2
					uci set mwan3config.$wanconfigname5.interval=2
				fi
									  
				count=$((count + 1))
				echo "Count = $count"
			fi					  
			#IPV6 update for wan6c1(Dual sim single modem)
			if [ "$PDP1" = "IPV6" ]
			then
			    uci delete mwan3.default_rule
				uci set mwan3config.$wan6configname3=mwan3config
				uci set mwan3config.$wan6configname3.name=$wan6configname3
                uci set mwan3config.$wan6configname3.track_method=$CWAN1V6_0trackmethod_failover
                uci set mwan3config.$wan6configname3.flush_conntrack=$CWAN1V6_0flush_conntrack_failover
				uci set mwan3config.$wan6configname3.timeout=$CWAN1V6_0timeout_failover
				uci set mwan3config.$wan6configname3.interval=$CWAN1V6_0interval_failover
				uci set mwan3config.$wan6configname3.check_quality=$CWAN1V6_0check_quality_failover
				uci set mwan3config.$wan6configname3.failure_latency=$CWAN1V6_0failure_latency_failover
				uci set mwan3config.$wan6configname3.recovery_latency=$CWAN1V6_0recovery_latency_failover
				uci set mwan3config.$wan6configname3.failure_loss=$CWAN1V6_0failure_loss_failover
				uci set mwan3config.$wan6configname3.recovery_loss=$CWAN1V6_0recovery_loss _failover 
				if [[ $CWAN1V6_0priority_failover != 0 ]]
				then
					uci set mwan3config.$wan6configname3.wanpriority=$CWAN1V6_0priority_failover
					uci set mwan3config.$wan6configname3.validtrackip=$CWAN1V6_0validtrackip_failover
					uci set mwan3config.$wan6configname3.enabled=$CWAN1V6_0enabled_failover
					if [ "$CWAN1V6_0validtrackip_failover" =  "1" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1_failover"
					fi
					if [ "$CWAN1V6_0validtrackip_failover" =  "2" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1_failover"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2_failover"
					fi
			
					if [ "$CWAN1V6_0validtrackip_failover" =  "3" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1_failover"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2_failover"
						uci set mwan3config.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3_failover"
					fi
					if [ "$CWAN1V6_0validtrackip_failover" =  "4" ]
					then            
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1_failover"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2_failover"
						uci set mwan3config.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3_failover"
						uci set mwan3config.$wan6configname3.trackIp4="$CWAN1V6_0trackIp4_failover"
					fi
						uci set mwan3config.$wan6configname3.reliability="$CWAN1V6_0reliability_failover"
						uci set mwan3config.$wan6configname3.count="$CWAN1V6_0count_failover"
						uci set mwan3config.$wan6configname3.up="$CWAN1V6_0up_failover"
						uci set mwan3config.$wan6configname3.down="$CWAN1V6_0down_failover"       
				else    
					uci set mwan3config.$wan6configname3.enabled=1
					uci set mwan3config.$wan6configname3.wanpriority=2
                    uci set mwan3config.$wan6configname3.track_method="ping"
					uci set mwan3config.$wan6configname3.validtrackip=2
					uci set mwan3config.$wan6configname3.trackIp1=2001:4860:4860::8888
					uci set mwan3config.$wan6configname3.trackIp2=2001:4860:4860::8844
					uci set mwan3config.$wan6configname3.reliability=1
					uci set mwan3config.$wan6configname3.count=3
					uci set mwan3config.$wan6configname3.up=3
					uci set mwan3config.$wan6configname3.down=3
					uci set mwan3config.$wan6configname3.flush_conntrack=1
					uci set mwan3config.$wan6configname3.timeout=4
					uci set mwan3config.$wan6configname3.interval=2
				fi				  
					count=$((count + 1))
					echo "Count = $count"
					uci set mwan3config				
			fi 
			
			#sim2 priorioty 
			if [ "$PDP2" = "IPV4" ] || [ "$PDP2" = "IPV4V6" ] 
			then
				uci set mwan3config."$wanconfigname6"=mwan3config
				uci set mwan3config.$wanconfigname6.name=$wanconfigname6 
                uci set mwan3config.$wanconfigname6.track_method=$CWAN1_1trackmethod_failover   		   
				if [[ $CWAN1_1priority_failover != 0 ]]
				then
					uci set mwan3config.$wanconfigname6.wanpriority=$CWAN1_1priority_failover
					uci set mwan3config.$wanconfigname6.validtrackip=$CWAN1_1validtrackip_failover
					uci set mwan3config.$wanconfigname6.enabled=$CWAN1_1enabled_failover
					uci set mwan3config.$wanconfigname6.flush_conntrack=$CWAN1_1flush_conntrack_failover
					uci set mwan3config.$wanconfigname6.timeout=$CWAN1_1timeout_failover
					uci set mwan3config.$wanconfigname6.interval=$CWAN1_1interval_failover
					uci set mwan3config.$wanconfigname6.check_quality=$CWAN1_1check_quality_failover
					uci set mwan3config.$wanconfigname6.failure_latency=$CWAN1_1failure_latency_failover
					uci set mwan3config.$wanconfigname6.recovery_latency=$CWAN1_1recovery_latency_failover
					uci set mwan3config.$wanconfigname6.failure_loss=$CWAN1_1failure_loss_failover
					uci set mwan3config.$wanconfigname6.recovery_loss=$CWAN1_1recovery_loss_failover   		 
					
					if [ "$CWAN1_1validtrackip_failover" =  "1" ]
					then 
						uci set mwan3config.$wanconfigname6.trackIp1="$CWAN1_1trackIp1_failover"
					fi
					if [ "$CWAN1_1validtrackip_failover" =  "2" ]
					then 
						uci set mwan3config.$wanconfigname6.trackIp1="$CWAN1_1trackIp1_failover"
						uci set mwan3config.$wanconfigname6.trackIp2="$CWAN1_1trackIp2_failover"
					fi
					if [ "$CWAN1_1validtrackip_failover" =  "3" ]
					then 
						uci set mwan3config.$wanconfigname6.trackIp1="$CWAN1_1trackIp1_failover"
						uci set mwan3config.$wanconfigname6.trackIp2="$CWAN1_1trackIp2_failover"
						uci set mwan3config.$wanconfigname6.trackIp3="$CWAN1_1trackIp3_failover"
					fi
					if [ "$CWAN1_1validtrackip_failover" =  "4" ]
					then             
						uci set mwan3config.$wanconfigname6.trackIp1="$CWAN1_1trackIp1_failover"
						uci set mwan3config.$wanconfigname6.trackIp2="$CWAN1_1trackIp2_failover"
						uci set mwan3config.$wanconfigname6.trackIp3="$CWAN1_1trackIp3_failover"
						uci set mwan3config.$wanconfigname6.trackIp4="$CWAN1_1trackIp4_failover"
					fi
					uci set mwan3config.$wanconfigname6.reliability="$CWAN1_1reliability_failover"
					uci set mwan3config.$wanconfigname6.count="$CWAN1_1count_failover"
					uci set mwan3config.$wanconfigname6.up="$CWAN1_1up_failover"
					uci set mwan3config.$wanconfigname6.down="$CWAN1_1down_failover"
				else  
					uci set mwan3config.$wanconfigname6.enabled=1
					uci set mwan3config.$wanconfigname6.wanpriority=3
                    uci set mwan3config.$wanconfigname6.track_method="ping"
					uci set mwan3config.$wanconfigname6.validtrackip=2
					uci set mwan3config.$wanconfigname6.trackIp1=8.8.8.8
					uci set mwan3config.$wanconfigname6.trackIp2=8.8.4.4
					uci set mwan3config.$wanconfigname6.reliability=1
					uci set mwan3config.$wanconfigname6.count=3
					uci set mwan3config.$wanconfigname6.timeout=2
					uci set mwan3config.$wanconfigname6.up=3
					uci set mwan3config.$wanconfigname6.down=3
					uci set mwan3config.$wanconfigname6.flush_conntrack=1
					uci set mwan3config.$wanconfigname6.interval=2
				fi
				
				
				count=$((count + 1))
				echo "Count = $count"  
				uci set mwan3config
			fi 
				#IPV6 update for sim2 
			if [ "$PDP2" = "IPV6" ]
			then   
				uci set mwan3config."$wan6configname4"=mwan3config
				uci set mwan3config.$wan6configname4.name=$wan6configname4
                uci set mwan3config.$wan6configname4.track_method=$CWAN1V6_1trackmethod_failover  
				if [[ $CWAN1V6_1priority != 0 ]]
				then
					uci set mwan3config.$wan6configname4.wanpriority=$CWAN1V6_1priority_failover
					uci set mwan3config.$wan6configname4.validtrackip=$CWAN1V6_1validtrackip_failover
					uci set mwan3config.$wan6configname4.enabled=$CWAN1V6_1enabled_failover
					uci set mwan3config.$wan6configname4.flush_conntrack=$CWAN1V6_1flush_conntrack_failover
					uci set mwan3config.$wan6configname4.timeout=$CWAN1V6_1timeout_failover
					uci set mwan3config.$wan6configname4.interval=$CWAN1V6_1interval_failover
					uci set mwan3config.$wan6configname4.check_quality=$CWAN1V6_1check_quality_failover
					uci set mwan3config.$wan6configname4.failure_latency=$CWAN1V6_1failure_latency_failover
					uci set mwan3config.$wan6configname4.recovery_latency=$CWAN1V6_1recovery_latency_failover
					uci set mwan3config.$wan6configname4.failure_loss=$CWAN1V6_1failure_loss_failover
					uci set mwan3config.$wan6configname4.recovery_loss=$CWAN1V6_1recovery_loss_failover  	 
					if [ "$CWAN1V6_1validtrackip_failover" =  "1" ]
					then 
						uci set mwan3config.$wan6configname4.trackIp1="$CWAN1V6_1trackIp1_failover"
					fi
					if [ "$CWAN1V6_1validtrackip_failover" =  "2" ]
					then 
						uci set mwan3config.$wan6configname4.trackIp1="$CWAN1V6_1trackIp1_failover"
						uci set mwan3config.$wan6configname4.trackIp2="$CWAN1V6_1trackIp2_failover"
					fi
					if [ "$CWAN1V6_1validtrackip_failover" =  "3" ]
					then 
						uci set mwan3config.$wan6configname4.trackIp1="$CWAN1V6_1trackIp1_failover"
						uci set mwan3config.$wan6configname4.trackIp2="$CWAN1V6_1trackIp2_failover"
						uci set mwan3config.$wan6configname4.trackIp3="$CWAN1V6_1trackIp3_failover"
					fi
					if [ "$CWAN1V6_1validtrackip_failover" =  "4" ]
					then             
						uci set mwan3config.$wan6configname4.trackIp1="$CWAN1V6_1trackIp1_failover"
						uci set mwan3config.$wan6configname4.trackIp2="$CWAN1V6_1trackIp2_failover"
						uci set mwan3config.$wan6configname4.trackIp3="$CWAN1V6_1trackIp3_failover"
						uci set mwan3config.$wan6configname4.trackIp4="$CWAN1V6_1trackIp4_failover"
					fi
					uci set mwan3config.$wan6configname4.reliability="$CWAN1V6_1reliability_failover"
					uci set mwan3config.$wan6configname4.count="$CWAN1V6_1count_failover"
					uci set mwan3config.$wan6configname4.up="$CWAN1V6_1up_failover"
					uci set mwan3config.$wan6configname4.down="$CWAN1V6_1down_failover"
				else  
					uci set mwan3config.$wan6configname4.enabled=1
					uci set mwan3config.$wan6configname4.wanpriority=3
                    uci set mwan3config.$wan6configname4.track_method="ping"
					uci set mwan3config.$wan6configname4.validtrackip=2
					uci set mwan3config.$wan6configname4.trackIp1=2001:4860:4860::8888
					uci set mwan3config.$wan6configname4.trackIp2=2001:4860:4860::8844
					uci set mwan3config.$wan6configname4.reliability=1
					uci set mwan3config.$wan6configname4.count=3
					uci set mwan3config.$wan6configname4.up=3
					uci set mwan3config.$wan6configname4.down=3
					uci set mwan3config.$wan6configname4.flush_conntrack=1
					uci set mwan3config.$wan6configname4.timeout=4
					uci set mwan3config.$wan6configname4.interval=2
				fi	
				count=$((count + 1))
				echo "Count = $count"			
			fi   
				 
		fi	
		
				#################################################
		if [ "$CellularOperationMode" = "singlecellularsinglesim" ]
		then
			echo "singlecellular" 
			#IPV6 only for sssm
			#IPV6 update for wan6c1(single sim single modem)
			if [ "$PDP1" = "IPV6" ] 
			then
			    uci delete mwan3.default_rule
				uci set mwan3config."$wan6configname3"=mwan3config
				uci set mwan3config."$wan6configname3".name=$wan6configname3
				uci set mwan3config."$wan6configname3".track_method=$CWAN1V6_0trackmethod_failover
				if [[ $CWAN1V6_0priority != 0 ]]
				then
					uci set mwan3config.$wan6configname3.wanpriority=$CWAN1V6_0priority_failover
					uci set mwan3config.$wan6configname3.validtrackip=$CWAN1V6_0validtrackip_failover
					uci set mwan3config.$wan6configname3.enabled=$CWAN1V6_0enabled_failover
					uci set mwan3config.$wan6configname3.flush_conntrack=$CWAN1V6_0flush_conntrack_failover
					uci set mwan3config.$wan6configname3.timeout=$CWAN1V6_0timeout_failover
					uci set mwan3config.$wan6configname3.interval=$CWAN1V6_0interval_failover
					uci set mwan3config.$wan6configname3.check_quality=$CWAN1V6_0check_quality_failover
					uci set mwan3config.$wan6configname3.failure_latency=$CWAN1V6_0failure_latency_failover
					uci set mwan3config.$wan6configname3.recovery_latency=$CWAN1V6_0recovery_latency_failover
					uci set mwan3config.$wan6configname3.failure_loss=$CWAN1V6_0failure_loss_failover
					uci set mwan3config.$wan6configname3.recovery_loss=$CWAN1V6_0recovery_loss_failover  
					if [ "$CWAN1V6_0validtrackip_failover" =  "1" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1_failover"
					fi
					if [ "$CWAN1V6_0validtrackip_failover" =  "2" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1_failover"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2_failover"
					fi
			
					if [ "$CWAN1V6_0validtrackip_failover" =  "3" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1_failover"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2_failover"
						uci set mwan3config.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3_failover"
					fi
					if [ "$CWAN1V6_0validtrackip_failover" =  "4" ]
					then            
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1_failover"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2_failover"
						uci set mwan3config.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3_failover"
						uci set mwan3config.$wan6configname3.trackIp4="$CWAN1V6_0trackIp4_failover"
					fi
					uci set mwan3config.$wan6configname3.reliability="$CWAN1V6_0reliability_failover"
					uci set mwan3config.$wan6configname3.count="$CWAN1V6_0count_failover"
					uci set mwan3config.$wan6configname3.up="$CWAN1V6_0up_failover"
					uci set mwan3config.$wan6configname3.down="$CWAN1V6_0down_failover"       
				else   
					uci set mwan3config.$wan6configname3.enabled=1
					uci set mwan3config.$wan6configname3.wanpriority=2
					uci set mwan3config.$wan6configname3.track_method="ping"
					uci set mwan3config.$wan6configname3.validtrackip=2
					uci set mwan3config.$wan6configname3.trackIp1=2001:4860:4860::8888
					uci set mwan3config.$wan6configname3.trackIp2=2001:4860:4860::8844
					uci set mwan3config.$wan6configname3.reliability=1
					uci set mwan3config.$wan6configname3.count=3
					uci set mwan3config.$wan6configname3.up=3
					uci set mwan3config.$wan6configname3.down=3
					uci set mwan3config.$wan6configname3.flush_conntrack=1
					uci set mwan3config.$wan6configname3.timeout=4
					uci set mwan3config.$wan6configname3.interval=2
			    fi				  
				count=$((count + 1))
				echo "Count = $count"
				uci set mwan3config				
		    fi 
			
			################ IPV4 || IPV4V6 single sim single modem############
			if [ "$PDP1" = "IPV4" ]  || [ "$PDP1" = "IPV4V6" ] 
			then
				uci set mwan3config."$wanconfigname3"=mwan3config
				uci set mwan3config.$wanconfigname3.name=$wanconfigname3
				uci set mwan3config.$wanconfigname3.track_method=$CWAN1trackmethod_failover
				echo $CWAN1trackmethod 
                               
				if [[ $CWAN1priority_failover != 0 ]]
				then
					uci set mwan3config.$wanconfigname3.wanpriority=$CWAN1priority_failover
					uci set mwan3config.$wanconfigname3.validtrackip=$CWAN1validtrackip_failover
					uci set mwan3config.$wanconfigname3.enabled=$CWAN1enabled_failover
					uci set mwan3config.$wanconfigname3.flush_conntrack=$CWAN1flush_conntrack_failover
					uci set mwan3config.$wanconfigname3.timeout=$CWAN1timeout_failover
					uci set mwan3config.$wanconfigname3.interval=$CWAN1interval_failover
					uci set mwan3config.$wanconfigname3.check_quality=$CWAN1check_quality_failover
					uci set mwan3config.$wanconfigname3.failure_latency=$CWAN1failure_latency_failover
					uci set mwan3config.$wanconfigname3.recovery_latency=$CWAN1recovery_latency_failover
					uci set mwan3config.$wanconfigname3.failure_loss=$CWAN1failure_loss_failover
					uci set mwan3config.$wanconfigname3.recovery_loss=$CWAN1recovery_loss_failover
					if [ "$CWAN1validtrackip_failover" =  "1" ]
					then 
						uci set mwan3config.$wanconfigname3.trackIp1="$CWAN1trackIp1_failover"
					fi
					if [ "$CWAN1validtrackip_failover" =  "2" ]
					then 
						uci set mwan3config.$wanconfigname3.trackIp1="$CWAN1trackIp1_failover"
						uci set mwan3config.$wanconfigname3.trackIp2="$CWAN1trackIp2_failover"
					fi
					if [ "$CWAN1validtrackip_failover" =  "3" ]
					then 
						uci set mwan3config.$wanconfigname3.trackIp1="$CWAN1trackIp1_failover"
						uci set mwan3config.$wanconfigname3.trackIp2="$CWAN1trackIp2_failover"
						uci set mwan3config.$wanconfigname3.trackIp3="$CWAN1trackIp3_failover"
					fi
					if [ "$CWAN1validtrackip_failover" =  "4" ]
					then             
						uci set mwan3config.$wanconfigname3.trackIp1="$CWAN1trackIp1_failover"
						uci set mwan3config.$wanconfigname3.trackIp2="$CWAN1trackIp2_failover"
						uci set mwan3config.$wanconfigname3.trackIp3="$CWAN1trackIp3_failover"
						uci set mwan3config.$wanconfigname3.trackIp4="$CWAN1trackIp4_failover"
					fi
					uci set mwan3config.$wanconfigname3.reliability="$CWAN1reliability_failover"
					uci set mwan3config.$wanconfigname3.count="$CWAN1count_failover"
					uci set mwan3config.$wanconfigname3.up="$CWAN1up_failover"
					uci set mwan3config.$wanconfigname3.down="$CWAN1down_failover"      
				else  
					uci set mwan3config.$wanconfigname3.enabled=1
					uci set mwan3config.$wanconfigname3.wanpriority=2
					uci set mwan3config.$wanconfigname3.track_method="ping"
					uci set mwan3config.$wanconfigname3.validtrackip=2
					uci set mwan3config.$wanconfigname3.trackIp1=8.8.8.8
					uci set mwan3config.$wanconfigname3.trackIp2=8.8.4.4
					uci set mwan3config.$wanconfigname3.reliability=1
					uci set mwan3config.$wanconfigname3.count=3
					uci set mwan3config.$wanconfigname3.up=3
					uci set mwan3config.$wanconfigname3.down=3
					uci set mwan3config.$wanconfigname3.flush_conntrack=1
					uci set mwan3config.$wanconfigname3.timeout=2
					uci set mwan3config.$wanconfigname3.interval=2
				fi
			
				count=$((count + 1))
				echo "Count = $count"	
			fi	
		fi	  
		
	fi						  
	 
	if [ "$wifi1mode" = "sta" ] || [ "$wifi1mode" = "apsta" ]
	then
		uci set mwan3config."$wanconfigname7"=mwan3config
		uci set mwan3config.$wanconfigname7.name=$wanconfigname7
        uci set mwan3config.$wanconfigname7.track_method=$WIFItrackmethod_failover
		uci set mwan3config.$wanconfigname7.enabled=1
		if [[ $WIFIpriority_failover != 0 ]]
		then
			uci set mwan3config.$wanconfigname7.wanpriority=$WIFIpriority_failover
			uci set mwan3config.$wanconfigname7.validtrackip=$WIFIvalidtrackip_failover
			uci set mwan3config.$wanconfigname7.enabled=$WIFIenabled_failover
			uci set mwan3config.$wanconfigname7.flush_conntrack=$WIFIflush_conntrack_failover
			uci set mwan3config.$wanconfigname7.timeout=$WIFItimeout_failoverIPV6
			uci set mwan3config.$wanconfigname7.interval=$WIFIinterval_failover
			uci set mwan3config.$wanconfigname7.check_quality=$WIFIcheck_quality_failover
			uci set mwan3config.$wanconfigname7.failure_latency=$WIFIfailure_latency_failover
			uci set mwan3config.$wanconfigname7.recovery_latency=$WIFIrecovery_latency_failover
			uci set mwan3config.$wanconfigname7.failure_loss=$WIFIfailure_loss_failover
			uci set mwan3config.$wanconfigname7.recovery_loss=$WIFIrecovery_loss_failover
			uci set mwan3config.$wanconfigname7.initial_state=$WIFIinitial_state_failover
			if [ "$WIFIvalidtrackip_failover_failover" =  "1" ]
			then 
				uci set mwan3config.$wanconfigname7.trackIp1="$WIFItrackIp1_failover"
			fi
			if [ "$WIFIvalidtrackip_failover" =  "2" ]
			then 
				uci set mwan3config.$wanconfigname7.trackIp1="$WIFItrackIp1_failover"
				uci set mwan3config.$wanconfigname7.trackIp2="$WIFItrackIp2_failover"
			fi
			if [ "$WIFIvalidtrackip_failover" =  "3" ]
			then 
				uci set mwan3config.$wanconfigname7.trackIp1="$WIFItrackIp1_failover"
				uci set mwan3config.$wanconfigname7.trackIp2="$WIFItrackIp2_failover"
				uci set mwan3config.$wanconfigname7.trackIp3="$WIFItrackIp3_failover"
			fi
			if [ "$WIFIvalidtrackip_failover" =  "4" ]
			then            
				uci set mwan3config.$wanconfigname7.trackIp1="$WIFItrackIp1_failover"
				uci set mwan3config.$wanconfigname7.trackIp2="$WIFItrackIp2_failover"
				uci set mwan3config.$wanconfigname7.trackIp3="$WIFItrackIp3_failover"
				uci set mwan3config.$wanconfigname7.trackIp4="$WIFItrackIp4_failover"
			fi
			uci set mwan3config.$wanconfigname7.reliability="$WIFIreliability_failover"
			uci set mwan3config.$wanconfigname7.count="$WIFIcount_failover"
			uci set mwan3config.$wanconfigname7.up="$WIFIup_failover"
			uci set mwan3config.$wanconfigname7.down="$WIFIdown_failover"     
		else    
			uci set mwan3config.$wanconfigname7.enabled=1
			uci set mwan3config.$wanconfigname7.wanpriority=4
			uci set mwan3config.$wanconfigname7.track_method="ping"
			uci set mwan3config.$wanconfigname7.validtrackip=2
			uci set mwan3config.$wanconfigname7.trackIp1=8.8.8.8
			uci set mwan3config.$wanconfigname7.trackIp2=8.8.4.4
			uci set mwan3config.$wanconfigname7.reliability=1
			uci set mwan3config.$wanconfigname7.count=3
			uci set mwan3config.$wanconfigname7.up=3
			uci set mwan3config.$wanconfigname7.down=3
			uci set mwan3config.$wanconfigname7.flush_conntrack=1
			uci set mwan3config.$wanconfigname7.timeout=2
			uci set mwan3config.$wanconfigname7.interval=2
		fi	
		
		count=$((count + 1))
		echo "Count = $count"
	fi 

		echo "Final Count = $count"
		echo "$count" > "wancount.txt"
    
	uci commit mwan3config
	logger -t config -p customs.info "mwan3config configuration changed"

  #fi		
}


ReadOldWeight_LoadBalancing()
{
  
  #if [ "$Select" =  "balanced" ]
  #then	
	
  config=$1
  config_get WanWeight "$config" wanweight
  config_get enabled "$config" enabled
  config_get track_method "$config" track_method
  config_get validtrackip "$config" validtrackip
  config_get trackIp1 "$config" trackIp1
  config_get trackIp2 "$config" trackIp2
  config_get trackIp3 "$config" trackIp3
  config_get trackIp4 "$config" trackIp4
  config_get reliability "$config" reliability
  config_get count "$config" count
  config_get up "$config" up
  config_get down "$config" down
  config_get flush_conntrack "$config" flush_conntrack
  config_get timeout "$config" timeout
  config_get interval "$config" interval
  config_get check_quality "$config" check_quality
  config_get failure_latency "$config" failure_latency
  config_get recovery_latency "$config" recovery_latency
  config_get failure_loss "$config" failure_loss
  config_get recovery_loss "$config" recovery_loss
  config_get initial_state "$config" initial_state
  
  
  case "$config" in
   "CWAN1") 
			CWAN1weight=$WanWeight
			CWAN1validtrackip=$validtrackip
			CWAN1enabled=$enabled
            CWAN1trackmethod=$track_method 
            CWAN1flush_conntrack=$flush_conntrack
            CWAN1timeout=$timeout
            CWAN1interval=$interval
            CWAN1check_quality=$check_quality
            CWAN1failure_latency=$failure_latency
            CWAN1frecovery_latency=$recovery_latency
            CWAN1failure_loss=$failure_loss
            CWAN1recovery_loss=$recovery_loss
            echo $CWAN1trackmethod  
				if [ $CWAN1validtrackip = "1" ]
				then
					CWAN1trackIp1=$trackIp1
				fi
				if [ $CWAN1validtrackip = "2" ]
				then
					CWAN1trackIp1=$trackIp1
					CWAN1trackIp2=$trackIp2
				fi
				if [ $CWAN1validtrackip = "3" ]
				then
					CWAN1trackIp1=$trackIp1
					CWAN1trackIp2=$trackIp2
					CWAN1trackIp3=$trackIp3
				fi
				if [ $CWAN1validtrackip = "4" ]
				then
					CWAN1trackIp1=$trackIp1
					CWAN1trackIp2=$trackIp2
					CWAN1trackIp3=$trackIp3
					CWAN1trackIp4=$trackIp4
				fi
				CWAN1up=$up
				CWAN1down=$down
				CWAN1reliability=$reliability
				CWAN1count=$count

			;;
	"wan6c1")		         
			CWAN1V6_0weight=$WanWeight
			CWAN1V6_0validtrackip=$validtrackip
			CWAN1V6_0enabled=$enabled 
            CWAN1V6_0trackmethod=$track_method 
            CWAN1V6_0flush_conntrack=$flush_conntrack
            CWAN1V6_0timeout=$timeout
            CWAN1V6_0interval=$interval
            CWAN1V6_0check_quality=$check_quality
            CWAN1V6_0failure_latency=$failure_latency
            CWAN1V6_0frecovery_latency=$recovery_latency
            CWAN1V6_0failure_loss=$failure_loss
            CWAN1V6_0recovery_loss=$recovery_loss	 		
			if [ $CWAN1V6_0validtrackip = "1" ]
			then
				CWAN1V6_0trackIp1=$trackIp1
			fi
			if [ $CWAN1V6_0validtrackip = "2" ]
			then
				CWAN1V6_0trackIp1=$trackIp1
				CWAN1V6_0trackIp2=$trackIp2
			fi
			if [ $CWAN1V6_0validtrackip = "3" ]
			then
				CWAN1V6_0trackIp1=$trackIp1
				CWAN1V6_0trackIp2=$trackIp2
				CWAN1V6_0trackIp3=$trackIp3
			fi
			if [ $CWAN1V6_0validtrackip = "4" ]
			then
				CWAN1V6_0trackIp1=$trackIp1
				CWAN1V6_0trackIp2=$trackIp2
				CWAN1V6_0trackIp3=$trackIp3
				CWAN1V6_0trackIp4=$trackIp4
			fi
					CWAN1V6_0up=$up
					CWAN1V6_0down=$down
					CWAN1V6_0reliability=$reliability
					CWAN1V6_0count=$count			
			;;
   "CWAN2") 
			CWAN2weight=$WanWeight
			CWAN2enabled=$enabled 
			CWAN2trackIp1=$trackIp1
			CWAN2trackIp2=$trackIp2
			CWAN2trackIp3=$trackIp3
			CWAN2trackIp4=$trackIp4
			CWAN2flush_conntrack=$flush_conntrack

            CWAN2timeout=$timeout
            CWAN2interval=$interval
            CWAN2check_quality=$check_quality
            CWAN2failure_latency=$failure_latency
            CWAN2frecovery_latency=$recovery_latency
            CWAN2failure_loss=$failure_loss
            CWAN2recovery_loss=$recovery_loss
			;;
   "CWAN1_0") 
			CWAN1_0weight=$WanWeight
			CWAN1_0validtrackip=$validtrackip
			CWAN1_0enabled=$enabled
            CWAN1_0trackmethod=$track_method
            CWAN1_0flush_conntrack=$flush_conntrack  

            CWAN1_0timeout=$timeout
            CWAN1_0interval=$interval
            CWAN1_0check_quality=$check_quality
            CWAN1_0failure_latency=$failure_latency
            CWAN1_0recovery_latency=$recovery_latency
            CWAN1_0failure_loss=$failure_loss
            CWAN1_0recovery_loss=$recovery_loss                  
				if [ $CWAN1_0validtrackip = "1" ]
				then
					CWAN1_0trackIp1=$trackIp1
				fi
				if [ $CWAN1_0validtrackip = "2" ]
				then
					CWAN1_0trackIp1=$trackIp1
					CWAN1_0trackIp2=$trackIp2
				fi
				if [ $CWAN1_0validtrackip = "3" ]
				then
					CWAN1_0trackIp1=$trackIp1
					CWAN1_0trackIp2=$trackIp2
					CWAN1_0trackIp3=$trackIp3
				fi
				if [ $CWAN1_0validtrackip = "4" ]
				then
					CWAN1_0trackIp1=$trackIp1
					CWAN1_0trackIp2=$trackIp2
					CWAN1_0trackIp3=$trackIp3
					CWAN1_0trackIp4=$trackIp4
				fi
				CWAN1_0up=$up
				CWAN1_0down=$down
				CWAN1_0reliability=$reliability
				CWAN1_0count=$count

				;;
	"wan6c2")			
			CWAN1V6_1weight=$WanWeight
			CWAN1V6_1validtrackip=$validtrackip
			CWAN1V6_1enabled=$enabled
            CWAN1V6_1trackmethod=$track_method
            CWAN1V6_1flush_conntrack=$flush_conntrack 

            CWAN1V6_1timeout=$timeout
            CWAN1V6_1interval=$interval
            CWAN1V6_1check_quality=$check_quality
            CWAN1V6_1failure_latency=$failure_latency
            CWAN1V6_1recovery_latency=$recovery_latency
            CWAN1V6_1failure_loss=$failure_loss
            CWAN1V6_1recovery_loss=$recovery_loss	    
				if [ $CWAN1V6_1validtrackip = "1" ]
				then
					CWAN1V6_1trackIp1=$trackIp1
				fi
				if [ $CWAN1V6_1validtrackip = "2" ]
				then
					CWAN1V6_1trackIp1=$trackIp1
					CWAN1V6_1trackIp2=$trackIp2
				fi
				if [ $CWAN1_0validtrackip = "3" ]
				then
					CWAN1V6_1trackIp1=$trackIp1
					CWAN1V6_1trackIp2=$trackIp2
					CWAN1V6_1trackIp3=$trackIp3
				fi
				if [ $CWAN1V6_1validtrackip = "4" ]
				then
					CWAN1V6_1trackIp1=$trackIp1
					CWAN1V6_1trackIp2=$trackIp2
					CWAN1V6_1trackIp3=$trackIp3
					CWAN1V6_1trackIp4=$trackIp4
				fi
				CWAN1V6_1up=$up
				CWAN1V6_1down=$down
				CWAN1V6_1reliability=$reliability
				CWAN1V6_1count=$count          
		  
			;;
   "CWAN1_1") 
			CWAN1_1weight=$WanWeight
			CWAN1_1validtrackip=$validtrackip
			CWAN1_1enabled=$enabled
            CWAN1_1trackmethod=$track_method 
            CWAN1_1flush_conntrack=$flush_conntrack  

            CWAN1_1timeout=$timeout
            CWAN1_1interval=$interval
            CWAN1_1check_quality=$check_quality
            CWAN1_1failure_latency=$failure_latency
            CWAN1_1recovery_latency=$recovery_latency
            CWAN1_1failure_loss=$failure_loss
            CWAN1_1recovery_loss=$recovery_loss                   
			if [ $CWAN1_1validtrackip = "1" ]
			then
				CWAN1_1trackIp1=$trackIp1
			fi
			if [ $CWAN1_1validtrackip = "2" ]
			then
				CWAN1_1trackIp1=$trackIp1
				CWAN1_1trackIp2=$trackIp2
			fi
			if [ $CWAN1_1validtrackip = "3" ]
			then
				CWAN1_1trackIp1=$trackIp1
				CWAN1_1trackIp2=$trackIp2
				CWAN1_1trackIp3=$trackIp3
			fi
			if [ $CWAN1_0validtrackip = "4" ]
			then
				CWAN1_1trackIp1=$trackIp1
				CWAN1_1trackIp2=$trackIp2
				CWAN1_1trackIp3=$trackIp3
				CWAN1_1trackIp4=$trackIp4
			fi
			CWAN1_1up=$up
			CWAN1_1down=$down
			CWAN1_1reliability=$reliability
			CWAN1_1count=$count

			;;
   "WIFI_WAN")                  
				WIFIweight=$WanWeight
				WIFIvalidtrackip=$validtrackip
				WIFIenabled=$enabled 
                WIFItrackmethod=$track_method 
                WIFIflush_conntrack=$flush_conntrack

				WIFItimeout=$timeout
				WIFIinterval=$interval
				WIFIcheck_quality=$check_quality
				WIFIfailure_latency=$failure_latency
				WIFIrecovery_latency=$recovery_latency
				WIFIfailure_loss=$failure_loss
				WIFIrecovery_loss=$recovery_loss
				WIFIinitial_state=$initial_state
				if [ $WIFIvalidtrackip = "1" ]
				then
					WIFItrackIp1=$trackIp1
				fi
				if [ $WIFIvalidtrackip = "2" ]
				then
					WIFItrackIp1=$trackIp1
					WIFItrackIp2=$trackIp2
				fi
				if [ $WIFIvalidtrackip = "3" ]
				then
					WIFItrackIp1=$trackIp1
					WIFItrackIp2=$trackIp2
					WIFItrackIp3=$trackIp3
				fi
				if [ $WIFIvalidtrackip = "4" ]
				then
					WIFItrackIp1=$trackIp1
					WIFItrackIp2=$trackIp2
					WIFItrackIp3=$trackIp3
					WIFItrackIp4=$trackIp4
				fi
				WIFIup=$up
				WIFIdown=$down
				WIFIreliability=$reliability
				WIFIcount=$count

					;;
esac

echo "CWAN1weight=$CWAN1weight"
echo "CWAN2weight=$CWAN2weight"
echo "CWAN1_0weight=$CWAN1_0weight"
echo "CWAN1_1weight=$CWAN1_1weight"
echo "WIFIweight=$WIFIweight"
 
 #fi

}

SetWeight_LoadBalancing()
{  
  #if [ "$Select" =  "balanced" ]
  #then		
	
	if [ "$enablecellular" = "1" ]
	then     
		if [ "$CellularOperationMode" = "dualcellularsinglesim" ]
		then
			uci set loadbalancingconfig."$wanconfigname3"=loadbalancingconfig
			uci set loadbalancingconfig.$wanconfigname3.name=$wanconfigname3
            uci set loadbalancingconfig.$wanconfigname3.track_method=$CWAN1trackmethod
            uci set loadbalancingconfig.$wanconfigname3.flush_conntrack=$CWAN1flush_conntrack

			uci set loadbalancingconfig.$wanconfigname3.timeout=$CWAN1timeout
			uci set loadbalancingconfig.$wanconfigname3.interval=$CWAN1interval
			uci set loadbalancingconfig.$wanconfigname3.check_quality=$CWAN1check_quality
			uci set loadbalancingconfig.$wanconfigname3.failure_latency=$CWAN1failure_latency
			uci set loadbalancingconfig.$wanconfigname3.recovery_latency=$CWAN1recovery_latency
			uci set loadbalancingconfig.$wanconfigname3.failure_loss=$CWAN1failure_loss
			uci set loadbalancingconfig.$wanconfigname3.recovery_loss=$CWAN1recovery_loss
			if [[ $CWAN1weight != 0 ]]
			then
				uci set loadbalancingconfig.$wanconfigname3.wanweight=$CWAN1weight
				uci set loadbalancingconfig.$wanconfigname3.trackIp1=$CWAN1trackIp1
				uci set loadbalancingconfig.$wanconfigname3.trackIp2=$CWAN1trackIp2
				uci set loadbalancingconfig.$wanconfigname3.trackIp3=$CWAN1trackIp3
				uci set loadbalancingconfig.$wanconfigname3.trackIp4=$CWAN1trackIp4
			else    
				uci set loadbalancingconfig.$wanconfigname3.enabled=1
				uci set loadbalancingconfig.$wanconfigname3.wanweight=30
				uci set loadbalancingconfig.$wanconfigname3.trackIp1=8.8.8.8
				uci set loadbalancingconfig.$wanconfigname3.trackIp2=8.8.4.4
				uci set loadbalancingconfig.$wanconfigname3.trackIp3=208.67.220.220
				uci set loadbalancingconfig.$wanconfigname3.trackIp4=208.67.222.222
				uci set loadbalancingconfig.$wanconfigname3.timeout=2
				uci set loadbalancingconfig.$wanconfigname3.interval=2
			fi                   
				count=$((count + 1))
				echo "Count = $count"
				
				uci set loadbalancingconfig."$wanconfigname4"=loadbalancingconfig
				uci set loadbalancingconfig.$wanconfigname4.name=$wanconfigname4
				uci set loadbalancingconfig.$wanconfigname4.flush_conntrack=$CWAN2flush_conntrack

				uci set loadbalancingconfig.$wanconfigname4.timeout=$CWAN2timeout
				uci set loadbalancingconfig.$wanconfigname4.interval=$CWAN2interval
				uci set loadbalancingconfig.$wanconfigname4.check_quality=$CWAN2check_quality
				uci set loadbalancingconfig.$wanconfigname4.failure_latency=$CWAN2failure_latency
				uci set loadbalancingconfig.$wanconfigname4.recovery_latency=$CWAN2recovery_latency
				uci set loadbalancingconfig.$wanconfigname4.failure_loss=$CWAN2failure_loss
				uci set loadbalancingconfig.$wanconfigname4.recovery_loss=$CWAN2recovery_loss
				if [[ $CWAN2weight != 0 ]]
				then
					uci set loadbalancingconfig.$wanconfigname4.wanweight=$CWAN2weight
					uci set loadbalancingconfig.$wanconfigname4.trackIp1=$CWAN2trackIp1
					uci set loadbalancingconfig.$wanconfigname4.trackIp2=$CWAN2trackIp2
					uci set loadbalancingconfig.$wanconfigname4.trackIp3=$CWAN2trackIp3
					uci set loadbalancingconfig.$wanconfigname4.trackIp4=$CWAN2trackIp4
				else    
					uci set loadbalancingconfig.$wanconfigname4.enabled=1
					uci set loadbalancingconfig.$wanconfigname4.track_method="ping"
					uci set loadbalancingconfig.$wanconfigname4.wanweight=30                 
					uci set loadbalancingconfig.$wanconfigname4.trackIp1=8.8.8.8
					uci set loadbalancingconfig.$wanconfigname4.trackIp2=8.8.4.4
					uci set loadbalancingconfig.$wanconfigname4.trackIp3=208.67.220.220
					uci set loadbalancingconfig.$wanconfigname4.trackIp4=208.67.222.222
					uci set loadbalancingconfig.$wanconfigname4.timeout=2
					uci set loadbalancingconfig.$wanconfigname4.interval=2
				fi
				count=$((count + 1))
				echo "Count = $count"
		fi
			 
		if [ "$CellularOperationMode" = "singlecellulardualsim" ]
		then
		    if [ "$PDP1" = "IPV4" ] || [ "$PDP1" = "IPV4V6" ]
			then
				uci set loadbalancingconfig.$wanconfigname5=loadbalancingconfig
				uci set loadbalancingconfig.$wanconfigname5.name=$wanconfigname5
                uci set loadbalancingconfig.$wanconfigname5.track_method=$CWAN1_0trackmethod
				if [[ $CWAN1_0weight != 0 ]]
				then
					uci set loadbalancingconfig.$wanconfigname5.wanweight=$CWAN1_0weight
					uci set loadbalancingconfig.$wanconfigname5.validtrackip=$CWAN1_0validtrackip
					uci set loadbalancingconfig.$wanconfigname5.enabled=$CWAN1_0enabled
					uci set loadbalancingconfig.$wanconfigname5.flush_conntrack=$CWAN1_0flush_conntrack 

					uci set loadbalancingconfig.$wanconfigname5.timeout=$CWAN1_0timeout
					uci set loadbalancingconfig.$wanconfigname5.interval=$CWAN1_0interval
					uci set loadbalancingconfig.$wanconfigname5.check_quality=$CWAN1_0check_quality
					uci set loadbalancingconfig.$wanconfigname5.failure_latency=$CWAN1_0failure_latency
					uci set loadbalancingconfig.$wanconfigname5.recovery_latency=$CWAN1_0recovery_latency
					uci set loadbalancingconfig.$wanconfigname5.failure_loss=$CWAN1_0failure_loss
					uci set loadbalancingconfig.$wanconfigname5.recovery_loss=$CWAN1_0recovery_loss  
						if [ "$CWAN1_0validtrackip" =  "1" ]
					then 
						uci set loadbalancingconfig.$wanconfigname5.trackIp1="$CWAN1_0trackIp1"
					fi
					if [ "$CWAN1_0validtrackip" =  "2" ]
					then 
						uci set loadbalancingconfig.$wanconfigname5.trackIp1="$CWAN1_0trackIp1"
						uci set loadbalancingconfig.$wanconfigname5.trackIp2="$CWAN1_0trackIp2"
					fi
			
					if [ "$CWAN1_0validtrackip" =  "3" ]
					then 
						uci set loadbalancingconfig.$wanconfigname5.trackIp1="$CWAN1_0trackIp1"
						uci set loadbalancingconfig.$wanconfigname5.trackIp2="$CWAN1_0trackIp2"
						uci set loadbalancingconfig.$wanconfigname5.trackIp3="$CWAN1_0trackIp3"
					fi
					if [ "$CWAN1_0validtrackip" =  "4" ]
					then            
						uci set loadbalancingconfig.$wanconfigname5.trackIp1="$CWAN1_0trackIp1"
						uci set loadbalancingconfig.$wanconfigname5.trackIp2="$CWAN1_0trackIp2"
						uci set loadbalancingconfig.$wanconfigname5.trackIp3="$CWAN1_0trackIp3"
						uci set loadbalancingconfig.$wanconfigname5.trackIp4="$CWAN1_0trackIp4"
					fi
					uci set loadbalancingconfig.$wanconfigname5.reliability="$CWAN1_0reliability"
					uci set loadbalancingconfig.$wanconfigname5.count="$CWAN1_0count"

					uci set loadbalancingconfig.$wanconfigname5.up="$CWAN1_0up"
					uci set loadbalancingconfig.$wanconfigname5.down="$CWAN1_0down"
				else    
					uci set loadbalancingconfig.$wanconfigname5.enabled=1
					uci set loadbalancingconfig.$wanconfigname5.track_method="ping"
					uci set loadbalancingconfig.$wanconfigname5.wanweight=30
					uci set loadbalancingconfig.$wanconfigname5.validtrackip=2
					uci set loadbalancingconfig.$wanconfigname5.trackIp1=8.8.8.8
					uci set loadbalancingconfig.$wanconfigname5.trackIp2=8.8.4.4
					uci set loadbalancingconfig.$wanconfigname5.reliability=1
					uci set loadbalancingconfig.$wanconfigname5.count=3
					uci set loadbalancingconfig.$wanconfigname5.up=3
					uci set loadbalancingconfig.$wanconfigname5.down=3
					uci set loadbalancingconfig.$wanconfigname5.timeout=2
					uci set loadbalancingconfig.$wanconfigname5.interval=2
				fi	  
				count=$((count + 1))
				echo "Count = $count"
			fi					  
			#IPV6 update for wan6c1(Dual sim single modem)
			if [ "$PDP1" = "IPV6" ]
			then	
				uci set loadbalancingconfig."$wan6configname3"=loadbalancingconfig
				uci set loadbalancingconfig."$wan6configname3".name=$wan6configname3
                uci set loadbalancingconfig.$wan6configname3.track_method=$CWAN1V6_0trackmethod
                uci set loadbalancingconfig.$wan6configname3.flush_conntrack=$CWAN1V6_0flush_conntrack

				uci set loadbalancingconfig.$wan6configname3.timeout=$CWAN1V6_0timeout
				uci set loadbalancingconfig.$wan6configname3.interval=$CWAN1V6_0interval
				uci set loadbalancingconfig.$wan6configname3.check_quality=$CWAN1V6_0check_quality
				uci set loadbalancingconfig.$wan6configname3.failure_latency=$CWAN1V6_0failure_latency
				uci set loadbalancingconfig.$wan6configname3.recovery_latency=$CWAN1V6_0recovery_latency
				uci set loadbalancingconfig.$wan6configname3.failure_loss=$CWAN1V6_0failure_loss
				uci set loadbalancingconfig.$wan6configname3.recovery_loss=$CWAN1V6_0recovery_loss  
				if [[ $CWAN1V6_0weight != 0 ]]
				then
					uci set loadbalancingconfig.$wan6configname3.wanweight=$CWAN1V6_0weight
					uci set loadbalancingconfig.$wan6configname3.validtrackip=$CWAN1V6_0validtrackip
					uci set loadbalancingconfig.$wan6configname3.enabled=$CWAN1V6_0enabled
					if [ "$CWAN1V6_0validtrackip" =  "1" ]
					then 
						uci set loadbalancingconfig.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
					fi
					if [ "$CWAN1V6_0validtrackip" =  "2" ]
					then 
						uci set loadbalancingconfig.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set loadbalancingconfig.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
					fi
			
					if [ "$CWAN1V6_0validtrackip" =  "3" ]
					then 
						uci set loadbalancingconfig.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set loadbalancingconfig.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
						uci set loadbalancingconfig.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3"
					fi
					if [ "$CWAN1V6_0validtrackip" =  "4" ]
					then            
						uci set loadbalancingconfig.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set loadbalancingconfig.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
						uci set loadbalancingconfig.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3"
						uci set loadbalancingconfig.$wan6configname3.trackIp4="$CWAN1V6_0trackIp4"
					fi
						uci set loadbalancingconfig.$wan6configname3.reliability="$CWAN1V6_0reliability"
						uci set loadbalancingconfig.$wan6configname3.count="$CWAN1V6_0count"

						uci set loadbalancingconfig.$wan6configname3.up="$CWAN1V6_0up"
						uci set loadbalancingconfig.$wan6configname3.down="$CWAN1V6_0down"       
				else    
					uci set loadbalancingconfig.$wan6configname3.enabled=1
                    uci set loadbalancingconfig.$wan6configname3.track_method="ping"
					uci set loadbalancingconfig.$wan6configname3.wanweight=30
					uci set loadbalancingconfig.$wan6configname3.validtrackip=2
					uci set loadbalancingconfig.$wan6configname3.trackIp1=2001:4860:4860::8888
					uci set loadbalancingconfig.$wan6configname3.trackIp2=2001:4860:4860::8844
					uci set loadbalancingconfig.$wan6configname3.reliability=1
					uci set loadbalancingconfig.$wan6configname3.count=3
					uci set loadbalancingconfig.$wan6configname3.up=3
					uci set loadbalancingconfig.$wan6configname3.down=3
					uci set loadbalancingconfig.$wan6configname3.timeout=4
					uci set loadbalancingconfig.$wan6configname3.interval=2
				fi				  
					count=$((count + 1))
					echo "Count = $count"
					uci set loadbalancingconfig				
			fi 
			
			#sim2 priorioty 
			if [ "$PDP2" = "IPV4" ] || [ "$PDP2" = "IPV4V6" ] 
			then
				uci set loadbalancingconfig."$wanconfigname6"=loadbalancingconfig
				uci set loadbalancingconfig.$wanconfigname6.name=$wanconfigname6 
                uci set loadbalancingconfig.$wanconfigname6.track_method=$CWAN1_1trackmethod   		   
				if [[ $CWAN1_1weight != 0 ]]
				then
				 
					uci set loadbalancingconfig.$wanconfigname6.wanweight=$CWAN1_1weight
					uci set loadbalancingconfig.$wanconfigname6.validtrackip=$CWAN1_1validtrackip
					uci set loadbalancingconfig.$wanconfigname6.enabled=$CWAN1_1enabled
					uci set loadbalancingconfig.$wanconfigname6.flush_conntrack=$CWAN1_1flush_conntrack

					uci set loadbalancingconfig.$wanconfigname6.timeout=$CWAN1_1timeout
					uci set loadbalancingconfig.$wanconfigname6.interval=$CWAN1_1interval
					uci set loadbalancingconfig.$wanconfigname6.check_quality=$CWAN1_1check_quality
					uci set loadbalancingconfig.$wanconfigname6.failure_latency=$CWAN1_1failure_latency
					uci set loadbalancingconfig.$wanconfigname6.recovery_latency=$CWAN1_1recovery_latency
					uci set loadbalancingconfig.$wanconfigname6.failure_loss=$CWAN1_1failure_loss
					uci set loadbalancingconfig.$wanconfigname6.recovery_loss=$CWAN1_1recovery_loss   
					if [ "$CWAN1_1validtrackip" =  "1" ]
					then 
						uci set loadbalancingconfig.$wanconfigname6.trackIp1="$CWAN1_1trackIp1"
					fi
					if [ "$CWAN1_1validtrackip" =  "2" ]
					then 
						uci set loadbalancingconfig.$wanconfigname6.trackIp1="$CWAN1_1trackIp1"
						uci set loadbalancingconfig.$wanconfigname6.trackIp2="$CWAN1_1trackIp2"
					fi
					if [ "$CWAN1_1validtrackip" =  "3" ]
					then 
						uci set loadbalancingconfig.$wanconfigname6.trackIp1="$CWAN1_1trackIp1"
						uci set loadbalancingconfig.$wanconfigname6.trackIp2="$CWAN1_1trackIp2"
						uci set loadbalancingconfig.$wanconfigname6.trackIp3="$CWAN1_1trackIp3"
					fi
					if [ "$CWAN1_1validtrackip" =  "4" ]
					then             
						uci set loadbalancingconfig.$wanconfigname6.trackIp1="$CWAN1_1trackIp1"
						uci set loadbalancingconfig.$wanconfigname6.trackIp2="$CWAN1_1trackIp2"
						uci set loadbalancingconfig.$wanconfigname6.trackIp3="$CWAN1_1trackIp3"
						uci set loadbalancingconfig.$wanconfigname6.trackIp4="$CWAN1_1trackIp4"
					fi
					uci set loadbalancingconfig.$wanconfigname6.reliability="$CWAN1_1reliability"
					uci set loadbalancingconfig.$wanconfigname6.count="$CWAN1_1count"

					uci set loadbalancingconfig.$wanconfigname6.up="$CWAN1_1up"
					uci set loadbalancingconfig.$wanconfigname6.down="$CWAN1_1down"
				else  
					uci set loadbalancingconfig.$wanconfigname6.enabled=1
                    uci set loadbalancingconfig.$wanconfigname6.track_method="ping"
					uci set loadbalancingconfig.$wanconfigname6.wanweight=30
					uci set loadbalancingconfig.$wanconfigname6.validtrackip=2
					uci set loadbalancingconfig.$wanconfigname6.trackIp1=8.8.8.8
					uci set loadbalancingconfig.$wanconfigname6.trackIp2=8.8.4.4
					uci set loadbalancingconfig.$wanconfigname6.reliability=1
					uci set loadbalancingconfig.$wanconfigname6.count=3
					uci set loadbalancingconfig.$wanconfigname6.up=3
					uci set loadbalancingconfig.$wanconfigname6.down=3
					uci set loadbalancingconfig.$wanconfigname6.timeout=2
					uci set loadbalancingconfig.$wanconfigname6.interval=2
				fi
				count=$((count + 1))
				echo "Count = $count"  
			fi 
				#IPV6 update for sim2 
			if [ "$PDP2" = "IPV6" ]
			then   
				uci set loadbalancingconfig."$wan6configname4"=loadbalancingconfig
				uci set loadbalancingconfig.$wan6configname4.name=$wan6configname4  
                uci set loadbalancingconfig.$wan6configname4.track_method=$CWAN1V6_1trackmethod
				if [[ $CWAN1V6_1weight != 0 ]]
				then
					uci set loadbalancingconfig.$wan6configname4.wanweight=$CWAN1V6_1weight
					uci set loadbalancingconfig.$wan6configname4.validtrackip=$CWAN1V6_1validtrackip
					uci set loadbalancingconfig.$wan6configname4.enabled=$CWAN1V6_1enabled
					uci set loadbalancingconfig.$wan6configname4.flush_conntrack=$CWAN1V6_1flush_conntrack

					uci set loadbalancingconfig.$wan6configname4.timeout=$CWAN1V6_1timeout
					uci set loadbalancingconfig.$wan6configname4.interval=$CWAN1V6_1interval
					uci set loadbalancingconfig.$wan6configname4.check_quality=$CWAN1V6_1check_quality
					uci set loadbalancingconfig.$wan6configname4.failure_latency=$CWAN1V6_1failure_latency
					uci set loadbalancingconfig.$wan6configname4.recovery_latency=$CWAN1V6_1recovery_latency
					uci set loadbalancingconfig.$wan6configname4.failure_loss=$CWAN1V6_1failure_loss
					uci set loadbalancingconfig.$wan6configname4.recovery_loss=$CWAN1V6_1recovery_loss   
					if [ "$CWAN1V6_1validtrackip" =  "1" ]
					then 
						uci set loadbalancingconfig.$wan6configname4.trackIp1="$CWAN1V6_1trackIp1"
					fi
					if [ "$CWAN1V6_1validtrackip" =  "2" ]
					then 
						uci set loadbalancingconfig.$wan6configname4.trackIp1="$CWAN1V6_1trackIp1"
						uci set loadbalancingconfig.$wan6configname4.trackIp2="$CWAN1V6_1trackIp2"
					fi
					if [ "$CWAN1V6_1validtrackip" =  "3" ]
					then 
						uci set loadbalancingconfig.$wan6configname4.trackIp1="$CWAN1V6_1trackIp1"
						uci set loadbalancingconfig.$wan6configname4.trackIp2="$CWAN1V6_1trackIp2"
						uci set loadbalancingconfig.$wan6configname4.trackIp3="$CWAN1V6_1trackIp3"
					fi
					if [ "$CWAN1V6_1validtrackip" =  "4" ]
					then             
						uci set loadbalancingconfig.$wan6configname4.trackIp1="$CWAN1V6_1trackIp1"
						uci set loadbalancingconfig.$wan6configname4.trackIp2="$CWAN1V6_1trackIp2"
						uci set loadbalancingconfig.$wan6configname4.trackIp3="$CWAN1V6_1trackIp3"
						uci set loadbalancingconfig.$wan6configname4.trackIp4="$CWAN1V6_1trackIp4"
					fi
					uci set loadbalancingconfig.$wan6configname4.reliability="$CWAN1V6_1reliability"
					uci set loadbalancingconfig.$wan6configname4.count="$CWAN1V6_1count"

					uci set loadbalancingconfig.$wan6configname4.up="$CWAN1V6_1up"
					uci set loadbalancingconfig.$wan6configname4.down="$CWAN1V6_1down"
				else  
					uci set loadbalancingconfig.$wan6configname4.enabled=1
                    uci set loadbalancingconfig.$wan6configname4.track_method="ping"
					uci set loadbalancingconfig.$wan6configname4.wanweight=30
					uci set loadbalancingconfig.$wan6configname4.validtrackip=2
					uci set loadbalancingconfig.$wan6configname4.trackIp1=2001:4860:4860::8888
					uci set loadbalancingconfig.$wan6configname4.trackIp2=2001:4860:4860::8844
					uci set loadbalancingconfig.$wan6configname4.reliability=1
					uci set loadbalancingconfig.$wan6configname4.count=3
					uci set loadbalancingconfig.$wan6configname4.up=3
					uci set loadbalancingconfig.$wan6configname4.down=3
					uci set loadbalancingconfig.$wan6configname4.timeout=4
					uci set loadbalancingconfig.$wan6configname4.interval=2
				fi	
				count=$((count + 1))
				echo "Count = $count"			
			fi   
				 
		fi	
				#################################################
		if [ "$CellularOperationMode" = "singlecellularsinglesim" ]
		then
			#IPV6 only for sssm
			#IPV6 update for wan6c1(single sim single modem)
			if [ "$PDP1" = "IPV6" ]
			then
			    uci delete mwan3.default_rule
				uci set loadbalancingconfig."$wan6configname3"=loadbalancingconfig
				uci set loadbalancingconfig."$wan6configname3".name=$wan6configname3
                uci set loadbalancingconfig.$wan6configname3.track_method=$CWAN1V6_0trackmethod
				if [[ $CWAN1V6_0weight != 0 ]]
				then
					uci set loadbalancingconfig.$wan6configname3.wanweight=$CWAN1V6_0weight
					uci set loadbalancingconfig.$wan6configname3.validtrackip=$CWAN1V6_0validtrackip
					uci set loadbalancingconfig.$wan6configname3.enabled=$CWAN1V6_0enabled
					uci set loadbalancingconfig.$wan6configname3.flush_conntrack=$CWAN1V6_0flush_conntrack

					uci set loadbalancingconfig.$wan6configname3.timeout=$CWAN1V6_0timeout
					uci set loadbalancingconfig.$wan6configname3.interval=$CWAN1V6_0interval
					uci set loadbalancingconfig.$wan6configname3.check_quality=$CWAN1V6_0check_quality
					uci set loadbalancingconfig.$wan6configname3.failure_latency=$CWAN1V6_0failure_latency
					uci set loadbalancingconfig.$wan6configname3.recovery_latency=$CWAN1V6_0recovery_latency
					uci set loadbalancingconfig.$wan6configname3.failure_loss=$CWAN1V6_0failure_loss
					uci set loadbalancingconfig.$wan6configname3.recovery_loss=$CWAN1V6_0recovery_loss 
					if [ "$CWAN1V6_0validtrackip" =  "1" ]
					then 
						uci set loadbalancingconfig.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
					fi
					if [ "$CWAN1V6_0validtrackip" =  "2" ]
					then 
						uci set loadbalancingconfig.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set loadbalancingconfig.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
					fi
			
					if [ "$CWAN1V6_0validtrackip" =  "3" ]
					then 
						uci set loadbalancingconfig.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set loadbalancingconfig.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
						uci set loadbalancingconfig.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3"
					fi
					if [ "$CWAN1V6_0validtrackip" =  "4" ]
					then            
						uci set loadbalancingconfig.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set loadbalancingconfig.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
						uci set loadbalancingconfig.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3"
						uci set loadbalancingconfig.$wan6configname3.trackIp4="$CWAN1V6_0trackIp4"
					fi
					uci set loadbalancingconfig.$wan6configname3.reliability="$CWAN1V6_0reliability"
					uci set loadbalancingconfig.$wan6configname3.count="$CWAN1V6_0count"

					uci set loadbalancingconfig.$wan6configname3.up="$CWAN1V6_0up"
					uci set loadbalancingconfig.$wan6configname3.down="$CWAN1V6_0down"       
				else    
					uci set loadbalancingconfig.$wan6configname3.enabled=1
					uci set loadbalancingconfig.$wan6configname3.wanweight=30
                    uci set loadbalancingconfig.$wan6configname3.track_method="ping"
					uci set loadbalancingconfig.$wan6configname3.validtrackip=2
					uci set loadbalancingconfig.$wan6configname3.trackIp1=2001:4860:4860::8888
					uci set loadbalancingconfig.$wan6configname3.trackIp2=2001:4860:4860::8844
					uci set loadbalancingconfig.$wan6configname3.reliability=1
					uci set loadbalancingconfig.$wan6configname3.count=3
					uci set loadbalancingconfig.$wan6configname3.up=3
					uci set loadbalancingconfig.$wan6configname3.down=3
					uci set loadbalancingconfig.$wan6configname3.timeout=4
					uci set loadbalancingconfig.$wan6configname3.interval=2
			    fi				  
				count=$((count + 1))
				echo "Count = $count"
				uci set loadbalancingconfig				
		    fi 
			
			################ IPV4 || IPV4V6 single sim single modem############33
			if [ "$PDP1" = "IPV4" ]  || [ "$PDP1" = "IPV4V6" ] 
			then
				uci set loadbalancingconfig."$wanconfigname3"=loadbalancingconfig
				uci set loadbalancingconfig.$wanconfigname3.name=$wanconfigname3
                uci set loadbalancingconfig.$wanconfigname3.track_method=$CWAN1trackmethod
				if [[ $CWAN1weight != 0 ]]
				then
					uci set loadbalancingconfig.$wanconfigname3.wanweight=$CWAN1weight
					uci set loadbalancingconfig.$wanconfigname3.validtrackip=$CWAN1validtrackip
					uci set loadbalancingconfig.$wanconfigname3.enabled=$CWAN1enabled
					uci set loadbalancingconfig.$wanconfigname3.flush_conntrack=$CWAN1flush_conntrack

					uci set loadbalancingconfig.$wanconfigname3.timeout=$CWAN1timeout
					uci set loadbalancingconfig.$wanconfigname3.interval=$CWAN1interval
					uci set loadbalancingconfig.$wanconfigname3.check_quality=$CWAN1check_quality
					uci set loadbalancingconfig.$wanconfigname3.failure_latency=$CWAN1failure_latency
					uci set loadbalancingconfig.$wanconfigname3.recovery_latency=$CWAN1recovery_latency
					uci set loadbalancingconfig.$wanconfigname3.failure_loss=$CWAN1failure_loss
					uci set loadbalancingconfig.$wanconfigname3.recovery_loss=$CWAN1recovery_loss
					if [ "$CWAN1validtrackip" =  "1" ]
					then 
						uci set loadbalancingconfig.$wanconfigname3.trackIp1="$CWAN1trackIp1"
					fi
					if [ "$CWAN1validtrackip" =  "2" ]
					then 
						uci set loadbalancingconfig.$wanconfigname3.trackIp1="$CWAN1trackIp1"
						uci set loadbalancingconfig.$wanconfigname3.trackIp2="$CWAN1trackIp2"
					fi
					if [ "$CWAN1validtrackip" =  "3" ]
					then 
						uci set loadbalancingconfig.$wanconfigname3.trackIp1="$CWAN1trackIp1"
						uci set loadbalancingconfig.$wanconfigname3.trackIp2="$CWAN1trackIp2"
						uci set loadbalancingconfig.$wanconfigname3.trackIp3="$CWAN1trackIp3"
					fi
					if [ "$CWAN1validtrackip" =  "4" ]
					then             
						uci set loadbalancingconfig.$wanconfigname3.trackIp1="$CWAN1trackIp1"
						uci set loadbalancingconfig.$wanconfigname3.trackIp2="$CWAN1trackIp2"
						uci set loadbalancingconfig.$wanconfigname3.trackIp3="$CWAN1trackIp3"
						uci set loadbalancingconfig.$wanconfigname3.trackIp4="$CWAN1trackIp4"
					fi
					uci set loadbalancingconfig.$wanconfigname3.reliability="$CWAN1reliability"
					uci set loadbalancingconfig.$wanconfigname3.count="$CWAN1count"

					uci set loadbalancingconfig.$wanconfigname3.up="$CWAN1up"
					uci set loadbalancingconfig.$wanconfigname3.down="$CWAN1down"      
				else  
					uci set loadbalancingconfig.$wanconfigname3.enabled=1
					uci set loadbalancingconfig.$wanconfigname3.wanweight=30
                    uci set loadbalancingconfig.$wanconfigname3.track_method="ping"
					uci set loadbalancingconfig.$wanconfigname3.validtrackip=2
					uci set loadbalancingconfig.$wanconfigname3.trackIp1=8.8.8.8
					uci set loadbalancingconfig.$wanconfigname3.trackIp2=8.8.4.4
					uci set loadbalancingconfig.$wanconfigname3.reliability=1
					uci set loadbalancingconfig.$wanconfigname3.count=3
					uci set loadbalancingconfig.$wanconfigname3.up=3
					uci set loadbalancingconfig.$wanconfigname3.down=3
					uci set loadbalancingconfig.$wanconfigname3.timeout=2
					uci set loadbalancingconfig.$wanconfigname3.interval=2
				fi
			
				count=$((count + 1))
				echo "Count = $count"	
			fi	
		fi	  
		
	fi						  
	 
	if [ "$wifi1mode" = "sta" ] || [ "$wifi1mode" = "apsta" ]
	then
		uci set loadbalancingconfig."$wanconfigname7"=loadbalancingconfig
		uci set loadbalancingconfig.$wanconfigname7.name=$wanconfigname7
		uci set loadbalancingconfig.$wanconfigname7.enabled=1
        uci set loadbalancingconfig.$wanconfigname7.track_method=$WIFItrackmethod
		if [[ $WIFIweight != 0 ]]
		then
			uci set loadbalancingconfig.$wanconfigname7.wanweight=$WIFIweight
			uci set loadbalancingconfig.$wanconfigname7.validtrackip=$WIFIvalidtrackip
			uci set loadbalancingconfig.$wanconfigname7.enabled=$WIFIenabled
			uci set loadbalancingconfig.$wanconfigname7.flush_conntrack=$WIFIflush_conntrack

			uci set loadbalancingconfig.$wanconfigname7.timeout=$WIFItimeout
			uci set loadbalancingconfig.$wanconfigname7.interval=$WIFIinterval
			uci set loadbalancingconfig.$wanconfigname7.check_quality=$WIFIcheck_quality
			uci set loadbalancingconfig.$wanconfigname7.failure_latency=$WIFIfailure_latency
			uci set loadbalancingconfig.$wanconfigname7.recovery_latency=$WIFIrecovery_latency
			uci set loadbalancingconfig.$wanconfigname7.failure_loss=$WIFIfailure_loss
			uci set loadbalancingconfig.$wanconfigname7.recovery_loss=$WIFIrecovery_loss
			uci set loadbalancingconfig.$wanconfigname7.initial_state=$WIFIinitial_state
			if [ "$WIFIvalidtrackip" =  "1" ]
			then 
				uci set loadbalancingconfig.$wanconfigname7.trackIp1="$WIFItrackIp1"
			fi
			if [ "$WIFIvalidtrackip" =  "2" ]
			then 
				uci set loadbalancingconfig.$wanconfigname7.trackIp1="$WIFItrackIp1"
				uci set loadbalancingconfig.$wanconfigname7.trackIp2="$WIFItrackIp2"
			fi
			if [ "$WIFIvalidtrackip" =  "3" ]
			then 
				uci set loadbalancingconfig.$wanconfigname7.trackIp1="$WIFItrackIp1"
				uci set loadbalancingconfig.$wanconfigname7.trackIp2="$WIFItrackIp2"
				uci set loadbalancingconfig.$wanconfigname7.trackIp3="$WIFItrackIp3"
			fi
			if [ "$WIFIvalidtrackip" =  "4" ]
			then            
				uci set loadbalancingconfig.$wanconfigname7.trackIp1="$WIFItrackIp1"
				uci set loadbalancingconfig.$wanconfigname7.trackIp2="$WIFItrackIp2"
				uci set loadbalancingconfig.$wanconfigname7.trackIp3="$WIFItrackIp3"
				uci set loadbalancingconfig.$wanconfigname7.trackIp4="$WIFItrackIp4"
			fi
			uci set loadbalancingconfig.$wanconfigname7.reliability="$WIFIreliability"
			uci set loadbalancingconfig.$wanconfigname7.count="$WIFIcount"

			uci set loadbalancingconfig.$wanconfigname7.up="$WIFIup"
			uci set loadbalancingconfig.$wanconfigname7.down="$WIFIdown"     
		else
			uci set loadbalancingconfig.$wanconfigname7.enabled=1
			uci set loadbalancingconfig.$wanconfigname7.wanweight=30
            uci set loadbalancingconfig.$wanconfigname7.track_method="ping"
			uci set loadbalancingconfig.$wanconfigname7.validtrackip=2
			uci set loadbalancingconfig.$wanconfigname7.trackIp1=8.8.8.8
			uci set loadbalancingconfig.$wanconfigname7.trackIp2=8.8.4.4
			uci set loadbalancingconfig.$wanconfigname7.reliability=1
			uci set loadbalancingconfig.$wanconfigname7.count=3
			uci set loadbalancingconfig.$wanconfigname7.up=3
			uci set loadbalancingconfig.$wanconfigname7.down=3
			uci set loadbalancingconfig.$wanconfigname7.timeout=2
			uci set loadbalancingconfig.$wanconfigname7.interval=2
			
		fi
		count=$((count + 1))
		echo "Count = $count"
	fi 

		echo "Final Count = $count"
		echo "$count" > "wancount.txt"
	  
	uci commit loadbalancingconfig
logger -t config -p customs.info "loadbalancingconfig configuration changed"

  #fi
}

	sh -x /etc/init.d/GD44AppManager stop &
	config_load "$sysconfigUCIPath"
	 
	 config_get CellularOperationMode "$sysconfigsection" CellularOperationMode 
	 config_get wifi1mode "$wificonfigsection" wifi1mode
	 config_get enablecellular "$sysconfigsection" enablecellular
	 
	 config_get cellularmodem1 "$sysconfigsection" cellularmodem1
	 config_get Manufacturer1 "$sysconfigsection" Manufacturer1
	 config_get model1 "$sysconfigsection" model1
	 
	 config_get cellularmodem2 "$sysconfigsection" cellularmodem2
	 config_get Manufacturer2 "$sysconfigsection" Manufacturer2
	 config_get model2 "$sysconfigsection" model2
	 config_get loopbackip "$loopbackconfigsection" loopbackip
	 config_get loopbacknetmask "$loopbackconfigsection" loopbacknetmask
	 config_get PDP1 sysconfig pdp
	 config_get PDP2 sysconfig sim2pdp
	 uci set network.loopback.ipaddr=$loopbackip
	 uci set network.loopback.netmask=$loopbacknetmask
	 uci commit network 
	logger -t config -p customs.info "network configuration changed"

	 config_get wifi1mode "$wificonfigsection" wifi1mode
	 
	 #sim1priority=$(uci get mwan3config.CWAN1_0.wanpriority)
	 #sim2priority=$(uci get mwan3config.CWAN1_1.wanpriority)
	 #wan6c1priority=$(uci get mwan3config.wan6c1.wanpriority)
	 #wan6c2priority=$(uci get mwan3config.wan6c2.wanpriority)
	 
	#if ([ -z "$sim2priority" ] && [ ! -z $wan6c2priority ]) || ([ ! -z "$sim2priority" ] && [ ! -z $wan6c2priority ]);then 
		#uci delete mwan3config.$wanconfigname6
		#uci delete mwan3config.$wan6configname4
		#uci commit mwan3config

	#fi
	 #if ([ -z "$sim1priority" ] && [ ! -z $wan6c1priority ]) || ([ ! -z "$sim1priority" ] && [ ! -z $wan6c1priority ]);then 
		#uci delete mwan3config.$wanconfigname5
		#uci delete mwan3config.$wan6configname3
		#uci commit mwan3config
	#fi
	 
	 config_load "/etc/config/mwan3config" 
	 config_foreach ReadOldPriority_Failover mwan3config
	 
	 config_load "/etc/config/loadbalancingconfig" 
	 config_foreach ReadOldWeight_LoadBalancing loadbalancingconfig
	
		uci delete mwan3config.$wanconfigname3
		uci delete mwan3config.$wanconfigname4
		uci delete mwan3config.$wanconfigname5
		uci delete mwan3config.$wanconfigname6
		uci delete mwan3config.$wanconfigname7
		uci delete mwan3config.$wan6configname1
		uci delete mwan3config.$wan6configname3
		uci delete mwan3config.$wan6configname4
		
		uci delete loadbalancingconfig.$wanconfigname3
		uci delete loadbalancingconfig.$wanconfigname4
		uci delete loadbalancingconfig.$wanconfigname5
		uci delete loadbalancingconfig.$wanconfigname6
		uci delete loadbalancingconfig.$wanconfigname7
		uci delete loadbalancingconfig.$wan6configname1
		uci delete loadbalancingconfig.$wan6configname3
		uci delete loadbalancingconfig.$wan6configname4
		
	 $cellulardatausagemanagerscript         
	 SetPriority_Failover
	 SetWeight_LoadBalancing
	 #$validatescript
	 
	 /etc/init.d/GD44AppManager start
	 

Policy_Type=$(uci get mwan3config.general.select)

UpdateInternetConfig()
{
	if [ "$Policy_Type" = "none" ]
	then
	      mwan3 stop
	 #elif [ "$Policy_Type" = "failover" ]
	 #then 
	      #sh /root/InterfaceManager/script/Mwan3_Failover.sh
	  else
	      sh /root/InterfaceManager/script/Mwan3_LoadBalancing.sh 
	fi      
  
}
	 
UpdateInternetConfig	

sh /root/InterfaceManager/script/SystemStart.sh
  
exit 0
