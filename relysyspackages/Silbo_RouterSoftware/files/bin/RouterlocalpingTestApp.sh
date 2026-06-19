#!/bin/sh

. /lib/functions.sh

#IP=$1
#PingTime=$2
#ping -c $PingTime $IP
#Retval="$?"
#echo "Retval=$Retval"
#echo "$Retval" > "/bin/pingTest.txt"
#PingIP=8.8.8.8
#maxnoofretries=10
#sleepinterval=1

CellularOperationMode=$(uci get sysconfig.sysconfig.CellularOperationMode)

ReadMwanConfigFile()
{ 
   config_load "$MwanConfigFile" 
   
   #Single Cellular Dual Sim variables
   #SIM1
   config_get Cwan1sim1TrackIp1 "$cellularwan1sim1interface" trackIp1
   config_get Cwan1sim1TrackIp2 "$cellularwan1sim1interface" trackIp2
   config_get Cwan1sim1TrackIp3 "$cellularwan1sim1interface" trackIp3
   config_get Cwan1sim1TrackIp4 "$cellularwan1sim1interface" trackIp4
   config_get Cwan1sim1Validtrackip "$cellularwan1sim1interface" validtrackip
   #SIM2
   config_get Cwan1sim2TrackIp1 "$cellularwan1sim2interface" trackIp1
   config_get Cwan1sim2TrackIp2 "$cellularwan1sim2interface" trackIp2
   config_get Cwan1sim2TrackIp3 "$cellularwan1sim2interface" trackIp3
   config_get Cwan1sim2TrackIp4 "$cellularwan1sim2interface" trackIp4
   config_get Cwan1sim2Validtrackip "$cellularwan1sim2interface" validtrackip
   
   #Dual Cellular Sim/Single Cellular Single Sim variables
   #Modem1/SIM1
   config_get Cwan1TrackIp1 "$cellularwan1interface" trackIp1
   config_get Cwan1TrackIp2 "$cellularwan1interface" trackIp2
   config_get Cwan1TrackIp3 "$cellularwan1interface" trackIp3
   config_get Cwan1TrackIp4 "$cellularwan1interface" trackIp4
   config_get Cwan1Validtrackip "$cellularwan1interface" validtrackip
   #Modem2/SIM2
   config_get Cwan2TrackIp1 "$cellularwan2interface" trackIp1
   config_get Cwan2TrackIp2 "$cellularwan2interface" trackIp2
   config_get Cwan2TrackIp3 "$cellularwan2interface" trackIp3
   config_get Cwan2TrackIp4 "$cellularwan2interface" trackIp4
   config_get Cwan2Validtrackip "$cellularwan2interface" validtrackip
   
   #IPV6 variables for all cellular operation modes
	config_get Cwan6_1TrackIp1 "$cellular1wan6interface" trackIp1
	config_get Cwan6_1TrackIp2 "$cellular1wan6interface" trackIp2
	config_get Cwan6_1TrackIp3 "$cellular1wan6interface" trackIp3
	config_get Cwan6_1TrackIp4 "$cellular1wan6interface" trackIp4
	config_get Cwan6_1validtrackip "$cellular1wan6interface" validtrackip

	config_get Cwan6_2TrackIp1 "$cellular2wan6interface" trackIp1
	config_get Cwan6_2TrackIp2 "$cellular2wan6interface" trackIp2
	config_get Cwan6_2TrackIp3 "$cellular2wan6interface" trackIp3
	config_get Cwan6_2TrackIp4 "$cellular2wan6interface" trackIp4
	config_get Cwan6_2validtrackip "$cellular2wan6interface" validtrackip
   
}

