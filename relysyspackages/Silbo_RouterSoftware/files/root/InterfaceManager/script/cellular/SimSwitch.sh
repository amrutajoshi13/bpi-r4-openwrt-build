#!/bin/sh

. /lib/functions.sh

AutoApnFlag="/root/usrRPC/script/autoapnflag.txt"
ReadSystemConfigFile()
{
   	config_load "$SystemConfigFile"
   	config_get EnableCellular sysconfig enablecellular
}

ReadSystemGpioFile()
{
	config_load "$SystemGpioConfig"
	config_get SimSelectGpio gpio simselectgpio
	config_get Sim1SelectValue gpio sim1selectvalue
	config_get Sim2SelectValue gpio sim2selectvalue
	config_get Sim1LedGpio gpio Sim1LedGpio
	config_get Sim1LedGpioOnvalue gpio Sim1LedGpioOnvalue
	config_get Sim1LedGpioOffvalue gpio Sim1LedGpioOffvalue
	config_get Sim2LedGpio gpio Sim2LedGpio
	config_get Sim2LedGpioOnvalue gpio Sim2LedGpioOnvalue
	config_get Sim2LedGpioOffvalue gpio Sim2LedGpioOffvalue
}

Interface="$1"
Simnum="$2"
date=$(date)
cellular1wan6interface=wan6c1
cellular2wan6interface=wan6c2
Logfile="/root/ConfigFiles/Logs/AddIfaceLog.txt"
SystemGpioConfig="/etc/config/systemgpio"
SimNumFile="/tmp/simnumfile"
SystemConfigFile="/etc/config/sysconfig"
Findapn="sh -x /root/InterfaceManager/script/cellular/findapn.sh"
ReadSystemConfigFile
ReadSystemGpioFile

