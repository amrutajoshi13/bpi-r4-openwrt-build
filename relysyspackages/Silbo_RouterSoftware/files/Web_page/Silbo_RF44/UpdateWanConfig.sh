#!/bin/sh
. /lib/functions.sh


sysconfigUCIPath=/etc/config/sysconfig
sysconfigsection="sysconfig"
validatescript="/bin/validate.sh"
wanstatusupdatescript="/bin/mwan3statusupdate.sh"
cellulardatausagemanagerscript="/bin/cellulardatausagemanagerscript.sh"

#wanconfigname1="port4wanconfig"
#wanconfigname2="port5wanconfig"
#wanconfigname3="sim1wanconfig"
#wanconfigname4="sim2wanconfig"

wanconfigname="EWAN"
wanconfigname2="EWAN2"
wanconfigname3="CWAN1"
wanconfigname4="CWAN2"
wanconfigname5="CWAN1_0"
wanconfigname6="CWAN1_1"

wanconfigname7="WIFI_WAN"
wan6configname1="CWAN1"



wan6configname1="CWAN1"
wan6configname2="CWAN2"
wan6configname3="wan6c1"
wan6configname4="wan6c2"
EWANpriority=0
EWANvalidtrackip=0
EWANtrackIp1=0
EWANtrackIp2=0
EWANtrackIp3=0
EWANtrackIp4=0
EWANup=0
EWANdown=0
EWANreliability=0
EWANcount=0
EWANtimeout=0

EWAN2priority=0
EWAN2trackIp1=0
EWAN2trackIp2=0
EWAN2trackIp3=0
EWAN2trackIp4=0

CWAN1priority=0
CWAN1validtrackip=0
CWAN1trackIp1=0
CWAN1trackIp2=0
CWAN1trackIp3=0
CWAN1trackIp4=0
CWAN1up=0
CWAN1down=0
CWAN1reliability=0
CWAN1count=0
CWAN1timeout=0

CWAN2priority=0
CWAN1_0priority=0
CWAN1_1priority=0


WIFIpriority=0
WIFIvalidtrackip=0
WIFItrackIp1=0
WIFItrackIp2=0
WIFItrackIp3=0
WIFItrackIp4=0
WIFIup=0
WIFIdown=0
WIFIreliability=0
check_quality=0
failure_latency=0
recovery_latency=0
failure_loss=0
recovery_loss=0
WIFIcount=0
WIFItimeout=0

#IPV6 variables
#sim1 IPV6 variables
CWAN1V6_0priority=0
CWAN1V6_0validtrackip=0
CWAN1V6_0trackIp1=0
CWAN1V6_0trackIp2=0
CWAN1V6_0trackIp3=0
CWAN1V6_0trackIp4=0
CWAN1V6_0up=0
CWAN1V6_0down=0
CWAN1V6_0reliability=0
CWAN1V6_0count=0
CWAN1V6_0timeout=0

#sim1(single sim single modem) IPV6 variables
CWAN1V6priority=0
CWAN1V6validtrackip=0
CWAN1V6trackIp1=0
CWAN1V6trackIp2=0
CWAN1V6trackIp3=0
CWAN1V6trackIp4=0
CWAN1V6up=0
CWAN1V6down=0
CWAN1V6reliability=0
CWAN1V6count=0
CWAN1V6timeout=0

#configname="wancount"

#count=0