UpdateRouterApplocalCfgModem1()
{
    echo "Updating Router Application configuration "
    echo "Updating '${RouterApplocalconfigureCfgPath1}.cfg' configuration"
    config_load "$RouterEventfile"
    
    config_get  enablerouterlocalpingapp      "$routerlocalconfigureEventSection1"    enablerouterlocalpingapp
    config_get  timeintervalforpingcheck      "$routerlocalconfigureEventSection1"    timeintervalforpingcheck
    config_get  noofipaddress                 "$routerlocalconfigureEventSection1"    noofipaddress
    config_get  ipaddress1                    "$routerlocalconfigureEventSection1"    ipaddress1
    config_get  ipaddress2                    "$routerlocalconfigureEventSection1"    ipaddress2
    config_get  failurecriteria               "$routerlocalconfigureEventSection1"    failurecriteria
    config_get  failureaction                 "$routerlocalconfigureEventSection1"    failureaction
    config_get  noofretries                   "$routerlocalconfigureEventSection1"    noofretries


   # config_get     
   {
	   echo "enablerouterlocalpingapp=\"$enablerouterlocalpingapp\""
	   echo "timeintervalforpingcheck=\"$timeintervalforpingcheck\""
	   echo "noofipaddress=\"$noofipaddress\""
	   echo "ipaddress1=\"$ipaddress1\""
	   echo "ipaddress2=\"$ipaddress2\""
	   echo "failurecriteria=\"$failurecriteria\""
	   echo "failureaction=\"$failureaction\""
	   echo "noofretries=\"$noofretries\""

   } > "${RouterApplocalconfigureCfgPath1}.cfg"
  
}

