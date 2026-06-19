#The cellular_handler script takes care of all the cellular related changes.

#############################################################################################################

#!/bin/sh

. /lib/functions.sh

cellularwan1interface="CWAN1"
cellularwan2interface="CWAN2"
cellularwan3interface="CWAN3"
cellularwan1sim1interface="CWAN1_0"
cellularwan1sim2interface="CWAN1_1"

#IPV6 Variables 
cellular1wan6interface="wan6c1"
cellular2wan6interface="wan6c2"
mwan3status=$(uci get mwan3config.general.select)

SystemConfigFile="/etc/config/sysconfig"
SystemGpioConfig="/etc/config/systemgpio"
simtmpfile="/tmp/simnumfile"
SimNumFile="/tmp/simnumfile"
SimSelectGpio=$(uci get systemgpio.gpio.simselectgpio)
EnableCellular=$(uci get sysconfig.sysconfig.enablecellular)
CellularOperationModelocal=$(uci get sysconfig.sysconfig.CellularOperationMode)
Sim1SelectValue=$(uci get systemgpio.gpio.sim1selectvalue)
SmsEnable1=$(uci get sysconfig.smsconfig.smsenable1)
SmsEnable2=$(uci get sysconfig.smsconfig.smsenable2)
Logfile="/root/ConfigFiles/Logs/AddIfaceLog.txt"
Findapn="/root/InterfaceManager/script/cellular/findapn.sh"
AutoApnFlag="/root/usrRPC/script/autoapnflag.txt"
SimSwitchingGpio="/sys/class/gpio/gpio$SimSelectGpio/value"

ifstatus wan6c1 | jq -r '
		  .["ipv6-prefix"][]?.assigned |
		  to_entries[] |
		  "\(.key) \(.value.address)/\(.value.mask)"
		' > /tmp/wan6c1_prefixes

ifstatus wan6c2 | jq -r '
		  .["ipv6-prefix"][]?.assigned |
		  to_entries[] |
		  "\(.key) \(.value.address)/\(.value.mask)"
		' > /tmp/wan6c2_prefixes

pkill -9 -f /root/InterfaceManager/script/cellular/PrimarySwitch.sh
uci delete network.CWAN1 > /dev/null 2>&1
uci delete network.CWAN1_0 > /dev/null 2>&1
uci delete network.CWAN1_1 > /dev/null 2>&1
uci delete network.wan6c1 > /dev/null 2>&1
uci delete network.wan6c2 > /dev/null 2>&1
uci commit network
ubus call network reload
mwan3 stop

Dhcpv6()
{
	interface="$1"
	
	#echo "$interface $(date '+%Y-%m-%d %H:%M:%S')" >> /tmp/ip6class.txt
	
	# Loop through all interfaces + prefixes dynamically
	while read -r iface prefix; do
	
		#echo "$iface $(date '+%Y-%m-%d %H:%M:%S')" >> /tmp/ip6class.txt
		#echo "$prefix $(date '+%Y-%m-%d %H:%M:%S')" >> /tmp/ip6class.txt
			
		# Get interface name from network config
		ifname=$(uci -q get network.$iface.ifname)

		# Skip if no ifname found
		[ -z "$ifname" ] && continue

		#echo "Deleting IPv6 prefix $prefix and flushing address on $iface ($ifname)..."
		
		# Flush IPv6 addresses on that interface
		ip -6 addr flush dev "$ifname" 2>/dev/null
		
		# Delete IPv6 route for that prefix
		ip -6 route del "$prefix" dev "$ifname" 2>/dev/null

		
	done < /tmp/"$interface"_prefixes
	rm -f /tmp/"$interface"_prefixes
	
}

Dhcpv6 wan6c1
Dhcpv6 wan6c2