ReadOldPriority()
{
  config=$1
  config_get WanPriority "$config" wanpriority
   config_get validtrackip "$config" validtrackip
  config_get trackIp1 "$config" trackIp1
  config_get trackIp2 "$config" trackIp2
  config_get trackIp3 "$config" trackIp3
  config_get trackIp4 "$config" trackIp4
  config_get reliability "$config" reliability
  config_get count "$config" count
  config_get up "$config" up
  config_get down "$config" down
  config_get timeout "$config" timeout
  config_get check_quality "$config" check_quality
  config_get failure_latency "$config" failure_latency
  config_get recovery_latency "$config" recovery_latency
  config_get failure_loss "$config" failure_loss
  config_get recovery_loss "$config" recovery_loss

  
  case "$config" in
   "EWAN") 
					 EWANpriority=$WanPriority
					 EWANvalidtrackip=$validtrackip
					 if [ $EWANvalidtrackip = "1" ]
					 then
							EWANtrackIp1=$trackIp1
					 fi
					 if [ $EWANvalidtrackip = "2" ]
					 then
							EWANtrackIp1=$trackIp1
							EWANtrackIp2=$trackIp2
					 fi
					 if [ $EWANvalidtrackip = "3" ]
					 then
							EWANtrackIp1=$trackIp1
							EWANtrackIp2=$trackIp2
							EWANtrackIp3=$trackIp3
					 fi
					 if [ $EWANvalidtrackip = "4" ]
					 then
					 EWANtrackIp1=$trackIp1
					 EWANtrackIp2=$trackIp2
					 EWANtrackIp3=$trackIp3
					 EWANtrackIp4=$trackIp4
					 fi
					 EWANup=$up
					 EWANdown=$down
					 EWANreliability=$reliability
					 EWANcount=$count
					 EWANtimeout= "2"
					
					;;
   "EWAN2") 
					 EWAN2priority=$WanPriority
					 EWAN2trackIp1=$trackIp1
					 EWAN2trackIp2=$trackIp2
					 EWAN2trackIp3=$trackIp3
					 EWAN2trackIp4=$trackIp4

					;;
   "CWAN1") 
					 CWAN1priority=$WanPriority
					 CWAN1validtrackip=$validtrackip
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
					CWAN1timeout="2"
					;;
					
	"wan6c1")		         
			CWAN1V6_0priority=$WanPriority
			CWAN1V6_0validtrackip=$validtrackip
					
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
					CWAN1V6_0timeout="2"	
			;;
   "CWAN2") 
					 CWAN2priority=$WanPriority
					 CWAN2trackIp1=$trackIp1
					 CWAN2trackIp2=$trackIp2
					 CWAN2trackIp3=$trackIp3
					 CWAN2trackIp4=$trackIp4
					;;
   "CWAN1_0") 
					 CWAN1_0priority=$WanPriority
					 CWAN1_0trackIp1=$trackIp1
					 CWAN1_0trackIp2=$trackIp2
					 CWAN1_0trackIp3=$trackIp3
					 CWAN1_0trackIp4=$trackIp4
					;;
   "CWAN1_1") 
					 CWAN1_1priority=$WanPriority
					 CWAN1_1trackIp1=$trackIp1
					 CWAN1_1trackIp2=$trackIp2
					 CWAN1_1trackIp3=$trackIp3
					 CWAN1_1trackIp4=$trackIp4
					;;
   "WIFI_WAN") 
				WIFIpriority=$WanPriority
				WIFIvalidtrackip=$validtrackip
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
				WIFIcheck_quality=$check_quality
				WIFIfailure_latency=$failure_latency
				WIFIrecovery_latency=$recovery_latency
				WIFIfailure_loss=$failure_loss
				WIFIrecovery_loss=$recovery_loss
				WIFIcount=$count
				WIFItimeout= "2"
					;;
				
esac

echo "EWANpriority=$EWANpriority"
echo "EWAN2priority=$EWAN2priority"
echo "CWAN1priority=$CWAN1priority"
echo "CWAN2priority=$CWAN2priority"
echo "CWAN1_0priority=$CWAN1_0priority"
echo "CWAN1_1priority=$CWAN1_1priority"
echo "WIFIpriority=$WIFIpriority"
}