RouterConfigFileUpdate()
{
	cellularwan1sim1interface="CWAN1_0"
	cellularwan1sim2interface="CWAN1_1"
	
	cellularwan1interface="CWAN1"
	cellularwan2interface="CWAN2"
	
	#IPV6 Variables 
	cellular1wan6interface="wan6c1"
	cellular2wan6interface="wan6c2"
	
	MwanConfigFile="/etc/config/mwan3config"
	SystemConfigFile="/etc/config/sysconfig"
	RouterApplocalconfigureCfgPath1="/root/ConfigFiles/RouterAppConfig/routerapplocalconfig"
	RouterEventfile="routerapplicationconfig"
	routerlocalconfigureEventSection1="routerapplicationlocalconfig"

	ReadMwanConfigFile
	
	Pdp1=$(uci get sysconfig.sysconfig.pdp)
	sim2pdp=$(uci get sysconfig.sysconfig.sim2pdp)
	
	
	simnum=$(cat /tmp/simnumfile)
	
	if [ "$CellularOperationMode" = "singlecellulardualsim" ]
	then
		uci delete routerapplicationconfig.routerapplicationlocalconfig.ipaddress1
		uci delete routerapplicationconfig.routerapplicationlocalconfig.ipaddress2
		uci delete routerapplicationconfig.routerapplicationlocalconfig.ipaddress3
		uci delete routerapplicationconfig.routerapplicationlocalconfig.ipaddress4
		
		if [ "$simnum" = "1" ]                                                                                                
		then 
			#CWAN1_0
			#If pdp1 is ipv4 or ipv4v6
			if [ "$Pdp1" = "IPV4" ]  || [ "$Pdp1" = "IPV4V6" ]
			then
				uci set routerapplicationconfig.routerapplicationlocalconfig.noofipaddress="$Cwan1sim1Validtrackip"
			
				if [ "$Cwan1sim1Validtrackip" =  "1" ]
				then 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1sim1TrackIp1"
				fi
				if [ "$Cwan1sim1Validtrackip" =  "2" ]
				then 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1sim1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1sim1TrackIp2"
				fi
				if [ "$Cwan1sim1Validtrackip" =  "3" ]
				then 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1sim1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1sim1TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan1sim1TrackIp3"
				fi
				if [ "$Cwan1sim1Validtrackip" =  "4" ]
				then 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1sim1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1sim1TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan1sim1TrackIp3"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress4="$Cwan1sim1TrackIp4"
				fi
	
			fi
			
			#If pdp1 is ipv6
			if [ "$Pdp1" = "IPV6" ]
			then
				uci set routerapplicationconfig.routerapplicationlocalconfig.noofipaddress="$Cwan6_1validtrackip"
				if [ "$Cwan6_1validtrackip" = "1" ]
				then                 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_1TrackIp1"
				fi
				if [ "$Cwan6_1validtrackip" = "2" ]
				then
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_1TrackIp2"
				fi
				if [ "$Cwan6_1validtrackip" = "3" ]
				then
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_1TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan6_1TrackIp3"
				fi
				if [ "$Cwan6_1validtrackip" = "4" ]
				then
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_1TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_1TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan6_1TrackIp3"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress4="$Cwan6_1TrackIp4"
				fi
				
			fi 
		elif [ "$simnum" = "2" ]
		then
			#CWAN1_1
			#If pdp2 is ipv4 or ipv4v6
			if [ "$sim2pdp" = "IPV4" ]  || [ "$sim2pdp" = "IPV4V6" ]
			then				
				uci set routerapplicationconfig.routerapplicationlocalconfig.noofipaddress="$Cwan1sim2Validtrackip"
				if [ "$Cwan1sim2Validtrackip" =  "1" ]
				then 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1sim2TrackIp1"
				fi
				if [ "$Cwan1sim2Validtrackip" =  "2" ]
				then 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1sim2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1sim2TrackIp2"
				fi	
				if [ "$Cwan1sim2Validtrackip" =  "3" ]
				then 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1sim2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1sim2TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan1sim2TrackIp3"
				fi	
				if [ "$Cwan1sim2Validtrackip" =  "4" ]
				then 
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1sim2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1sim2TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan1sim2TrackIp3"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress4="$Cwan1sim2TrackIp4"
				fi				
			fi
			
			#If pdp2 is ipv6
			if [ "$sim2pdp" = "IPV6" ]
			then
				uci set routerapplicationconfig.routerapplicationlocalconfig.noofipaddress="$Cwan6_2validtrackip"
				if [ "$Cwan6_2validtrackip" = "1" ]
				then
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_2TrackIp1"
				fi
				if [ "$Cwan6_2validtrackip" = "2" ]
				then
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_2TrackIp2"
				fi
				if [ "$Cwan6_2validtrackip" = "3" ]
				then
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_2TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan6_2TrackIp3"
				fi
				if [ "$Cwan6_2validtrackip" = "4" ]
				then
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_2TrackIp1"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_2TrackIp2"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan6_2TrackIp3"
					uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress4="$Cwan6_2TrackIp4"
				fi
			fi 
		fi	
	###################################################
	elif [ "$CellularOperationMode" = "dualcellularsinglesim" ] || [ "$CellularOperationMode" = "singlecellularsinglesim" ]
	then
		if [ "$Pdp1" = "IPV4" ]  || [ "$Pdp1" = "IPV4V6" ]
		then
			uci set routerapplicationconfig.routerapplicationlocalconfig.noofipaddress="$Cwan1Validtrackip"

			if [ "$Cwan1Validtrackip" =  "1" ]
			then 
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1TrackIp1"
			fi
			if [ "$Cwan1Validtrackip" =  "2" ]
			then 
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1TrackIp1"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1TrackIp2"
			fi
			if [ "$Cwan1Validtrackip" =  "3" ]
			then 
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1TrackIp1"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1TrackIp2"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan1TrackIp3"
			fi
			if [ "$Cwan1Validtrackip" =  "4" ]
			then 
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan1TrackIp1"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan1TrackIp2"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan1TrackIp3"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress4="$Cwan1TrackIp4"
			fi
		fi
			
		#If pdp1 is ipv6
		if [ "$Pdp1" = "IPV6" ]
		then
			uci set routerapplicationconfig.routerapplicationlocalconfig.noofipaddress="$Cwan6_1validtrackip"
			if [ "$Cwan6_1validtrackip" = "1" ]
			then                 
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_1TrackIp1"
			fi
			if [ "$Cwan6_1validtrackip" = "2" ]
			then
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_1TrackIp1"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_1TrackIp2"
			fi
			if [ "$Cwan6_1validtrackip" = "3" ]
			then
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_1TrackIp1"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_1TrackIp2"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan6_1TrackIp3"
			fi
			if [ "$Cwan6_1validtrackip" = "4" ]
			then
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress1="$Cwan6_1TrackIp1"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress2="$Cwan6_1TrackIp2"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress3="$Cwan6_1TrackIp3"
				uci set routerapplicationconfig.routerapplicationlocalconfig.ipaddress4="$Cwan6_1TrackIp4"
			fi			
		fi 
		
	####################################################
	fi

			uci commit routerapplicationconfig
	UpdateRouterApplocalCfgModem1
	sleep 1
}