model1=$(uci get sysconfig.sysconfig.model1)
sim2pdp=$(uci get sysconfig.sysconfig.sim2pdp)
SimSwitchingGpio="/sys/class/gpio/gpio$SimSelectGpio/value"
Protocol=$(uci get modem.CWAN1_0.protocol)
PDP1=$(uci get sysconfig.sysconfig.pdp)
username=$(uci get sysconfig.sysconfig.username)
password=$(uci get sysconfig.sysconfig.password)
auth=$(uci get sysconfig.sysconfig.auth)
Sim1apntype=$(uci get sysconfig.sysconfig.Sim1apntype)
Sim2apntype=$(uci get sysconfig.sysconfig.Sim2apntype)
EnableIpsec=$(uci get vpnconfig1.general.enableipsecgeneral)
CWAN1_0ifname=$(uci get modem.CWAN1_0.interfacename)
CWAN1_1ifname=$(uci get modem.CWAN1_1.interfacename)
#Set APN for sim1
SetAPNSim1()
{
	date=$(date)

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
			    echo "$date:[SimSwitch script]APN set Successfully for sim1 ,APN=$APN,PDP=$PDPN" >> "$Logfile"
			    break
			fi
	    done
	    if [ "$Status" != "OK" ]                                                                                 
			then
			    /bin/at-cmd /dev/ttyUSB$i AT+QIDEACT=1
			    echo "$date:[SimSwitch script]Status is not ok for APN and PDP AT command in sim1,APN=$APN,PDP=$PDPN,comport=$ComPort,username=$username,password=$password,auth=$auth" >> "$Logfile"
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
			    echo "$date:[SimSwitch script][cgdcont]APN set Successfully for sim1,APN=$APN,PDP=$PDP_QMI,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
			    break
			fi
		    if [ "$Status" != "OK"  ]
		    then
		    	echo "$date:[SimSwitch script]Status is not ok for APN and PDP[cgdcont]...so using qicsgp AT command in sim1,APN=$APN,PDP=$PDP_QMI,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
			   Status=$(/bin/at-cmd /dev/ttyUSB$i AT+QICSGP=1,"$PDPN",\"$APN\",\"$username\",\"$password\","$auth" | awk NR==2 | tr -d '\011\012\013\014\015\040')                           
			fi
			if [ "$Status" = "OK" ]                                                                                 
			then
				echo "$date:[SimSwitch script][using qicsgp]APN set Successfully for sim1,APN=$APN,PDP=$PDPN,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
				break
			else
		    	echo "$date:[SimSwitch script]Status is not ok for APN and PDP[using qicsgp] ..trying for next USB loop for sim1,APN=$APN,PDP=$PDP_QMI,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
			fi
	    done
	fi
}

#set APN and PDP for sim2 before sim switching
SetAPNSim2()
{
		Protocol=$(uci get modem.CWAN1_1.protocol)
		PDP1=$(uci get sysconfig.sysconfig.sim2pdp)
		username=$(uci get sysconfig.sysconfig.sim2username)
		password=$(uci get sysconfig.sysconfig.sim2password)
		auth=$(uci get sysconfig.sysconfig.sim2auth)
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
		
		InterfaceName=CWAN1_1
		if [ $InterfaceName = "CWAN1_1" ] 
		then
		    if [ $Sim2apntype = "auto" ] 
		    then
				echo "SETAPN=1" > "$AutoApnFlag"
				echo "$Sim2SelectValue" > "$SimSwitchingGpio"
				ComPort=$(cat /tmp/InterfaceManager/status/ports.txt | cut -d "=" -f2)
				/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh $ComPort
				sleep 20
				response=$($Findapn  $InterfaceName)  /dev/null 2>&1
				sleep 5
				echo "SETAPN=0" > "$AutoApnFlag"
				APN=$(uci get sysconfig.sysconfig.sim2autoapn)
		    elif [ $Sim2apntype = "manual" ]
		    then  
		       	APN=$(uci get sysconfig.sysconfig.sim2apn)
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
				    echo "$date:[SimSwitch script]APN set Successfully for sim2 ,APN=$APN,PDP=$PDPN" >> "$Logfile"
				    break
				fi
		    done
		     if [ "$Status" != "OK" ]                                                                                 
				then
				    /bin/at-cmd /dev/ttyUSB$i AT+QIDEACT=1
				    echo "$date:[SimSwitch script]Status is not ok for APN and PDP AT command in sim2,APN=$APN,PDP=$PDPN,comport=$ComPort,username=$username,password=$password,auth=$auth" >> "$Logfile"
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
					    echo "$date:[SimSwitch script][cgdcont]APN set Successfully for sim2,APN=$APN,PDP=$PDP_QMI,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
					    break
				fi
            if [ "$Status" != "OK"  ]
		    then
		    	echo "$date:[SimSwitch script]Status is not ok for APN and PDP [cgdcont] so using qicsgp AT command in sim2,APN=$APN,PDP=$PDP_QMI,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
			   Status=$(/bin/at-cmd /dev/ttyUSB$i AT+QICSGP=1,"$PDPN",\"$APN\",\"$username\",\"$password\","$auth" | awk NR==2 | tr -d '\011\012\013\014\015\040')                           
		    fi
			    if [ "$Status" = "OK" ]                                                                                 
					then
					    echo "$date:[SimSwitch script][using qicsgp]APN set Successfully for sim2,APN=$APN,PDP=$PDPN,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
					    break
                              else
		    	echo "$date:[SimSwitch script]Status is not ok for APN and PDP [qicsgp] so trying for next USB loop in  sim2,APN=$APN,PDP=$PDPN,comport=/dev/ttyUSB$i,username=$username,password=$password,auth=$auth" >> "$Logfile"
				fi
            done
		fi
}


if [ "$EnableCellular" = "1" ]
then
	uci delete  network.CWAN1_0
	uci delete  network.CWAN1_1
	uci delete  network.CWAN1
	uci delete  network.wan6c1
	uci delete  network.wan6c2
	uci commit network
	[ ! -f "$SimNumFile" ] && touch $SimNumFile
	echo "$Simnum" > "$SimNumFile"

	if [ "$Simnum" = "1" ]
	then
	    if [ "$model1" != "EM05-G" ]
		then
			SetAPNSim1
		fi
		Protocol=$(uci get modem.CWAN1_0.protocol)
		echo 1 > "$SimNumFile"
		uci set modem.CWAN1_0.modemenable=1                             
		uci set modem.CWAN1_1.modemenable=0                         
		uci set modem.CWAN1.modemenable=0                           
		uci commit modem 
		echo "$Sim1SelectValue" > "$SimSwitchingGpio"
		logger -t modem -p customs.info "Switched to sim1"
		InterfaceSim="$Interface"_0
		InterfaceSim1="$Interface"_1
		/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh 
		uci delete firewall.cwan1_0 > /dev/null 2>&1
		uci delete firewall.cwan1_1 > /dev/null 2>&1
		uci delete firewall.cwan1 > /dev/null 2>&1
		uci delete firewall.udp_DHCPv6c1_replies > /dev/null 2>&1
		uci delete firewall.udp_DHCPv6c2_replies > /dev/null 2>&1
		uci delete firewall.wan6c1 > /dev/null 2>&1
		uci delete firewall.wan6c2 > /dev/null 2>&1
		if [ "$PDP1" = "IPV4" ] || [ "$PDP1" = "IPV4V6" ];then
		    uci set firewall.cwan1_0=zone
			uci set firewall.cwan1_0.name='CWAN1_0'
			uci set firewall.cwan1_0.input='REJECT'
			uci set firewall.cwan1_0.output='ACCEPT'
			uci set firewall.cwan1_0.forward='ACCEPT'
			uci set firewall.cwan1_0.network='CWAN1_0'
			uci set firewall.cwan1_0.masq='1'
			uci set firewall.cwan1_0.mtu_fix='1'
			
			if [ "$EnableIpsec" = "1" ]
			then
			    uci set firewall.cwan1_0.extra_src="-i ${CWAN1_0ifname} -m policy --dir in --pol none"
				uci set firewall.cwan1_0.extra_dest="-o ${CWAN1_0ifname} -m policy --dir out --pol none"
			else 
			    uci set firewall.cwan1_0.extra_src='-m policy --dir in --pol none'
				uci set firewall.cwan1_0.extra_dest='-m policy --dir out --pol none'	
			fi 
		fi
		
		if [ "$PDP1" = "IPV6" ];then
			uci set firewall.$cellular1wan6interface=zone
			uci set firewall.$cellular1wan6interface.name="$cellular1wan6interface"
			uci set firewall.$cellular1wan6interface.input="REJECT"
			uci set firewall.$cellular1wan6interface.output="ACCEPT"
			uci set firewall.$cellular1wan6interface.forward="ACCEPT"
			uci set firewall.$cellular1wan6interface.network="$cellular1wan6interface"
			uci set firewall.$cellular1wan6interface.masq="1"
			uci set firewall.$cellular1wan6interface.mtu_fix="1"
			if [ "$EnableIpsec" = "1" ]
			then
			    uci set firewall.$cellular1wan6interface.extra_src="-i ${CWAN1_0ifname} -m policy --dir in --pol none"
				uci set firewall.$cellular1wan6interface.extra_dest="-o ${CWAN1_0ifname} -m policy --dir out --pol none"
			else 
			    uci set firewall.$cellular1wan6interface.extra_src="-m policy --dir in --pol none"
				uci set firewall.$cellular1wan6interface.extra_dest="-m policy --dir out --pol none"	
			fi 
							
		fi
		if [ "$PDP1" = "IPV6" ] || [ "$PDP1" = "IPV4V6" ];then
			uci set firewall.udp_DHCPv6c1_replies=rule
			uci set firewall.udp_DHCPv6c1_replies.target='ACCEPT'
			uci set firewall.udp_DHCPv6c1_replies.src="$cellular1wan6interface"
			uci set firewall.udp_DHCPv6c1_replies.proto='udp'
			uci set firewall.udp_DHCPv6c1_replies.dest_port='546'
			uci set firewall.udp_DHCPv6c1_replies.name='Allow DHCPv6c1 replies'
			uci set firewall.udp_DHCPv6c1_replies.family='ipv6'
			uci set firewall.udp_DHCPv6c1_replies.src_port='547'  
		fi 	 
	else
	    if [ "$model1" != "EM05-G" ]
		then
			SetAPNSim2
		fi
	    echo 2 > "$SimNumFile"
	    
	    uci set modem.CWAN1_0.modemenable=0               
	    uci set modem.CWAN1_1.modemenable=1            
	    uci set modem.CWAN1.modemenable=0            
	    uci commit modem 
	   echo "$Sim2SelectValue" > "$SimSwitchingGpio"
	   logger -t modem -p customs.info "Switched to sim2"
	   InterfaceSim="$Interface"_0                                                      
	   InterfaceSim1="$Interface"_1 
	  /root/usrRPC/script/Recycle_WAN1_PWR_Script.sh 
	  	uci delete firewall.cwan1_0 > /dev/null 2>&1
		uci delete firewall.cwan1_1 > /dev/null 2>&1
		uci delete firewall.cwan1 > /dev/null 2>&1
		uci delete firewall.udp_DHCPv6c1_replies > /dev/null 2>&1
		uci delete firewall.udp_DHCPv6c2_replies > /dev/null 2>&1
		uci delete firewall.wan6c1 > /dev/null 2>&1
		uci delete firewall.wan6c2 > /dev/null 2>&1
	  #/root/InterfaceManager/script/InterfaceInitializer.sh start "${InterfaceSim1}"
	    if [ "$sim2pdp" = "IPV4" ] || [ "$sim2pdp" = "IPV4V6" ];then
		    uci set firewall.cwan1_1=zone
			uci set firewall.cwan1_1.name='CWAN1_1'
			uci set firewall.cwan1_1.input='REJECT'
			uci set firewall.cwan1_1.output='ACCEPT'
			uci set firewall.cwan1_1.forward='ACCEPT'
			uci set firewall.cwan1_1.network='CWAN1_1'
			uci set firewall.cwan1_1.masq='1'
			uci set firewall.cwan1_1.mtu_fix='1'
			if [ "$EnableIpsec" = "1" ]
			then
			    uci set firewall.cwan1_1.extra_src="-i ${CWAN1_1ifname} -m policy --dir in --pol none"
				uci set firewall.cwan1_1.extra_dest="-o ${CWAN1_1ifname} -m policy --dir out --pol none"
			else 
			   uci set firewall.cwan1_1.extra_src='-m policy --dir in --pol none'
				uci set firewall.cwan1_1.extra_dest='-m policy --dir out --pol none'	
			fi 

			
		fi
		if [ "$sim2pdp" = "IPV6" ] ;then
			uci set firewall.$cellular2wan6interface=zone
			uci set firewall.$cellular2wan6interface.name="$cellular2wan6interface"
			uci set firewall.$cellular2wan6interface.input="REJECT"
			uci set firewall.$cellular2wan6interface.output="ACCEPT"
			uci set firewall.$cellular2wan6interface.forward="ACCEPT"
			uci set firewall.$cellular2wan6interface.network="$cellular2wan6interface"
			uci set firewall.$cellular2wan6interface.masq="1"
			uci set firewall.$cellular2wan6interface.mtu_fix="1"

			if [ "$EnableIpsec" = "1" ]
			then
			    uci set firewall.$cellular2wan6interface.extra_src="-i ${CWAN1_1ifname} -m policy --dir in --pol none"
				uci set firewall.$cellular2wan6interface.extra_dest="-o ${CWAN1_1ifname} -m policy --dir out --pol none"
			else 
			   uci set firewall.$cellular2wan6interface.extra_src="-m policy --dir in --pol none"
			   uci set firewall.$cellular2wan6interface.extra_dest="-m policy --dir out --pol none"	
			fi 

				
		fi	
		if [ "$sim2pdp" = "IPV6" ] || [ "$sim2pdp" = "IPV4V6" ];then
			uci set firewall.udp_DHCPv6c2_replies=rule
			uci set firewall.udp_DHCPv6c2_replies.target='ACCEPT'
			uci set firewall.udp_DHCPv6c2_replies.src="$cellular2wan6interface"
			uci set firewall.udp_DHCPv6c2_replies.proto='udp'
			uci set firewall.udp_DHCPv6c2_replies.dest_port='546'
			uci set firewall.udp_DHCPv6c2_replies.name='Allow DHCPv6c2 replies'
			uci set firewall.udp_DHCPv6c2_replies.family='ipv6'
			uci set firewall.udp_DHCPv6c2_replies.src_port='547'      
		fi		
	fi         
	uci commit firewall 
	fw3 reload
fi

#Removing Sig.txt file once the sim is switched to read the new values for simswitch based on signal strength.
rm -rf /tmp/Sig.txt

exit 0