SetPriority()
{
   
	if [ "$portmode" = "EWAN" ]
	 then
	      uci set mwan3config."$wanconfigname"=redirect
	      uci set mwan3config.$wanconfigname.name=$wanconfigname
	      if [[ $EWANpriority != 0 ]]
	      then
			 uci set mwan3config.$wanconfigname.wanpriority=$EWANpriority
			  uci set mwan3config.$wanconfigname.validtrackip=$EWANvalidtrackip
			  if [ "$EWANvalidtrackip" =  "1" ]
	   then 
	    uci set mwan3config.$wanconfigname.trackIp1="$EWANtrackIp1"
	   fi
	    if [ "$EWANvalidtrackip" =  "2" ]
	   then 
	    uci set mwan3config.$wanconfigname.trackIp1="$EWANtrackIp1"
	     uci set mwan3config.$wanconfigname.trackIp2="$EWANtrackIp2"
	   fi
	  	    if [ "$EWANvalidtrackip" =  "3" ]
	   then 
	    uci set mwan3config.$wanconfigname.trackIp1="$EWANtrackIp1"
	     uci set mwan3config.$wanconfigname.trackIp2="$EWANtrackIp2"
	     uci set mwan3config.$wanconfigname.trackIp3="$EWANtrackIp3"
	   fi
	      if [ "$EWANvalidtrackip" =  "4" ]
	   then 
	    uci set mwan3config.$wanconfigname.trackIp1="$EWANtrackIp1"
	     uci set mwan3config.$wanconfigname.trackIp2="$EWANtrackIp2"
	     uci set mwan3config.$wanconfigname.trackIp3="$EWANtrackIp3"
	     uci set mwan3config.$wanconfigname.trackIp4="$EWANtrackIp4"
	   fi
	   
	     uci set mwan3config.$wanconfigname.reliability="$EWANreliability"
	     uci set mwan3config.$wanconfigname.count="$EWANcount"
	     uci set mwan3config.$wanconfigname.timeout="2"
	     uci set mwan3config.$wanconfigname.up="$EWANup"
	     uci set mwan3config.$wanconfigname.down="$EWANdown"
	     
		  else	
		    uci set mwan3config.$wanconfigname.wanpriority=2
		    uci set mwan3config.$wanconfigname.validtrackip=2
			uci set mwan3config.$wanconfigname.trackIp1=8.8.8.8
	        uci set mwan3config.$wanconfigname.trackIp2=8.8.4.4
	        uci set mwan3config.$wanconfigname.reliability=1
	        uci set mwan3config.$wanconfigname.count=1
	        uci set mwan3config.$wanconfigname.timeout=2
	        uci set mwan3config.$wanconfigname.up=1
	        uci set mwan3config.$wanconfigname.down=1
	      fi
	     
	      count=$((count + 1))
	      echo "Count = $count"
	      
           uci commit mwan3config
     elif  [ "$portmode" = "LAN" ]
     then
          uci delete mwan3config.EWAN 
	fi
	 
	if [ "$enablecellular" = "1" ]
	 then	 
			 if [ "$CellularOperationMode" = "dualcellularsinglesim" ]
			 then
			      uci set mwan3config."$wanconfigname3"=redirect
			      uci set mwan3config.$wanconfigname3.name=$wanconfigname3
			      if [[ $CWAN1priority != 0 ]]
				  then
					uci set mwan3config.$wanconfigname3.wanpriority=$CWAN1priority
					uci set mwan3config.$wanconfigname3.trackIp1=$CWAN1trackIp1
			        uci set mwan3config.$wanconfigname3.trackIp2=$CWAN1trackIp2
			        uci set mwan3config.$wanconfigname3.trackIp3=$CWAN1trackIp3
			        uci set mwan3config.$wanconfigname3.trackIp4=$CWAN1trackIp4
				  else	
					uci set mwan3config.$wanconfigname3.wanpriority=2
					uci set mwan3config.$wanconfigname3.trackIp1=8.8.8.8
			       uci set mwan3config.$wanconfigname3.trackIp2=8.8.4.4
			       uci set mwan3config.$wanconfigname3.trackIp3=208.67.220.220
			       uci set mwan3config.$wanconfigname3.trackIp4=208.67.222.222
				  fi			         
			      count=$((count + 1))
			      echo "Count = $count"
			      
			      uci set mwan3config."$wanconfigname4"=redirect
			      uci set mwan3config.$wanconfigname4.name=$wanconfigname4
			      #uci set mwan3config.$wanconfigname4.wanpriority=3
			      if [[ $CWAN2priority != 0 ]]
				  then
					uci set mwan3config.$wanconfigname4.wanpriority=$CWAN2priority
					uci set mwan3config.$wanconfigname4.trackIp1=$CWAN2trackIp1
			        uci set mwan3config.$wanconfigname4.trackIp2=$CWAN2trackIp2
			        uci set mwan3config.$wanconfigname4.trackIp3=$CWAN2trackIp3
			        uci set mwan3config.$wanconfigname4.trackIp4=$CWAN2trackIp4
				  else	
					uci set mwan3config.$wanconfigname4.wanpriority=3
				 	
			      uci set mwan3config.$wanconfigname4.trackIp1=8.8.8.8
			      uci set mwan3config.$wanconfigname4.trackIp2=8.8.4.4
			      uci set mwan3config.$wanconfigname4.trackIp3=208.67.220.220
			      uci set mwan3config.$wanconfigname4.trackIp4=208.67.222.222
			       fi
			      count=$((count + 1))
			      echo "Count = $count"
			      
			      uci commit mwan3config
			 fi
			 
			 if [ "$CellularOperationMode" = "singlecellulardualsim" ]
			 then
			      uci set mwan3config."$wanconfigname5"=redirect
			      uci set mwan3config.$wanconfigname5.name=$wanconfigname5
			      if [[ $CWAN1_0priority != 0 ]]
				  then
					uci set mwan3config.$wanconfigname5.wanpriority=$CWAN1_0priority
					uci set mwan3config.$wanconfigname5.trackIp1=$CWAN1_0trackIp1
			        uci set mwan3config.$wanconfigname5.trackIp2=$CWAN1_0trackIp2
			        uci set mwan3config.$wanconfigname5.trackIp3=$CWAN1_0trackIp3
			        uci set mwan3config.$wanconfigname5.trackIp4=$CWAN1_0trackIp4
				  else	
					uci set mwan3config.$wanconfigname5.wanpriority=2
					uci set mwan3config.$wanconfigname5.trackIp1=8.8.8.8
			        uci set mwan3config.$wanconfigname5.trackIp2=8.8.4.4
			        uci set mwan3config.$wanconfigname5.trackIp3=208.67.220.220
			        uci set mwan3config.$wanconfigname5.trackIp4=208.67.222.222
				  fi
			     
			      
			      count=$((count + 1))
			      echo "Count = $count"
			      
			      uci set mwan3config."$wanconfigname6"=redirect
			      uci set mwan3config.$wanconfigname6.name=$wanconfigname6
			      #uci set mwan3config.$wanconfigname6.wanpriority=3
			      if [[ $CWAN1_1priority != 0 ]]
				  then
					uci set mwan3config.$wanconfigname6.wanpriority=$CWAN1_1priority
					uci set mwan3config.$wanconfigname6.trackIp1=$CWAN1_1trackIp1
			        uci set mwan3config.$wanconfigname6.trackIp2=$CWAN1_1trackIp2
			        uci set mwan3config.$wanconfigname6.trackIp3=$CWAN1_1trackIp3
			        uci set mwan3config.$wanconfigname6.trackIp4=$CWAN1_1trackIp4
					
				  else	
					uci set mwan3config.$wanconfigname6.wanpriority=3
                    uci set mwan3config.$wanconfigname6.trackIp1=8.8.8.8
			      uci set mwan3config.$wanconfigname6.trackIp2=8.8.4.4
			      uci set mwan3config.$wanconfigname6.trackIp3=208.67.220.220
			      uci set mwan3config.$wanconfigname6.trackIp4=208.67.222.222
				  fi
			    
			      
			       count=$((count + 1))
			      echo "Count = $count"
			      
		           uci commit mwan3config
			 fi
			 
			if [ "$CellularOperationMode" = "singlecellularsinglesim" ]
			then
			     			################ IPV4 || IPV4V6 single sim single modem############33
				if [ "$PDP1" = "IPV4" ]  || [ "$PDP1" = "IPV4V6" ] 
				then			 
					uci set mwan3config."$wanconfigname3"=redirect
					uci set mwan3config.$wanconfigname3.name=$wanconfigname3
					# uci set mwan3config.$wanconfigname3.wanpriority=2
					if [[ $CWAN1priority != 0 ]]
					then
						uci set mwan3config.$wanconfigname3.wanpriority=$CWAN1priority
						uci set mwan3config.$wanconfigname3.validtrackip=$CWAN1validtrackip
						if [ "$CWAN1validtrackip" =  "1" ]
						then 
							uci set mwan3config.$wanconfigname3.trackIp1="$CWAN1trackIp1"
						fi
						if [ "$CWAN1validtrackip" =  "2" ]
						then 
							uci set mwan3config.$wanconfigname3.trackIp1="$CWAN1trackIp1"
							uci set mwan3config.$wanconfigname3.trackIp2="$CWAN1trackIp2"
						fi
						if [ "$CWAN1validtrackip" =  "3" ]
						then 
							uci set mwan3config.$wanconfigname3.trackIp1="$CWAN1trackIp1"
							uci set mwan3config.$wanconfigname3.trackIp2="$CWAN1trackIp2"
							uci set mwan3config.$wanconfigname3.trackIp3="$CWAN1trackIp3"
						fi
						if [ "$CWAN1validtrackip" =  "4" ]
						then 			
							uci set mwan3config.$wanconfigname3.trackIp1="$CWAN1trackIp1"
							uci set mwan3config.$wanconfigname3.trackIp2="$CWAN1trackIp2"
							uci set mwan3config.$wanconfigname3.trackIp3="$CWAN1trackIp3"
							uci set mwan3config.$wanconfigname3.trackIp4="$CWAN1trackIp4"
						fi
						uci set mwan3config.$wanconfigname3.reliability="$CWAN1reliability"
						uci set mwan3config.$wanconfigname3.count="$CWAN1count"
						uci set mwan3config.$wanconfigname3.timeout="2"
						uci set mwan3config.$wanconfigname3.up="$CWAN1up"
						uci set mwan3config.$wanconfigname3.down="$CWAN1down"		
					else	
						uci set mwan3config.$wanconfigname3.wanpriority=1
						uci set mwan3config.$wanconfigname3.validtrackip=2
						uci set mwan3config.$wanconfigname3.trackIp1=8.8.8.8
				        uci set mwan3config.$wanconfigname3.trackIp2=8.8.4.4
				        uci set mwan3config.$wanconfigname3.reliability=1
		                uci set mwan3config.$wanconfigname3.count=1
		                uci set mwan3config.$wanconfigname3.timeout=1
		                uci set mwan3config.$wanconfigname3.interval=5
		                uci set mwan3config.$wanconfigname3.up=1
		                uci set mwan3config.$wanconfigname3.down=1
					fi
			     
			       count=$((count + 1))
			    fi	      
		          uci commit mwan3config
			fi
			
						#IPV6 only for sssm
			#IPV6 update for wan6c1(single sim single modem)
			if [ "$PDP1" = "IPV6" ]  
			then
			    uci delete mwan3.default_rule
				uci set mwan3config."$wan6configname3"=redirect
				uci set mwan3config."$wan6configname3".name=$wan6configname3
				if [[ $CWAN1V6_0priority != 0 ]]
				then
					uci set mwan3config.$wan6configname3.wanpriority=$CWAN1V6_0priority
					uci set mwan3config.$wan6configname3.validtrackip=$CWAN1V6_0validtrackip
					
					if [ "$CWAN1V6_0validtrackip" =  "1" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
					fi
					if [ "$CWAN1V6_0validtrackip" =  "2" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
					fi
			
					if [ "$CWAN1V6_0validtrackip" =  "3" ]
					then 
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
						uci set mwan3config.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3"
					fi
					if [ "$CWAN1V6_0validtrackip" =  "4" ]
					then            
						uci set mwan3config.$wan6configname3.trackIp1="$CWAN1V6_0trackIp1"
						uci set mwan3config.$wan6configname3.trackIp2="$CWAN1V6_0trackIp2"
						uci set mwan3config.$wan6configname3.trackIp3="$CWAN1V6_0trackIp3"
						uci set mwan3config.$wan6configname3.trackIp4="$CWAN1V6_0trackIp4"
					fi
					uci set mwan3config.$wan6configname3.reliability="$CWAN1V6_0reliability"
					uci set mwan3config.$wan6configname3.count="$CWAN1V6_0count"
					uci set mwan3config.$wan6configname3.timeout="2"
					uci set mwan3config.$wan6configname3.up="$CWAN1V6_0up"
					uci set mwan3config.$wan6configname3.down="$CWAN1V6_0down"       
				else    
					uci set mwan3config.$wan6configname3.wanpriority=5
					uci set mwan3config.$wan6configname3.validtrackip=2
					uci set mwan3config.$wan6configname3.trackIp1=2001:4860:4860::8888
					uci set mwan3config.$wan6configname3.trackIp2=2001:4860:4860::8844
					uci set mwan3config.$wan6configname3.reliability=1
					uci set mwan3config.$wan6configname3.count=3
					uci set mwan3config.$wan6configname3.timeout=1
					uci set mwan3config.$wan6configname3.interval=5
					uci set mwan3config.$wan6configname3.up=3
					uci set mwan3config.$wan6configname3.down=3
			    fi				  
				count=$((count + 1))
				echo "Count = $count"
				uci set mwan3config				
		    fi 
	fi
			 
	 
	if [ "$wifi1mode" = "sta" ] || [ "$wifi1mode" = "apsta" ]
	then
		uci set mwan3config."$wanconfigname7"=redirect
		uci set mwan3config.$wanconfigname7.name=$wanconfigname7
		if [[ $WIFIpriority != 0 ]]
		then
			uci set mwan3config.$wanconfigname7.wanpriority=$WIFIpriority
			uci set mwan3config.$wanconfigname7.validtrackip=$WIFIvalidtrackip
			if [ "$WIFIvalidtrackip" =  "1" ]
			then 
			uci set mwan3config.$wanconfigname7.trackIp1="$WIFItrackIp1"
			fi
			if [ "$WIFIvalidtrackip" =  "2" ]
			then 
			uci set mwan3config.$wanconfigname7.trackIp1="$WIFItrackIp1"
			uci set mwan3config.$wanconfigname7.trackIp2="$WIFItrackIp2"
			fi
			if [ "$WIFIvalidtrackip" =  "3" ]
			then 
			uci set mwan3config.$wanconfigname7.trackIp1="$WIFItrackIp1"
			uci set mwan3config.$wanconfigname7.trackIp2="$WIFItrackIp2"
			uci set mwan3config.$wanconfigname7.trackIp3="$WIFItrackIp3"
			fi
			if [ "$WIFIvalidtrackip" =  "4" ]
			then 			
			uci set mwan3config.$wanconfigname7.trackIp1="$WIFItrackIp1"
			uci set mwan3config.$wanconfigname7.trackIp2="$WIFItrackIp2"
			uci set mwan3config.$wanconfigname7.trackIp3="$WIFItrackIp3"
			uci set mwan3config.$wanconfigname7.trackIp4="$WIFItrackIp4"
			fi
			uci set mwan3config.$wanconfigname7.reliability="$WIFIreliability"
			uci set mwan3config.$wanconfigname7.count="$WIFIcount"
			uci set mwan3config.$wanconfigname7.timeout="2"
			uci set mwan3config.$wanconfigname7.up="$WIFIup"
			uci set mwan3config.$wanconfigname7.down="$WIFIdown" 
			uci set mwan3config.$wanconfigname7.check_quality="$WIFIcheck_quality"
			uci set mwan3config.$wanconfigname7.failure_latency="$WIFIfailure_latency"
			uci set mwan3config.$wanconfigname7.recovery_latency="$WIFIrecovery_latency"
			uci set mwan3config.$wanconfigname7.failure_loss="$WIFIfailure_loss"
			uci set mwan3config.$wanconfigname7.recovery_loss="$WIFIrecovery_loss"      
		else    
			uci set mwan3config.$wanconfigname7.wanpriority=4
			uci set mwan3config.$wanconfigname7.validtrackip=2
			uci set mwan3config.$wanconfigname7.trackIp1=8.8.8.8
			uci set mwan3config.$wanconfigname7.trackIp2=8.8.4.4
			uci set mwan3config.$wanconfigname7.reliability=1
			uci set mwan3config.$wanconfigname7.count=3
			uci set mwan3config.$wanconfigname7.timeout=2
			uci set mwan3config.$wanconfigname7.up=3
			uci set mwan3config.$wanconfigname7.down=3
			uci set mwan3config.$wanconfigname7.check_quality=1
			uci set mwan3config.$wanconfigname7.failure_latency=1000
			uci set mwan3config.$wanconfigname7.recovery_latency=500
			uci set mwan3config.$wanconfigname7.failure_loss=40
			uci set mwan3config.$wanconfigname7.recovery_loss=10
		fi
		
		count=$((count + 1))
		echo "Count = $count"
		uci commit mwan3config
	fi 
	  
	  echo "Final Count = $count"
	  echo "$count" > "wancount.txt"
	  
 uci commit mwan3config
}

sh -x /etc/init.d/GD44AppManager stop
 config_load "$sysconfigUCIPath"
	 
	# config_get lanwancombination sysconfig lanwancombination
	 config_get CellularOperationMode sysconfig CellularOperationMode 
	 config_get wifi1mode wificonfig wifi1mode
	 config_get port4mode ethernet port4mode
	 config_get portmode ethernet portmode
	 config_get enablecellular sysconfig enablecellular
	 
	 config_get cellularmodem1 sysconfig cellularmodem1
	 config_get Manufacturer1 sysconfig Manufacturer1
	 config_get model1 sysconfig model1
	 
	 config_get cellularmodem2 sysconfig cellularmodem2
	 config_get Manufacturer2 sysconfig Manufacturer2
	 config_get model2 sysconfig model2
	 config_get radio0stationenable wificonfig radio0stationenable
	 config_get SmsEnable1 smsconfig smsenable1                     
	config_get SmsEnable2 smsconfig smsenable2 
	config_get loopbackip loopback loopbackip
	 config_get loopbacknetmask loopback loopbacknetmask
	 config_get PDP1 sysconfig pdp
	 config_get PDP2 sysconfig sim2pdp
	 uci set network.loopback.ipaddr=$loopbackip
	 uci set network.loopback.netmask=$loopbacknetmask
	 uci commit network 
         config_get wifi1mode wificonfig wifi1mode
     config_load "/etc/config/mwan3config" 
     config_foreach ReadOldPriority redirect

		uci delete mwan3config.$wanconfigname
		uci delete mwan3config.$wanconfigname2
		uci delete mwan3config.$wanconfigname3
		uci delete mwan3config.$wanconfigname4
		uci delete mwan3config.$wanconfigname5
		uci delete mwan3config.$wanconfigname6
		uci delete mwan3config.$wanconfigname7
		uci delete mwan3config.$wan6configname1
		uci delete mwan3config.$wan6configname3
		uci delete mwan3config.$wan6configname4
	 $cellulardatausagemanagerscript	     
     SetPriority
     $validatescript
 /etc/init.d/GD44AppManager start
    # sleep 90
#	 $wanstatusupdatescript     

exit 0