RouterConfigFileUpdate
. /root/ConfigFiles/RouterAppConfig/routerapplocalconfig.cfg

#PacketCount=4
#PingDeadline=4
MinPacketLoss=$failurecriteria
iretries=0
pingres=2

PingTest()
{
	PacketCount=$ping_count
	PingDeadline=$ping_count
	
	ipaddress=$1
	ifname=$2
	
	echo "interface is $interface"
	echo "ifname is $ifname"
	
	#For track hhtping IP is required... 
	IP=$(ifconfig "$ifname" | awk '/inet addr/{print substr($2,6)}')
	
	echo "IP is $IP"
	
	if [ "$track_method" = "ping" ];then
		PingOutput=$($track_method -I $ifname -c "$PacketCount" -w "$PingDeadline" "$ipaddress" 2>&1)
		PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')
		PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/transmitted/' | awk '{ print $1 }')
		PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/received/' | awk '{ print $1 }')
		PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }' | tr -d '\011\012\013\014\015\040')		
		echo "track_method is $track_method"
		echo "PingOutput is $PingOutput"
		echo "PacketsTransmitted is $PacketsTransmitted"
		echo "PacketsReceived is $PacketsReceived"
		echo "PacketLoss is $PacketLoss"
    #For track_method is httping... 
    else
		PingOutput=$($track_method -y $IP -c "$PacketCount" -W -t 2 "$ipaddress" 2>&1)
		PingOutput=$(echo "$PingOutput" | awk '/connects|ok|failed|errors/')
		PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/connects/' | awk '{ print $1 }')
		PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/ok/' | awk '{ print $1 }')
		PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/failed/' | awk '{ print $1 }' | awk -F % '{ print $1 }' | awk -F . '{ print $1 }' | tr -d '\011\012\013\014\015\040')
	    echo "track_method is $track_method"
		echo "PingOutput is $PingOutput"
		echo "PacketsTransmitted is $PacketsTransmitted"
		echo "PacketsReceived is $PacketsReceived"
		echo "PacketLoss is $PacketLoss"
	fi
    
    if [ "x$PacketLoss" = "x" ] || [ "$PacketLoss" -ge "$MinPacketLoss" ] || [ "$PacketLoss" = "Resolving" ]
    then
        pingres=2
    else
        pingres=0
        break
    fi
    
    if [ "x$PacketLoss" = "x" ]
    then
        CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
        LogMsg="\"<\",\"Network unreachable,\"$CurrentDate\"\">\""
        echo $LogMsg >> "/tmp/Log/RouterlocalpingMsgLog"
    else	
		CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
		LogMsg="\"<\",\"IPaddress:$ipaddress\",\"PacketTx:$PacketsTransmitted\",\"PacketRx:$PacketsReceived\",\"PacketLoss:$PacketLoss\",\"$CurrentDate\",\">\""
		echo $LogMsg >> "/tmp/Log/RouterlocalpingMsgLog"
	fi
	
	echo $pingres > "/tmp/RouterlocalpingTestApp.txt"
	return $pingres
}

#For ping or httping we take track_method from mwan3 config file...