SetAPNSim1()
{
	date=$(date)
	Protocol=$(uci get modem.CWAN1_0.protocol)
	PDP1=$(uci get sysconfig.sysconfig.pdp)
	username=$(uci get sysconfig.sysconfig.username)
	password=$(uci get sysconfig.sysconfig.password)
	auth=$(uci get sysconfig.sysconfig.auth)
	Sim1apntype=$(uci get sysconfig.sysconfig.Sim1apntype)
	Sim2apntype=$(uci get sysconfig.sysconfig.Sim2apntype)
	if [ -z "$username" ]
	then
		username=""
		password=""
	else
		username=$username
		password=$password
	fi
	auth=$auth
	if [ "$PDP1" = "IPV4" ] 
	then
			PDPN=1
		  	PDP_QMI=IP
	elif [ "$PDP1" = "IPV6" ] 
	then
			PDPN=2
		  	PDP_QMI=IPV6
	elif [ "$PDP1" = "IPV4V6" ] 
	then
		  PDPN=3
		  PDP_QMI=IPV4V6
	fi
	
	InterfaceName=CWAN1_0
	if [ $InterfaceName = "CWAN1_0" ] || [ $InterfaceName = "CWAN1" ] 
	then
	    if [ $Sim1apntype = "auto" ] 
	    then
			echo "SETAPN=1" > "$AutoApnFlag"
			echo "$Sim1SelectValue" > "$SimSwitchingGpio"
			/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh 
			sleep 20
			response=$($Findapn  $InterfaceName)  /dev/null 2>&1
			sleep 5
			echo "SETAPN=0" > "$AutoApnFlag"
			APN=$(uci get sysconfig.sysconfig.sim1autoapn)
	    elif [ $Sim1apntype = "manual" ]
	    then
	     	APN=$(uci get sysconfig.sysconfig.apn)
	    fi
	fi
	
	
	if [ "$Protocol" = "cdcether" ]
	then
	    for i in 1 2 3 4 5 6                                                                                     
		do
		    Status=$(/bin/at-cmd /dev/ttyUSB$i AT+QICSGP=1,"$PDPN",\"$APN\",\"$username\",\"$password\","$auth" | awk NR==2 | tr -d '\011\012\013\014\015\040')                           
			if [ "$Status" = "OK" ]                                                                                 
			then
			    /bin/at-cmd /dev/ttyUSB$i AT+QIDEACT=1
			    echo "$date:[cellular handler.sh]APN set Successfully for sim1 ,APN=$APN,PDP=$PDPN" >> "$Logfile"
			    break
			else 
			     /bin/at-cmd /dev/ttyUSB$i AT+QIDEACT=1
			fi
	    done
	    if [ "$Status" != "OK" ]                                                                                 
		then
		    /bin/at-cmd /dev/ttyUSB$i AT+QIDEACT=1
		    echo "$date:[cellular handler.sh]Status is not ok for APN and PDP AT command in sim1,APN=$APN,PDP=$PDPN,comport=$ComPort,username=$username,password=$password,auth=$auth" >> "$Logfile"
		    /bin/at-cmd /dev/ttyUSB$i AT+QIDEACT=1
		    break
		fi    
	elif [ "$Protocol" = "qmi" ]
	then
		for i in 1 2 3 4 5 6                                                                                        
		do
			Status=$(/bin/at-cmd /dev/ttyUSB$i AT+CGDCONT=1,\"$PDP_QMI\",\"$APN\","","","" | awk NR==2 | tr -d '\011\012\013\014\015\040') 
		    if [ "$Status" = "OK" ]                                                                                 
			then
			    echo "$date:[cellular handler.sh][cgdcont]APN set Successfully for sim1,APN=$APN,PDP=$PDP_QMI,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
			    break
			fi
		    if [ "$Status" != "OK"  ]
		    then
		    	echo "$date:[cellular handler.sh]Status is not ok for APN and PDP[cgdcont]...so using qicsgp AT command in sim1,APN=$APN,PDP=$PDP_QMI,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
			   Status=$(/bin/at-cmd /dev/ttyUSB$i AT+QICSGP=1,"$PDPN",\"$APN\",\"$username\",\"$password\","$auth" | awk NR==2 | tr -d '\011\012\013\014\015\040')                           
			fi
			if [ "$Status" = "OK" ]                                                                                 
			then
				echo "$date:[cellular handler.sh][using qicsgp]APN set Successfully for sim1,APN=$APN,PDP=$PDPN,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
				break
			else
		    	echo "$date:[cellular handler.sh]Status is not ok for APN and PDP[using qicsgp] ..trying for next USB loop for sim1,APN=$APN,PDP=$PDP_QMI,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
			fi
	    done
	fi
}

#restart_flag=$(/root/InterfaceManager/script/common_scripts/create_mwan3_interface.sh cellular 2>/dev/null)
/bin/UpdateWanConfig.sh
/root/InterfaceManager/script/cellular/cellular_settings.sh

#Reboot the modem to run hotplug script.
if [ "$EnableCellular" = "1" ]
then
	if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
	then
		#/usr/sbin/mwan3 ifdown CWAN1_0 
		#/usr/sbin/mwan3 ifdown CWAN1_1 
		/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh
	elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
	then
		#create the below markers, so that the ifdown event gets ignored. Else, the ifdown event switches the sim.
		touch /tmp/mwan-ignore-CWAN1_0
		touch /tmp/mwan-ignore-wan6c1
		touch /tmp/mwan-ignore-CWAN1_1
		touch /tmp/mwan-ignore-wan6c2
		#Create ifdown event for the cellular interfaces, since we don't want mwan3 to track till the modem is updated.
		#/usr/sbin/mwan3 ifdown $cellularwan1sim1interface
		#/usr/sbin/mwan3 ifdown $cellular1wan6interface
		simnum=$(cat /tmp/simnumfile)                                                                                         
		touch "$simtmpfile"
		echo 1 > "$simtmpfile"
		SetAPNSim1
		echo "$Sim1SelectValue" > "$SimSwitchingGpio"		
		/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh		
	elif [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
	then 		
		#create the below markers, so that the ifdown event gets ignored. Else, the ifdown event switches the sim.
		touch /tmp/mwan-ignore-CWAN1
		touch /tmp/mwan-ignore-wan6c1
		
		#Create ifdown event for the cellular interfaces, since we don't want mwan3 to track till the modem is updated.
		#/usr/sbin/mwan3 ifdown $cellularwan1interface
		#/usr/sbin/mwan3 ifdown $cellular1wan6interface
		touch "$simtmpfile"
		echo 1 > "$simtmpfile"
		SetAPNSim1
		echo "$Sim1SelectValue" > "$SimSwitchingGpio"
		/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh		
	else	
		#Add CWAN2 to down the CWAN2 and remove from network file
		#Earlier it wouldn't get removed when switched from dual cellular to single cellular.
		/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh		
	fi

else
	uci delete network."${cellularwan1interface}" > /dev/null 2>&1
	uci delete network."${cellularwan2interface}" > /dev/null 2>&1
	uci delete network."${cellularwan3interface}" > /dev/null 2>&1
	uci delete network."${cellularwan1sim1interface}" > /dev/null 2>&1
	uci delete network."${cellularwan1sim2interface}" > /dev/null 2>&1
	uci commit network
fi

ubus call firewall reload
ubus call network reload

echo > /proc/net/nf_conntrack

sleep 1

#Kill SMS related files.
pkill -9 -f /root/InterfaceManager/script/cellular/SMS_Incomming_event.sh
pkill -9 -f "inotifywait /var/spool/sms/incoming/ -e create"
sleep 10
if [ "$mwan3status" = "failover" ] || [ "$mwan3status" = "balanced" ]
then
    /etc/init.d/mwan3 start
elif [ "$mwan3status" = "none" ] 
then
      mwan3 stop
fi
#SMS
if [ "$SmsEnable1" = "1" ] || [ "$SmsEnable2" = "1" ]
then
	/root/InterfaceManager/script/cellular/SMS_Incomming_event.sh & > /dev/null 2>&1
fi

if [ "$EnableCellular" = "0" ]
then
   sed -i '/Reset_data_usage/d' /etc/crontabs/root
   sed -i '/cellulardatausagemanagerspeedcronscript/d' /etc/crontabs/root
   sed -i '/Data_Cap/d' /etc/crontabs/root
fi

#Restart VPNs, PBR & nodogsplash.
/root/InterfaceManager/script/ethernet/multiple_scripts_restart.sh

exit 0