if [ "$CellularOperationMode" = "dualcellularsinglesim" ]
then
	if [ "$Pdp1" = "1" ]  || [ "$Pdp1" = "3" ]
	then
		interface="CWAN1"
		track_method=$(uci get mwan3.$interface.track_method)
		ping_count=$(uci get mwan3.$interface.up)
		ifname=$(uci get modem.${interface}.interfacename)
	else
		interface="wan6c1"
		track_method=$(uci get mwan3.$interface.track_method)
		ping_count=$(uci get mwan3.$interface.up)
		ifname=$(uci get modem.CWAN1.interfacename)
	fi
elif [ "$CellularOperationMode" = "singlecellulardualsim" ]
then
	#Check which interface is enabled
	modemenable1=$(uci get modem.CWAN1_0.modemenable)
	modemenable2=$(uci get modem.CWAN1_1.modemenable)
	Pdp1=$(uci get sysconfig.sysconfig.pdp)
	
	if [ "$modemenable1" = "1" ]
	then
		if [ "$Pdp1" = "IPV4" ]  || [ "$Pdp1" = "IPV4V6" ]
		then
			interface="CWAN1_0"
			track_method=$(uci get mwan3.$interface.track_method)
			ping_count=$(uci get mwan3.$interface.up)
			ifname=$(uci get modem.${interface}.interfacename)
		else
			interface="wan6c1"
			track_method=$(uci get mwan3.$interface.track_method)
			ping_count=$(uci get mwan3.$interface.up)
			ifname=$(uci get modem.CWAN1_0.interfacename)
		fi		
	else
		if [ "$Pdp1" = "IPV4" ]  || [ "$Pdp1" = "IPV4V6" ]
		then	
			interface="CWAN1_1"
			track_method=$(uci get mwan3.$interface.track_method)
			ping_count=$(uci get mwan3.$interface.up)
			ifname=$(uci get modem.${interface}.interfacename)
		else
			interface="wan6c2"
			track_method=$(uci get mwan3.$interface.track_method)
			ping_count=$(uci get mwan3.$interface.up)
			ifname=$(uci get modem.CWAN1_1.interfacename)
		fi	
	fi
else
	if [ "$Pdp1" = "IPV4" ]  || [ "$Pdp1" = "IPV4V6" ]
	then
		interface="CWAN1"
		track_method=$(uci get mwan3.$interface.track_method)
		ping_count=$(uci get mwan3.$interface.up)
		ifname=$(uci get modem.${interface}.interfacename)
	else
		interface="wan6c1"
		track_method=$(uci get mwan3.$interface.track_method)
		ping_count=$(uci get mwan3.$interface.up)
		ifname=$(uci get modem.CWAN1.interfacename)
	fi
	
fi
	
	case "$noofipaddress" in
		1)
			PingTest "$ipaddress1" "$ifname"
			echo "$ipaddress1 $ifname" >> /tmp/pingtest.txt
			;;
		2)
			PingTest "$ipaddress1" "$ifname"
			ret=$?
			if [ "$ret" != 0 ]; then
				PingTest "$ipaddress2" "$ifname"
			else
				exit 0
			fi
			;;
		3)
			PingTest "$ipaddress1" "$ifname"
			echo "$ipaddress1 $ifname" >> /tmp/pingtest.txt
			ret=$?
			if [ "$ret" != 0 ]; then
				PingTest "$ipaddress2" "$ifname"
				ret=$?
				if [ "$ret" != 0 ]; then
					PingTest "$ipaddress3" "$ifname"
				else
					exit 0
				fi
			else
				exit 0
			fi
			;;
		4)
			PingTest "$ipaddress1" "$ifname"
			ret=$?
			if [ "$ret" != 0 ]; then
				PingTest "$ipaddress2" "$ifname"
				ret=$?
				if [ "$ret" != 0 ]; then
					PingTest "$ipaddress3" "$ifname"
					ret=$?
					if [ "$ret" != 0 ]; then
						PingTest "$ipaddress4" "$ifname"
					else
						exit 0
					fi
				else
					exit 0
				fi
			else
				exit 0
			fi
			;;
	*)
	;;
	esac

exit 0
