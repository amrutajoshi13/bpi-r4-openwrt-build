#!/bin/sh

. /lib/functions.sh

#
# PKG_RELEASE: 1.01
#

#
# Read Modem Configuration file
# 
Source=modem
logger -t $Source -p customs.info "addinterface executed"
policy_type=$(uci get mwan3config.general.select)

		SystemGpioConfig="/etc/config/systemgpio"
		date=$(date)

ReadModemConfigFile()
{
	config_load "$ModemConfigFile"
	config_get ModemEnable "$InterfaceName" modemenable
	config_get DataEnable "$InterfaceName" dataenable
	config_get ConfiguredDataPort "$InterfaceName" device
	config_get ConfiguredComPort "$InterfaceName" comport
	config_get ConfiguredAltComPort "$InterfaceName" altcomport
	config_get PortType "$InterfaceName" porttype
	config_get APN "$InterfaceName" apn
	config_get Metric "$InterfaceName" metric
	config_get Proto "$InterfaceName" proto
	config_get Service "$InterfaceName" bandselectenable
	config_get Protocol "$InterfaceName" protocol
	config_get dualsimsinglemodule "$InterfaceName" dualsimsinglemodule
	config_get mtu "$InterfaceName" mtu
	config_get ifname "$InterfaceName" interfacename
}

ReadSystemConfigFile()
{
	config_load "$SystemConfigFile"
	config_get EnableCellular sysconfig enablecellular
	config_get cellularmodem1 sysconfig cellularmodem1
	config_get PrimarySimSwitchBackEnable sysconfig primarysimswitchbackenable
	config_get PrimarySimSwitchBackTime sysconfig primarysimswitchbacktime
	config_get smsenable1 smsconfig smsenable1
	config_get PDP1 sysconfig pdp
	config_get PDP2 sysconfig sim2pdp
	config_get auth sysconfig auth
	config_get sim2auth sysconfig sim2auth
	config_get username sysconfig username
	config_get password sysconfig password
	config_get sim2username sysconfig sim2username
	config_get sim2password sysconfig sim2password
	config_get Sim1apntype sysconfig Sim1apntype
	config_get Sim2apntype sysconfig Sim2apntype
	config_get sim1autoapn sysconfig sim1autoapn
	config_get sim2autoapn sysconfig sim2autoapn
	config_get Sim1mtu sysconfig Sim1mtu
	config_get Sim2mtu sysconfig Sim2mtu
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


#Calling this function everytime after ModemReboot Function is called.
CheckAddIfaceRunningstatus()
{
	#Exit if the AddIfaceRunningstatus1 flag is set to 1. 
	AddIfaceRunningstatus=$(cat /tmp/AddIfaceRunningstatus | cut -d "=" -f2)
	if [ "$AddIfaceRunningstatus" = "1" ] 
	then 
		exit 0
	fi
}

#
# Search for Communication & data port and write the same into file 
#
PortSearch()
{
	date=$(date) 
	echo "============ $date START OF MODEM INITIALISATION============" >> "$Logfile"
   
		if [ "$PortType" = "ttyS" ]
		then
		date=$(date)
		echo "$date PortType=ttyS" >> "$Logfile"
				if [ "x$ConfiguredDataPort" != "x" ]
				then
						# Get original/enumerated data port 
						EnmDataPort="/dev/ttyS""$ConfiguredDataPort"
				fi
				
				if [ "x$ConfiguredComPort" != "x" ]
				then
						# Get original/enumerated com port 
						EnmComPort="/dev/ttyS""$ConfiguredComPort"
				fi
				
				[ -c "$EnmDataPort" ]  && DataPort="$EnmDataPort"
				[ -c "$EnmComPort" ]  && ComPort="$EnmDataPort"
				
				echo "DataPort=$DataPort" > "$PortDetailsFile"
				echo "ComPort=$ComPort" >> "$PortDetailsFile"
				
				if [ ! -c "$EnmDataPort" ] && [ ! -c "$EnmComPort" ]
				then
						echo "status=Disabled" > "$AddIfaceStatusFile"
						echo "status=NE" >> "$PortDetailsFile"
				elif [ ! -c "$EnmDataPort" ]
				then
						echo "status=Disabled" > "$AddIfaceStatusFile"
						echo "status=DataPort NE" >> "$PortDetailsFile"
				elif [ ! -c "$EnmComPort" ]
				then
						echo "status=ComPort NE" >> "$PortDetailsFile"
						AddNetworkInterface
				else
						echo "status=Enumerated" >> "$PortDetailsFile"
							if [ "$EnableCellular" = "1" ]
							then
								for i in 1 2 3
								do
									simid=$(/bin/at-cmd "$EnmComPort" AT+QCCID | awk '/\+QCCID:/ {print $0}' | cut -d ":" -f 2)
									# if [ "${#simid}" -gt 10 ]
									if [ "${#simid}" -gt 10 ] && [ -n "$simid" ] && [[ "$simid" != "-" ]] && [[ "$simid" != *"Entry not found"* ]] && [[ "$simid" != *"ERROR"* ]];
									then
									    uci set system.system.qccid="$simid"
										uci set modemstatus.modemstatus.QCCID="$simid"
										uci commit modemstatus
												uci commit system
									   status="READY"
									   echo "$date:sim qccid is $simid using comport $EnmComPort" >> "$Logfile"
									   if [ $i = "3" ];then
											logger -t $Source -p customs.info "Qccid of $Simno is $simid"
									   fi
									   break
									else
									    $(/bin/at-cmd "$EnmDataPort" AT+QCCID | awk '/\+QCCID:/ {print $0}' | cut -d ":" -f 2)
										if [ "${#simid}" -gt 10 ] && [ -n "$simid" ] && [[ "$simid" != "-" ]] && [[ "$simid" != *"Entry not found"* ]] && [[ "$simid" != *"ERROR"* ]];
										then
										    	uci set system.system.qccid="$simid"
												uci set modemstatus.modemstatus.QCCID="$simid"
												uci commit modemstatus
												uci commit system
											status="READY"
											echo "$date:sim qccid is $simid using dataport $EnmDataPort" >> "$Logfile"
											logger -t $Source -p customs.info "Qccid of $Simno is $simid"
											break
										else
										    uci set system.system.qccid="Qccid Not found"
											uci set modemstatus.modemstatus.QCCID="ERROR"
											uci commit modemstatus
											uci commit system
											echo "$date:sim qccid is not ready $simid" >> "$Logfile"     
									        if [ $i = "3" ];then
												logger -t $Source -p customs.err "Qccid of $Simno is not found"
											fi
									    fi
									fi
								done
							   if [ "$status" = "READY" ]
							   then

								   if [ "$InterfaceName" = "CWAN1_0" ]
								   then
									uci set system.system.qccid="$simid"
									uci set modemstatus.modemstatus.QCCID="$simid"
										uci commit modemstatus
									uci commit system
									pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")
									kill -TERM "$pid" > /dev/null 2>&1
									sleep 1
									kill -KILL "$pid" > /dev/null 2>&1
								   AddNetworkInterface
								   else
									uci set system.system.qccid="$simid"
									uci set modemstatus.modemstatus.QCCID="$simid"
									uci commit modemstatus
									uci commit system
								    AddNetworkInterface
								   fi
							   else
								   if [ "$InterfaceName" = "CWAN1_0" ]
								   then
										logger -t $Source -p customs.info "Switching to sim2"
								   /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
								   if [ "$PrimarySimSwitchBackEnable" = "1" ]
								   then
									pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")
									kill -TERM "$pid" > /dev/null 2>&1
									sleep 1
									kill -KILL "$pid" > /dev/null 2>&1
									 /root/InterfaceManager/script/cellular/PrimarySwitch.sh "$PrimarySimSwitchBackTime" CWAN1 1 &         
								   fi
								   fi
								   if [ "$InterfaceName" = "CWAN1_1" ]
								   then
										logger -t $Source -p customs.info "Switching to sim1"
										/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
								   fi
								fi
							fi
				fi
		else
		date=$(date)
		echo "$date PortType=ttyUSB" >> "$Logfile"
				
				if [ "x$ConfiguredDataPort" != "x" ]
				then
						if [ "$cellularmodem1" != "QuectelRM500U" ] 
						then
							# Add an extra count to port number for searching
							ConfiguredDataPort=$((ConfiguredDataPort + 1))
						fi
						# Search for symbolically linked ports(generated by udev rule) and copy the same
						DataPortSymLink=$(find /dev -maxdepth 1 -name  "$InterfaceName""_"* | sort | sed -n $ConfiguredDataPort"p")
						# Get original/enumerated data port 
						[ "x$DataPortSymLink" != "x" ]  && DataPortSymLink="$DataPortSymLink" && EnmDataPort=$(readlink -f "$DataPortSymLink")
				
				fi
				
				if [ "x$ConfiguredComPort" != "x" ]
				then
					date=$(date)
					echo "$date ConfiguredComPort=$ConfiguredComPort" >> "$Logfile"
						if [ "$cellularmodem1" != "QuectelRM500U" ] 
						then
							# Add an extra count to port number for searching
							ConfiguredComPort=$((ConfiguredComPort + 1))
						fi
						# Search for symbolically linked ports(generated by udev rule) and copy the same
						ComPortSymLink=$(find /dev -maxdepth 1 -name  "$InterfaceName""_"* | sort | sed -n $ConfiguredComPort"p")
						# Get original/enumerated communication port
						[ "x$ComPortSymLink" != "x" ]  && ComPortSymLink="$ComPortSymLink" && EnmComPort=$(readlink -f "$ComPortSymLink")
				fi
				
				echo "DataPortSymLink=$DataPortSymLink" > "$PortDetailsFile"
				echo "ComPortSymLink=$ComPortSymLink" >> "$PortDetailsFile"
				echo "DataPort=$EnmDataPort" >> "$PortDetailsFile"
				echo "ComPort=$EnmComPort" >> "$PortDetailsFile"
				echo "DataPort=$EnmDataPort" > "$portdetails"
				echo "ComPort=$EnmComPort" > "$portdetails"
				echo "ComPort=$EnmDataPort" > "/tmp/InterfaceManager/status/Dataport.txt"
				
				date=$(date)
					echo "$date ComPortSymLink=$ComPortSymLink" >> "$Logfile"
					echo "$date EnmComPort=$EnmComPort" >> "$Logfile"
				
				if [ "x$DataPortSymLink" = "x" ] && [ "x$ComPortSymLink" = "x" ]
				then
				date=$(date)
				echo "$date No Data Port and No Comp port" >> "$Logfile"
						echo "status=PortLinks NE" >> "$PortDetailsFile"
						echo "status=Disabled" > "$AddIfaceStatusFile"
				elif [ "x$DataPortSymLink" = "x" ]
				then
				date=$(date)
				echo "$date No Data port" >> "$Logfile"
						echo "status=DataPortLink NE" >> "$PortDetailsFile"
						echo "status=Disabled" > "$AddIfaceStatusFile"
				else
			
						if [ "x$ComPortSymLink" = "x" ]
						then
								if [ "x$EnmDataPort" = "x" ]
								then
								date=$(date)
								echo "$date Both Comp Port and enData ports are not available" >> "$Logfile"
										echo "status=ComPortLink & DataPort NE" >> "$PortDetailsFile"
										echo "status=Disabled" > "$AddIfaceStatusFile"
								else
								date=$(date)
								echo "$date No Comp Port but enData port is available" >> "$Logfile"
										echo "status=ComPortLink NE" >> "$PortDetailsFile"
											if [ "$EnableCellular" = "1" ]
											then
												for i in 1 2 3 
												do
													simid=$(/bin/at-cmd "$EnmComPort" AT+QCCID | awk '/\+QCCID:/ {print $0}' | cut -d ":" -f 2)
													if [ "${#simid}" -gt 10 ] && [ -n "$simid" ] && [[ "$simid" != "-" ]] && [[ "$simid" != *"Entry not found"* ]] && [[ "$simid" != *"ERROR"* ]];
													then
													uci set system.system.qccid="$simid"
													uci set modemstatus.modemstatus.QCCID="$simid"
													uci commit modemstatus
													uci commit system
													   status="READY"
													   date=$(date)
													   echo "$date:sim qccid is $simid using comport $EnmComPort" >> "$Logfile"
													   logger -t $Source -p customs.info "Qccid of $Simno is $simid"

													   break
													else
													    simid=$(/bin/at-cmd "$EnmDataPort" AT+QCCID | awk '/\+QCCID:/ {print $0}' | cut -d ":" -f 2)
														if [ "${#simid}" -gt 10 ] && [ -n "$simid" ] && [[ "$simid" != "-" ]] && [[ "$simid" != *"Entry not found"* ]] && [[ "$simid" != *"ERROR"* ]];
														then
															uci set system.system.qccid="$simid"
															uci set modemstatus.modemstatus.QCCID="$simid"
															uci commit modemstatus
															uci commit system
															status="READY"
															date=$(date)
															echo "$date:sim qccid is $simid using dataport $EnmDataPort" >> "$Logfile"
															logger -t $Source -p customs.info "Qccid of $Simno is $simid"
															break
														else
														uci set system.system.qccid="Qccid Not found"
														uci set modemstatus.modemstatus.QCCID="ERROR"
														uci commit modemstatus
														uci commit system
														date=$(date)
															echo "$date:sim qccid is not ready $simid" >> "$Logfile"     
													    if [ $i = "3" ];then
															logger -t $Source -p customs.err "Qccid of $Simno is not found"    
													    fi
													    fi
													fi
												done
											   if [ "$status" = "READY" ]
											   then

												   if [ "$InterfaceName" = "CWAN1_0" ]
												   then
													uci set system.system.qccid="$simid"
													uci set modemstatus.modemstatus.QCCID="$simid"
													uci commit modemstatus
													uci commit system
   													pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")
													kill -TERM "$pid" > /dev/null 2>&1
													sleep 1
													kill -KILL "$pid" > /dev/null 2>&1
												   AddNetworkInterface
												   else
													uci set system.system.qccid="$simid"
													uci set modemstatus.modemstatus.QCCID="$simid"
													uci commit modemstatus
													uci commit system
													AddNetworkInterface
												   fi
											   else
												   if [ "$InterfaceName" = "CWAN1_0" ]
												   then
												  		logger -t $Source -p customs.info "Switching to sim2"
														/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
												   if [ "$PrimarySimSwitchBackEnable" = "1" ]
												   then
													pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")
													kill -TERM "$pid" > /dev/null 2>&1
													sleep 1
													kill -KILL "$pid" > /dev/null 2>&1
													 /root/InterfaceManager/script/cellular/PrimarySwitch.sh "$PrimarySimSwitchBackTime" CWAN1 1 &         
												   fi
												   fi
												   if [ "$InterfaceName" = "CWAN1_1" ]
												   then
												   		logger -t $Source -p customs.info "Switching to sim1"
														/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
												   fi
												fi
											fi
								fi
						else
								if [ "x$EnmDataPort" = "x" ]
								then
								date=$(date)
								echo "$date Comp port is available and No EnmData port" >> "$Logfile"
										echo "status=DataPort NE" >> "$PortDetailsFile"
										echo "status=Disabled" > "$AddIfaceStatusFile"
								else
								date=$(date)
								echo "$date Both Comp port and enData Ports are available" >> "$Logfile"
										echo "status=Enumerated" >> "$PortDetailsFile"
											if [ "$EnableCellular" = "1" ]
											then
											   for i in 1 2 3
											   do
											       simid=$(/bin/at-cmd "$EnmComPort" AT+QCCID | awk '/\+QCCID:/ {print $0}' | cut -d ":" -f 2)
												   	if [ "${#simid}" -gt 10 ] && [ -n "$simid" ] && [[ "$simid" != "-" ]] && [[ "$simid" != *"Entry not found"* ]] && [[ "$simid" != *"ERROR"* ]];
													then
													uci set system.system.qccid="$simid"
													uci set modemstatus.modemstatus.QCCID="$simid"
													uci commit modemstatus
													uci commit system
													   status="READY"
													   date=$(date)
													   echo "$date:sim qccid is $simid using comport $EnmComPort" >> "$Logfile"
													   	logger -t $Source -p customs.info "Qccid of $Simno is $simid"

													   break
													else
													    simid=$(/bin/at-cmd "$EnmDataPort" AT+QCCID | awk '/\+QCCID:/ {print $0}' | cut -d ":" -f 2)
														if [ "${#simid}" -gt 10 ] && [ -n "$simid" ] && [[ "$simid" != "-" ]] && [[ "$simid" != *"Entry not found"* ]] && [[ "$simid" != *"ERROR"* ]];
														then
															uci set system.system.qccid="$simid"
															uci set modemstatus.modemstatus.QCCID="$simid"
															uci commit modemstatus
															uci commit system
															status="READY"
															date=$(date)
															echo "$date:sim qccid is $simid using dataport $EnmDataPort" >> "$Logfile"
															logger -t $Source -p customs.info "Qccid of $Simno is $simid"
															break
														else
															uci set system.system.qccid="Qccid Not found"
															uci set modemstatus.modemstatus.QCCID="ERROR"
															uci commit modemstatus
															uci commit system
															date=$(date)
															echo "$date:sim qccid is not ready $simid" >> "$Logfile"     
															if [ $i = "3" ];then
																logger -t $Source -p customs.err "Qccid of $Simno is not found"   
															fi
													    fi
													fi
											   done
											   if [ "$status" = "READY" ]
											   then

												   if [ "$InterfaceName" = "CWAN1_0" ]
												   then
													uci set system.system.qccid="$simid"
													uci set modemstatus.modemstatus.QCCID="$simid"
													uci commit modemstatus
													uci commit system
   													pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")
													kill -TERM "$pid" > /dev/null 2>&1
													sleep 1
													kill -KILL "$pid" > /dev/null 2>&1
												   AddNetworkInterface
												   else
													uci set system.system.qccid="$simid"
													uci set modemstatus.modemstatus.QCCID="$simid"
													uci commit modemstatus
													uci commit system
												    AddNetworkInterface
												   fi
											   else
												   if [ "$InterfaceName" = "CWAN1_0" ]
												   then
												   		logger -t $Source -p customs.info "Switching to sim2"
												   /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
												   if [ "$PrimarySimSwitchBackEnable" = "1" ]
												   then
													pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")
													kill -TERM "$pid" > /dev/null 2>&1
													sleep 1
													kill -KILL "$pid" > /dev/null 2>&1
													 /root/InterfaceManager/script/cellular/PrimarySwitch.sh "$PrimarySimSwitchBackTime" CWAN1 1 &         
												   fi
												   fi
												   if [ "$InterfaceName" = "CWAN1_1" ]
												   then
												   		logger -t $Source -p customs.info "Switching to sim1"
														/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
												   fi
												fi
											fi
								fi
						fi
				fi
		fi
		
}

ModemReboot() {
InterfaceName=$1
EnmComPort=$2

	if [ "$InterfaceName" = "CWAN1" ] || [ "$InterfaceName" = "wan6c1" ]
	then
		echo "$date Rebooting CWAN1 ..." >> "$Logfile"
		/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh $EnmComPort
	elif [ "$InterfaceName" = "CWAN2" ]
	then
		echo "$date Rebooting CWAN2 ..." >> "$Logfile"
		/root/usrRPC/script/Recycle_WAN2_PWR_Script.sh $EnmComPort
	elif [ "$InterfaceName" = "CWAN1_0" ] || [ "$InterfaceName" = "wan6c1" ]
	then
		echo "$date Rebooting CWAN1_0 ..." >> "$Logfile"
		echo 1 > "$SimNumFile"
		/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh $EnmComPort
		
	elif [ "$InterfaceName" = "CWAN1_1" ] || [ "$InterfaceName" = "wan6c2" ]
	then
		echo "$date Rebooting CWAN1_1 ..." >> "$Logfile"
		echo "$date simswitch script invoked" >> "$Logfile"
		#If the modem works on sim2, then sim2 should be up, not sim1.
		logger -t $Source -p customs.info "Switching to sim2"
		/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
		if [ "$PrimarySimSwitchBackEnable" = "1" ]
		then
			pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")
			kill -TERM "$pid" > /dev/null 2>&1
			sleep 1
			kill -KILL "$pid" > /dev/null 2>&1
		   echo "$date PrimarySwitch script invoked" >> "$Logfile"
			/root/InterfaceManager/script/cellular/PrimarySwitch.sh "$PrimarySimSwitchBackTime" CWAN1 1 &         
		fi
		break
	fi
echo "AddIfaceRunningstatus=0" > /tmp/AddIfaceRunningstatus
 exit 0
}


SetATCommandsQMI()
{
  	date=$(date)    
	echo "============$date $InterfaceName -- $EnmComPort ============" >> "$Logfile"
	#To check sim status. It should come ready. It should come within 20 sec
	for i in 1 2 3                                                                                                                  
	do 
		Status=$(/bin/at-cmd "$EnmComPort" AT+CPIN? | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		#Values are set in /etc/config/modemstatus for snmp agent
		uci set modemstatus.modemstatus=interface
		uci set modemstatus.modemstatus.PinState=$Status
		uci commit modemstatus
		if [ $Status = "READY" ]
		then
			echo "$date:AT+CPIN=$Status,CPIN is Ready" >> "$Logfile"
			break
		else
			sleep 3
		fi
	done
	
	if [ "$Status" != "READY" ]
	then
		echo "$date:[AT+CPIN=$Status]CPIN is not Ready so Simswitch script is invoked" >> "$Logfile"
	
		#switch sim depending on the  name.
		if [ "$dualsimsinglemodule" = "dualsimsinglemodule" ] && ([ "$InterfaceName" = "CWAN1_0" ] || [ "$InterfaceName" = "wan6c1" ])
		then
			 logger -t $Source -p customs.info "Switching to sim2"
			 /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
		elif [ "$dualsimsinglemodule" = "singlesimsinglemodule" ]
		then
			echo "$date:[AT+CPIN=$Status]CPIN is not Ready so modem is rebooted" >> "$Logfile"
			ModemReboot $InterfaceName $EnmComPort
			CheckAddIfaceRunningstatus
		fi
		
	fi
	
	#To check if it is registered in circuit switched network. should happen within 90 sec.
	#output should be 0,1.
	for i in 1 2 3                                                                                                                  
	do 
		Status=$(/bin/at-cmd "$EnmComPort" AT+CREG? | awk NR==2 | cut -d ":" -f 2 | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')

		if [ $Status = "1" ] || [ $Status = "5" ]
		then
			echo "$date:[AT+CREG?=$Status]Sim is Successfully Registered" >> "$Logfile"
			break
		else
			sleep 3
		fi
	done
	
	if [ "$Status" != "1" ]
	then
		echo "$date:[AT+CREG?=$Status]Sim is not Successfully Registered" >> "$Logfile"
	fi

	#To check Registration status.
	#output should be 0,1.
	for i in 1 2 3                                                                                                                  
	do 
		Status=$(/bin/at-cmd "$EnmComPort" AT+CGREG? | awk NR==2 | cut -d ":" -f 2 | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')
		if [ $Status = "1" ] || [ $Status = "5" ]
		then
			echo "$date:[AT+CGREG?=$Status]" >> "$Logfile"
			break
		else
			sleep 3
		fi
	done
	
	if [ "$Status" != "1" ]
	then
		echo "$date:[AT+CGREG?=$Status]" >> "$Logfile"
	fi
	  	  	
    #Check and Set APN
	for i in 1 2                                                                                         
	do   
	    #check for pdp and apn set in modem ,
	    Status=$(/bin/at-cmd $EnmComPort at+cgdcont? | awk NR==2 | awk '{print $2}')
	    pdp_stat=$(echo $Status | awk -F',' '{print $2}' | awk -F'"' '{print $2}' | tr -d '\011\012\013\014\015\040') 
	    apn_stat=$(echo $Status | awk -F',' '{print $3}' | awk -F'"' '{print $2}' |  tr -d '\011\012\013\014\015\040')
	    echo "$date:Default PDP set in modem is  $pdp_stat,PDP to be set is $PDP_QMI" >> "$Logfile"
		echo "$date:Default APN set in modem is  $apn_stat,APN to be set is $APN" >> "$Logfile"
	    
	    	#If the pdp, APN & authentication are different, only then, set them using QICSGP command.
		if [ "$pdp_stat" != "$PDP_QMI" ] || [ "$apn_stat" != "$APN" ] 
		then                                                                                                                   
			Status=$(/bin/at-cmd $EnmComPort AT+CGDCONT=1,\"$PDP_QMI\",\"$APN\","","","" | awk NR==2 | tr -d '\011\012\013\014\015\040') 
			pdp_stat=$(echo $Status | awk -F',' '{print $2}' | awk -F'"' '{print $2}' | tr -d '\011\012\013\014\015\040')                          
				if [ "$Status" = "OK" ]                                                                                 
				then                                       
					echo "$date:APN ,PDP,Auth was different, hence modem is rebooted" >> "$Logfile"
					ModemReboot $InterfaceName $EnmComPort
					CheckAddIfaceRunningstatus
					break                                                                                                               
				fi 
		fi                                                                                                                          
	done 

    
    #check if PDPN is activated/not.
			for i in 1 2 3                                                                                                                    
			do  				
				#For ipv4 -
				if [ "$PDPN" = "1" ]
				then  								
					Setqiact=$(/bin/at-cmd "$EnmComPort" AT+QIACT=1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
					Status=$(/bin/at-cmd "$EnmComPort" AT+QIACT? | awk NR==2 | tr -d '\011\012\013\014\015\040')
					echo "$date AT+QIACT?=$Status" >> "$Logfile"
					ipaddr=$(echo $Status | cut -d "," -f 4 | tr -d -c '.' | wc -c | tr -d '\011\012\013\014\015\040')
					echo "$date AT+QIACT? ipv4=$ipaddr" >> "$Logfile"
					#ipv4 has 3 dots (.)                         
					if [ "$ipaddr" = "3" ]                                                                                                        
					then
						break
					else
						echo "IPV4 address obtained is invalid"
					fi
				
				#For ipv6 -
				elif [ "$PDPN" = "2" ]
				then								 
					Setqiact=$(/bin/at-cmd "$EnmComPort" AT+QIACT=1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
					Status=$(/bin/at-cmd "$EnmComPort" AT+QIACT? | awk NR==2 | tr -d '\011\012\013\014\015\040')
					echo "$date AT+QIACT?=$Status" >> "$Logfile"
					ipaddr=$(echo $Status | cut -d "," -f 4 | cut -d ":" -f 1 | awk -F'"' '{print $2}' | tr -d '\011\012\013\014\015\040')					
					echo "$date AT+QIACT? ipv6=$ipaddr" >> "$Logfile"					
					#ipv6 starting addr should be greater then 2000                         
					if [ "$ipaddr" -gt "2000" ]                                                                                                        
					then
						break
					else
					   echo "IPV6 address obtained is invalid"
					fi
				
				#For ipv4v6 -
				elif [ "$PDPN" = "3" ]
				then
					Status=$(at-cmd "$EnmComPort" at+cgpaddr=1)
					echo "$date AT+cgpaddr?=$Status" >> "$Logfile"
					ipv4addr=$(echo $Status | cut -d "," -f 2 | awk -F'"' '{print $2}'  | tr -d '\011\012\013\014\015\040')
					ipaddr1=$(echo $Status | cut -d "," -f 2 | tr -d -c '.' | wc -c | tr -d '\011\012\013\014\015\040')
					ipaddr2=$(echo $Status | cut -d "," -f 3 |tr -d '\011\012\013\014\015\040')
					echo "$date AT+cgpaddr? ipv4=$ipv4addr; ipv6=$ipaddr2" >> "$Logfile"
					if [ "$ipaddr1" = "3" ]
                    then 
                        break
                    else
					   echo "IPV6 address obtained is invalid"
					fi
				fi                                                      
																				
			done   
}

SetATCommandsRM500U() {
	date=$(date)    
	echo "============$date $InterfaceName -- $EnmComPort ============" >> "$Logfile"
	#To check sim status. It should come ready. It should come within 20 sec
	AltComPortSymLink=$(find /dev -maxdepth 1 -name  "$InterfaceName""_"* | sort | sed -n $ConfiguredAltComPort"p")
	
	AltComPortSymLink=$(readlink -f "$AltComPortSymLink")
	
	for i in 1 2 3                                                                                                                  
	do 
		Status=$(/bin/at-cmd "$EnmComPort" AT+CPIN? | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		#Values are set in /etc/config/modemstatus for snmp agent
		uci set modemstatus.modemstatus=interface
		uci set modemstatus.modemstatus.PinState=$Status
		uci commit modemstatus
		if [ $Status = "READY" ]
		then
			date=$(date)
			echo "$date:AT+CPIN=$Status,CPIN is Ready" >> "$Logfile"
			break
		else
			sleep 3
		fi
	done
	
	if [ "$Status" != "READY" ]
	then
		date=$(date)
		echo "$date:[AT+CPIN=$Status]CPIN is not Ready so Simswitch script is invoked" >> "$Logfile"
	
		#switch sim depending on the  name.
		if [ "$dualsimsinglemodule" = "dualsimsinglemodule" ] && ([ "$InterfaceName" = "CWAN1_0" ] || [ "$InterfaceName" = "wan6c1" ])
		then
			logger -t $Source -p customs.info "Switching to sim2"
			 /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
		elif [ "$dualsimsinglemodule" = "singlesimsinglemodule" ]
		then
			date=$(date)
			echo "$date:[AT+CPIN=$Status]CPIN is not Ready so modem is rebooted" >> "$Logfile"
			ModemReboot $InterfaceName $EnmComPort
			CheckAddIfaceRunningstatus
		fi

	fi
	
	
	#Check for the set pdp, APN & authentication. 
	for i in 1 2                                                                                                                 
	do
		Status=$(/bin/at-cmd $EnmComPort AT+QICSGP=1 | awk NR==2 | awk '{print $2}' | tr -d '\011\012\013\014\015\040')
		pdp_stat=$(echo $Status | awk -F',' '{print $1}' | tr -d '\011\012\013\014\015\040')                           
		apn_stat=$(echo $Status | awk -F',' '{print $2}' | awk -F'"' '{print $2}' | tr -d '\011\012\013\014\015\040')                           
		auth_stat=$(echo $Status | awk -F',' '{print $5}' | tr -d '\011\012\013\014\015\040') 
		if [ ! -n "$Status" ]                                                                                                        
		then                                                                                                                           
			sleep 1                                                                                                                     
		else                                                                                                                           
			break                                                                                                                    
		fi                                                                                                                             
	done 
	date=$(date)
	echo "$date:[AT+QICSGP=1 and status=$Status]" >> "$Logfile"
	echo "$date:Default PDP set in modem is  $pdp_stat, PDP to set is $PDPN" >> "$Logfile"
	echo "$date:Default APN set in modem is  $apn_stat,APN to set is $APN" >> "$Logfile"
	echo "$date:Default Auth set in modem is  $auth_stat,Auth to set is $auth" >> "$Logfile"
	
	#If status is empty.
	if [ ! -n "$Status" ]
	then
	date=$(date)
		echo "$date:AT+QICSGP=1 status not OK when apn,pdp,auth is same $Status" >> "$Logfile"  
	#If the pdp, APN & authentication are different, only then, set them using QICSGP command.
	elif [ "$pdp_stat" != "$PDPN" ] || [ "$apn_stat" != "$APN" ] || [ "$auth_stat" != "$auth" ]
	then
	date=$(date)
		echo "$date : pdp, APN & authentication are different." >> "$Logfile"
		echo "$date : APN,PDP,Auth to be set is $PDPN=$PDPN,$apn_stat=$APN,$auth_stat=$auth" >> "$Logfile"
		#Set APN
		for i in 1 2                                                                                         
		do                                                                                                                         
		Status=$(/bin/at-cmd $EnmComPort AT+QICSGP=1,"$PDPN",\"$APN\",\"$username\",\"$password\","$auth" | awk NR==2 | tr -d '\011\012\013\014\015\040')                           
			if [ "$Status" = "OK" ]                                                                                 
			then
			date=$(date)
				echo "$date:APN ,PDP,Auth is set Successfully so Deactivate the pdp context." >> "$Logfile"
				#Deactivate the pdp context.
				/bin/at-cmd $EnmComPort AT+QIDEACT=1
				
				sleep 3
				date=$(date)
				echo "$date:Modem will be Rebooted after successfully setting APN,PDP,Auth" >> /tmp/ATCommandStatus
				#Reboot/switch sim depending on the interface name.
				ModemReboot $InterfaceName $EnmComPort
				CheckAddIfaceRunningstatus
				break                                                                                                               
			fi                                                                                                                           
		done 
		
		if [ "$Status" != "OK" ]
		then
		date=$(date)
			echo "$date:AT+QICSGP At command Status is $Status, status not OK when apn,pdp is not set Successfully" >> /tmp/ATCommandStatus
				#Deactivate the pdp context.
				/bin/at-cmd $EnmComPort AT+QIDEACT=1
				
				sleep 3
				date=$(date)
				echo "$date:Modem will be Rebooted as status not OK when apn,pdp is set" >> /tmp/ATCommandStatus
				#Reboot/switch sim depending on the interface name.
				ModemReboot $InterfaceName $EnmComPort
				CheckAddIfaceRunningstatus
		fi
	
	#If the pdp, APN & authentication are same.
	else
		#Activate pdp context 1. Get response -- either OK/Error.
		for i in 1 2 3                                                                                                                    
		do
			Status=$(/bin/at-cmd $EnmComPort AT+QIACT=1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
									 
			if [ "$Status" = "OK" ]                                                                                                        
			then
			date=$(date)
				echo "$date: PDP Context is succcessfully set" >> "$Logfile"
				break                                                                                                                     
			else                                                                                                                           
				sleep 3                                                                                                                    
			fi                                                                                                                             
		done 
		
		##If the response of AT+QIACT=1 is error or if it has no response.
		if [ "$Status" != "OK" ]
		then
		date=$(date)
			echo "$date AT+QIACT=1 status not OK="$Status >> "$Logfile"
			echo "$date AT+QIDEACT=1 Deactivate the pdp context." >> "$Logfile"			
			#Deactivate and then reboot
			/bin/at-cmd $EnmComPort AT+QIDEACT=1			
			sleep 1
		fi
		#If the response of AT+QIACT=1 is OK

			#check if PDPN is activated/not.
			for i in 1 2 3                                                                                                                    
			do  
				#Status=$(/bin/at-cmd $EnmComPort AT+QIACT=1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
				Status=$(/bin/at-cmd $EnmComPort AT+QIACT? | awk NR==2 | tr -d '\011\012\013\014\015\040')
				date=$(date)
				echo "$date AT+QIACT?=$Status" >> "$Logfile"
				
				#For ipv4 -
				if [ "$PDPN" = "1" ]
				then
					ipaddr=$(echo $Status | cut -d "," -f 4 | tr -d -c '.' | wc -c | tr -d '\011\012\013\014\015\040')
					date=$(date)
					echo "$date AT+QIACT? ipv4=$ipaddr" >> "$Logfile"
					
					#ipv4 has 3 dots (.)                         
					if [ "$ipaddr" = "3" ]                                                                                                        
					then
						break
					else
					   echo "Invalid IP address obtained" >> "$Logfile"
					   #ModemReboot $InterfaceName $EnmComPort
					fi
				
				#For ipv6 -
				elif [ "$PDPN" = "2" ]
				then
					ipaddr=$(echo $Status | cut -d "," -f 4 | cut -d ":" -f 1 | awk -F'"' '{print $2}' | tr -d '\011\012\013\014\015\040')
					date=$(date)
					echo "$date AT+QIACT? ipv6=$ipaddr" >> "$Logfile"
					
					#ipv6 starting addr should be greater then 2000                         
					if [ "$ipaddr" -gt "2000" ]                                                                                                        
					then
						break
					else
					   echo "Invalid IP address obtained" >> "$Logfile"
					   #ModemReboot $InterfaceName $EnmComPort
					fi
				
				#For ipv4v6 -
				elif [ "$PDPN" = "3" ]
				then
					ipaddr1=$(echo $Status | cut -d "," -f 4 | tr -d -c '.' | wc -c | tr -d '\011\012\013\014\015\040')
					ipaddr2=$(echo $Status | cut -d "," -f 5 | cut -d ":" -f 1 | tr -d '\011\012\013\014\015\040')
					date=$(date)
					echo "$date AT+QIACT? ipv4V6=$ipaddr1; $ipaddr2" >> "$Logfile"
					
					#ipv6 starting addr should be greater then 2000 & ipv4 has 3 dots (.)                        
					if [ "$ipaddr2" -gt "2000" ] && [ "$ipaddr1" = "3" ]                                                                                                     
					then
						break
					else
					   echo "Invalid IP address obtained" >> "$Logfile"
					   #ModemReboot $InterfaceName $EnmComPort
					fi				
				##For wrong pdp
				else
					 echo "Invalid IP address obtained"
				fi                                                      
																				
			done
		  
	fi
	
	exec 200>"$EnmComPort"
	flock -n 200
	
	Status_ok=$(/bin/at-cmd "$EnmComPort" AT+QNETDEVCTL=1,1,1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
	
	#If response is ok; then break.
	if [ "$Status_ok" = "OK" ]
	then
	date=$(date)
		echo "$date: AT+QNETDEVCTL=$Status_ok" >> "$Logfile"
		break 
	#If no response, then try again 3 times
	else
		sleep 2
		date=$(date)
		echo "$date: AT+QNETDEVCTL=$Status_ok" >> "$Logfile"
		
		for i in 1 2 3                                                                                                                   
		do
			Status=$(/bin/at-cmd "$EnmComPort" AT+QNETDEVCTL=1,1,1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
			
			if [ "$Status" = "OK" ]
			then
			date=$(date)
				echo "$date: AT+QNETDEVCTL=$Status" >> "$Logfile"
				
				#Set got_ok as 1, if received ok as response. So as not to switch to alt comport port.
				got_ok=1
				break 
			else
				sleep 2
				date=$(date)
				echo "$date: AT+QNETDEVCTL=$Status" >> "$Logfile"
			fi
		done
		
		if [ "$got_ok" = "1" ]
		then
			break
		
		#If no response on comport, then switch to alt comport.
		else
		date=$(date)
			echo "$date: No response on AT+QNETDEVCTL; switching to alternate comport" >> "$Logfile"
			
			for i in 1 2 3                                                                                                                   
			do
				Status_alt=$(/bin/at-cmd "$AltComPortSymLink" AT+QNETDEVCTL=1,1,1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
				
				if [ "$Status_alt" = "OK" ]
				then
				date=$(date)
					echo "$date: AT+QNETDEVCTL=$Status_alt for AltComPort" >> "$Logfile"
					break 
				else
					sleep 2
					date=$(date)
					echo "$date: AT+QNETDEVCTL=$Status_alt for AltComPort" >> "$Logfile"
				fi
			done
		fi
	fi
	flock -u 200

}



SetATCommands() {
	date=$(date)    
	echo "============$date $InterfaceName -- $EnmComPort ============" >> "$Logfile"
	#To check sim status. It should come ready. It should come within 20 sec
	for i in 1 2 3                                                                                                                  
	do 
		Status=$(/bin/at-cmd "$EnmComPort" AT+CPIN? | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		#Values are set in /etc/config/modemstatus for snmp agent
		uci set modemstatus.modemstatus=interface
		uci set modemstatus.modemstatus.PinState=$Status
		uci commit modemstatus
		if [ $Status = "READY" ]
		then
			echo "$date:AT+CPIN=$Status,CPIN is Ready" >> "$Logfile"
			logger -t $Source -p customs.info "$Simno is inserted properly"
			break
		else
			sleep 3
		fi
	done
	
	if [ "$Status" != "READY" ]
	then
		echo "$date:[AT+CPIN=$Status]CPIN is not Ready so Simswitch script is invoked" >> "$Logfile"
		logger -t $Source -p customs.err "$Simno is not inserted properly"
		#switch sim depending on the  name.
		if [ "$dualsimsinglemodule" = "dualsimsinglemodule" ] && ([ "$InterfaceName" = "CWAN1_0" ] || [ "$InterfaceName" = "wan6c1" ])
		then
			logger -t $Source -p customs.info "Switching to sim2"
			 /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
		elif [ "$dualsimsinglemodule" = "singlesimsinglemodule" ]
		then
			echo "$date:[AT+CPIN=$Status]CPIN is not Ready so modem is rebooted" >> "$Logfile"
			ModemReboot $InterfaceName $EnmComPort
			CheckAddIfaceRunningstatus
		fi
		
	fi
	
	
	#To check if it is registered in circuit switched network. should happen within 90 sec.
	#output should be 0,1.
	for i in 1 2 3                                                                                                                  
	do 
		Status=$(/bin/at-cmd "$EnmComPort" AT+CREG? | awk NR==2 | cut -d ":" -f 2 | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')

		if [ $Status = "1" ]
		then
			echo "$date:[AT+CREG?=$Status]Sim is Successfully Registered" >> "$Logfile"
			logger -t $Source -p customs.info "$Simno is Successfully Registered"
			break
		else
			sleep 3
		fi
	done
	
	if [ "$Status" != "1" ]
	then
		echo "$date:[AT+CREG?=$Status]Sim is not Successfully Registered" >> "$Logfile"
		logger -t $Source -p customs.info "$Simno is not Successfully Registered"
	fi
	
	#To check Registration status.
	#output should be 0,1.
	for i in 1 2 3                                                                                                                  
	do 
		Status=$(/bin/at-cmd "$EnmComPort" AT+CGREG? | awk NR==2 | cut -d ":" -f 2 | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')

		if [ $Status = "1" ]
		then
			echo "$date:[AT+CGREG?=$Status]" >> "$Logfile"
			break
		else
			sleep 3
		fi
	done
	
	if [ "$Status" != "1" ]
	then
		echo "$date:[AT+CGREG?=$Status]" >> "$Logfile"
	fi
	
	
	#Check for the set pdp, APN & authentication. 
	for i in 1 2                                                                                                                 
	do
		Status=$(/bin/at-cmd $EnmComPort AT+QICSGP=1 | awk NR==2 | awk '{print $2}' | tr -d '\011\012\013\014\015\040')
		pdp_stat=$(echo $Status | awk -F',' '{print $1}' | tr -d '\011\012\013\014\015\040')                           
		apn_stat=$(echo $Status | awk -F',' '{print $2}' | awk -F'"' '{print $2}' | tr -d '\011\012\013\014\015\040')                           
		auth_stat=$(echo $Status | awk -F',' '{print $5}' | tr -d '\011\012\013\014\015\040') 
		if [ ! -n "$Status" ]                                                                                                        
		then                                                                                                                           
			sleep 1                                                                                                                     
		else                                                                                                                           
			break                                                                                                                    
		fi                                                                                                                             
	done 
	
	echo "$date:[AT+QICSGP=1 and status=$Status]" >> "$Logfile"
	echo "$date:Default PDP set in modem is  $pdp_stat, PDP to set is $PDPN" >> "$Logfile"
	echo "$date:Default APN set in modem is  $apn_stat,APN to set is $APN" >> "$Logfile"
	echo "$date:Default Auth set in modem is  $auth_stat,Auth to set is $auth" >> "$Logfile"
	
	#If status is empty.
	if [ ! -n "$Status" ]
	then
		echo "$date:AT+QICSGP=1 status not OK when apn,pdp,auth is same $Status" >> "$Logfile"  
	#If the pdp, APN & authentication are different, only then, set them using QICSGP command.
	elif [ "$pdp_stat" != "$PDPN" ] || [ "$apn_stat" != "$APN" ] || [ "$auth_stat" != "$auth" ]
	then
		echo "$date : pdp, APN & authentication are different." >> "$Logfile"
		echo "$date : APN,PDP,Auth to be set is $PDPN=$PDPN,$apn_stat=$APN,$auth_stat=$auth" >> "$Logfile"
		#Set APN
		for i in 1 2                                                                                         
		do                                                                                                                         
		Status=$(/bin/at-cmd $EnmComPort AT+QICSGP=1,"$PDPN",\"$APN\",\"$username\",\"$password\","$auth" | awk NR==2 | tr -d '\011\012\013\014\015\040')                           
			if [ "$Status" = "OK" ]                                                                                 
			then
				echo "$date:APN ,PDP,Auth is set Successfully so Deactivate the pdp context." >> "$Logfile"
				logger -t $Source -p customs.info "APN=$APN,PDP=$PDPN,Authentication=$auth is set successfully for $Simno"
				#Deactivate the pdp context.
				/bin/at-cmd $EnmComPort AT+QIDEACT=1
				
				sleep 3
				echo "$date:Modem will be Rebooted, after successfully setting APN,PDP,Auth" >> /tmp/ATCommandStatus
				logger -t $Source -p customs.info "Modem will be Rebooted,after successfully setting APN,PDP,Auth for $Simno"
				#Reboot/switch sim depending on the interface name.
				ModemReboot $InterfaceName $EnmComPort
				CheckAddIfaceRunningstatus
				break                                                                                                               
			fi                                                                                                                           
		done 
		
		if [ "$Status" != "OK" ]
		then
			echo "$date:AT+QICSGP At command Status is $Status, status not OK when apn,pdp is not set Successfully" >> /tmp/ATCommandStatus
				#Deactivate the pdp context.
				/bin/at-cmd $EnmComPort AT+QIDEACT=1
				
				sleep 3
				echo "$date:Modem will be Rebooted as status not OK when apn,pdp is set" >> /tmp/ATCommandStatus
				logger -t $Source -p customs.err "Modem will be Rebooted as setting of APN,PDP,Auth for $Simno has failed"
				#Reboot/switch sim depending on the interface name.
				ModemReboot $InterfaceName $EnmComPort
				CheckAddIfaceRunningstatus
		fi
	
	#If the pdp, APN & authentication are same.
	else
		logger -t $Source -p customs.info "Since APN,PDP,Auth config set in modem is same as configurations in modem.so skipping of setting APN,PDP,Auth."
		#Activate pdp context 1. Get response -- either OK/Error.
		for i in 1 2 3                                                                                                                    
		do
			Status=$(/bin/at-cmd $EnmComPort AT+QIACT=1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
									 
			if [ "$Status" = "OK" ]                                                                                                        
			then
				echo "$date: PDP Context is succcessfully set" >> "$Logfile"
				logger -t $Source -p customs.info "Establishing data connection for $Simno is successful"
				break                                                                                                                     
			else                                                                                                                           
				sleep 3                                                                                                                    
			fi                                                                                                                             
		done 
		
		##If the response of AT+QIACT=1 is error or if it has no response.
		if [ "$Status" != "OK" ]
		then
			echo "$date AT+QIACT=1 status not OK="$Status >> "$Logfile"
			echo "$date AT+QIDEACT=1 Deactivate the pdp context." >> "$Logfile"			
			#Deactivate and then reboot
			/bin/at-cmd $EnmComPort AT+QIDEACT=1			
			sleep 1
		fi
		#If the response of AT+QIACT=1 is OK

			#check if PDPN is activated/not.
			for i in 1 2 3                                                                                                                    
			do  
				Status=$(/bin/at-cmd $EnmComPort AT+QIACT=1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
				Status=$(/bin/at-cmd $EnmComPort AT+QIACT? | awk NR==2 | tr -d '\011\012\013\014\015\040')
				echo "$date AT+QIACT?=$Status" >> "$Logfile"
				

				#For ipv4 -
				if [ "$PDPN" = "1" ]
				then
					ipaddr=$(echo $Status | cut -d "," -f 4 | tr -d -c '.' | wc -c | tr -d '\011\012\013\014\015\040')
					echo "$date AT+QIACT? ipv4=$ipaddr" >> "$Logfile"
					ipv4addr=$(echo $Status | cut -d "," -f 4)
					logger -t $Source -p customs.info "IPv4 address obtained for $Simno-$ipv4addr"
					#ipv4 has 3 dots (.)                         
					if [ "$ipaddr" = "3" ]                                                                                                        
					then
						break
					else
					   echo "Invalid IP address obtained"
					fi
				
				#For ipv6 -
				elif [ "$PDPN" = "2" ]
				then
					ipaddr=$(echo $Status | cut -d "," -f 4 | cut -d ":" -f 1 | awk -F'"' '{print $2}' | tr -d '\011\012\013\014\015\040')
					echo "$date AT+QIACT? ipv6=$ipaddr" >> "$Logfile"
					ipv6addr=$(echo $Status | cut -d "," -f 4)
					logger -t $Source -p customs.info "IPv6 address obtained for $Simno-$ipv6addr"
					#ipv6 starting addr should be greater then 2000                         
					if [ "$ipaddr" -gt "2000" ]                                                                                                        
					then
						break
					else
					   echo "Invalid IP address obtained"
					fi
				
				#For ipv4v6 -
				elif [ "$PDPN" = "3" ]
				then
					ipaddr1=$(echo $Status | cut -d "," -f 4 | tr -d -c '.' | wc -c | tr -d '\011\012\013\014\015\040')
					ipaddr2=$(echo $Status | cut -d "," -f 5 | cut -d ":" -f 1 | awk -F'"' '{print $2}' | tr -d '\011\012\013\014\015\040')
					echo "$date AT+QIACT? ipv4v6=$ipaddr1; $ipaddr2" >> "$Logfile"
						ipv4addr=$(echo $Status | cut -d "," -f 4)
						ipv6addr=$(echo $Status | cut -d "," -f 5)
					logger -t $Source -p customs.info "IPv4v6 address obtained for $Simno ipv4addr-$ipv4addr,ipv6addr-$ipv6addr"
					#ipv6 starting addr should be greater then 2000 & ipv4 has 3 dots (.)                        
					if [ "$ipaddr2" -gt "2000" ] && [ "$ipaddr1" = "3" ]                                                                                                     
					then
						break
					else
					   echo "Invalid IP address obtained"
					fi				
				##For wrong pdp
				else
					 echo "Invalid IP address obtained"
				fi                                                      
																				
			done
		  
	fi
	
	
	/bin/at-cmd "$EnmComPort" AT+QNETDEVCTL=1,1,1                                                                                 
	
	sleep 1                                                                                                                        
	
	for i in 1 2 3                                                                                                                   
	do                                                                                                                              
		Status=$(/bin/at-cmd "$EnmComPort" AT+QNETDEVCTL? | awk NR==2 | cut -d "," -f 4 | tr -d '\011\012\013\014\015\040')   
		if [ "$Status" = "1" ]                                                                                                         
		then 
			echo "$date:AT+QNETDEVCTL=$Status" >> "$Logfile"
			break                                                                                                                     
		else                                                                                                                           
			sleep 2  
			echo "$date:AT+QNETDEVCTL=$Status" >> "$Logfile"                                                                                                                  
			/bin/at-cmd "$EnmComPort"  AT+QNETDEVCTL=1,1,1                                                                             
		fi                                                                                                                             
	done
}


#
# Update network configuration file
# 
AddNetworkInterface()
{
		date=$(date)
		echo "============$date Start of AddNetworkInterface ============" >> "$Logfile"
		/etc/init.d/sms3 stop &
		
		response=$($Updatebandlock $EnmComPort)
		m2mesim=$(uci get sysconfig.sysconfig.Sim1type)
		
		response=$($Updateoperatorlock $EnmDataPort)
		response=$($Findapn  $InterfaceName)  /dev/null 2>&1
		if [ $m2mesim = "m2mesim" ]
		then 
			response=$($UpdateEsim_ATCommands $EnmComPort)
		fi
		if [ $InterfaceName = "CWAN1_0" ] || [ $InterfaceName = "CWAN1" ] 
		then
		    if [ $Sim1apntype = "auto" ] 
		    then
		       APN=$(uci get sysconfig.sysconfig.sim1autoapn)
		    fi
		elif [ $InterfaceName = "CWAN1_1" ] 
		then
		    if [ $Sim2apntype = "auto" ] 
		    then
		       APN=$(uci get sysconfig.sysconfig.sim2autoapn)
		    fi
		fi
		uci delete network.wan6c1_xlat
		uci delete network.wan6c2_xlat
		
		date=$(date)
		echo "============$date After BandLock ============" >> "$Logfile"
		
		if [ "x$DataEnable" != "x" ] && [ "$DataEnable" -eq "1" ]
		then

			Enablexlatsim1=$(uci get sysconfig.sysconfig.Enable464xlatSim1)
			Enablexlatsim2=$(uci get sysconfig.sysconfig.Enable464xlatSim2)
			if ([ "$Enablexlatsim1" = "1" ] && [ "$PDP" = "IPV6" ]) || ([ "$Enablexlatsim2" = "1" ] && [ "$PDP" = "IPV6" ]) 
			then
				
				uci set network.${IPV6InterfaceName}_xlat=interface
				uci set network.${IPV6InterfaceName}_xlat.proto='464xlat'
				uci set network.${IPV6InterfaceName}_xlat.tunlink=$IPV6InterfaceName
				uci set network.${IPV6InterfaceName}_xlat.ip6prefix='64:ff9b::/96'
			fi
			if [ "$Protocol" = "ppp" ]
			then
				uci set network."$InterfaceName"=interface
				uci set network."$InterfaceName".ifname="3g-${InterfaceName}"                                                                       
				uci set network."$InterfaceName".proto="$Proto"                                                                         
				uci set network."$InterfaceName".service="$Service"                                                                     
				uci set network."$InterfaceName".device="$EnmDataPort"                                                                
				uci set network."$InterfaceName".comport="$EnmComPort"                                                                
				uci set network."$InterfaceName".apn="$APN"
						if [ "$policy_type" = "failover" ]
						then
							uci set network."$InterfaceName".metric="$Metric"  
						else
							uci set network."$InterfaceName".metric="1"
						fi         
				uci set network."$InterfaceName".username="$Username"             
				uci set network."$InterfaceName".password="$Password"
				uci set network."$InterfaceName".mtu="$mtu"
			 elif [ "$Protocol" = "cdcether" ]
			 then
				if [ "$PDP" = "IPV4" ]              
				then
					metric=$(uci get mwan3config.$InterfaceName.wanpriority)
					uci set network."$InterfaceName"=interface
					uci set network."$InterfaceName".ifname="usb0"
					uci set network."$InterfaceName".proto="dhcp"	
					uci set network."$InterfaceName".mtu="$mtu"	
						if [ "$policy_type" = "failover" ]
						then
							if [ -z "$metric" ];then
								uci set network."$InterfaceName".metric=2 
							else 
								uci set network."$InterfaceName".metric="$metric"  
							fi
						else
							uci set network."$InterfaceName".metric="1"
						fi
				elif [ "$PDP" = "IPV6" ]
				then 
					metric=$(uci get mwan3config.$IPV6InterfaceName.wanpriority)
					uci set network."$IPV6InterfaceName"=interface
					uci set network."$IPV6InterfaceName".ifname="usb0"
					uci set network."$IPV6InterfaceName".proto="dhcpv6"
						if [ "$policy_type" = "failover" ]
						then
							if [ -z "$metric" ];then
								uci set network."$IPV6InterfaceName".metric=2  
							else 
								uci set network."$IPV6InterfaceName".metric="$metric"  
							fi
						else
							uci set network."$IPV6InterfaceName".metric="1"
						fi
					uci set network."$IPV6InterfaceName".reqaddress="try" 
					uci set network."$IPV6InterfaceName".reqprefix="auto"
					uci set network."$IPV6InterfaceName".mtu="$mtu"


				elif [ "$PDP" = "IPV4V6" ] 
				then 
					metric=$(uci get mwan3config.$InterfaceName.wanpriority)
					uci set network."$InterfaceName".metric="$metric" 
					uci set network."$InterfaceName"=interface
					uci set network."$InterfaceName".ifname="usb0"
					uci set network."$InterfaceName".proto="dhcp"
					if [ "$policy_type" = "failover" ]
						then
							if [ -z "$metric" ];then
								uci set network."$InterfaceName".metric=2 
							else 
								uci set network."$InterfaceName".metric="$metric"  
							fi
						else
							uci set network."$InterfaceName".metric="1"
						fi
					
					uci set network."$IPV6InterfaceName"=interface
					uci set network."$IPV6InterfaceName".ifname="usb0"
					uci set network."$IPV6InterfaceName".proto="dhcpv6"
					uci set network."$IPV6InterfaceName".reqaddress="try" 
					uci set network."$IPV6InterfaceName".reqprefix="auto"
					uci set network."$IPV6InterfaceName".mtu="$mtu"
				fi                                                                                                 
			 else  
			    if [ "$auth" = "1" ]
			    then 
			         authentication=PAP
			    elif [ "$auth" = "2" ]
			    then
			         authentication=CHAP
			    fi
				if [ "$PDP" = "IPV4" ] 
				then                                                                                    
					uci set network."$InterfaceName"=interface
					uci set network."$InterfaceName".ifname="wwan0"
					uci set network."$InterfaceName".proto="qmi"
					uci set network."$InterfaceName".device="/dev/cdc-wdm0"                                                                
					uci set network."$InterfaceName".apn="$APN"
					uci set network."$InterfaceName".pdptype="ipv4"
                    uci set network."$InterfaceName".mtu="$mtu"  
                    metric=$(uci get mwan3config.$InterfaceName.wanpriority)                                                              
						if [ "$policy_type" = "failover" ]
						then
							if [ -z "$metric" ];then
								uci set network."$InterfaceName".metric=2 
							else 
								uci set network."$InterfaceName".metric="$metric"
							fi						
						else
							uci set network."$InterfaceName".metric="1"
						fi
					if [ "$auth" = "1" ] ||  [ "$auth" = "2" ]
					then
						uci set network."$InterfaceName".auth="$authentication"
					    uci set network."$InterfaceName".username="$username"
					    uci set network."$InterfaceName".password="$password"
					fi
				elif [ "$PDP" = "IPV6" ] 
				then 
					uci set network."$IPV6InterfaceName"=interface
					uci set network."$IPV6InterfaceName".ifname="wwan0"
					uci set network."$IPV6InterfaceName".proto="qmi"
					uci set network."$IPV6InterfaceName".apn="$APN"
					metric=$(uci get mwan3config.$InterfaceName.wanpriority)                                                              
						if [ "$policy_type" = "failover" ]
						then
							if [ -z "$metric" ];then
								uci set network."$IPV6InterfaceName".metric=2  
							else 
								uci set network."$IPV6InterfaceName".metric="$metric"  
							fi						
						else
							uci set network."$IPV6InterfaceName".metric="1"
						fi
					uci set network."$IPV6InterfaceName".device="/dev/cdc-wdm0"                                                                
					uci set network."$IPV6InterfaceName".pdptype="ipv6"                                                                
					uci set network."$IPV6InterfaceName".ipv6="1" 
					uci set network."$IPV6InterfaceName".mtu="$mtu" 
			
					if [ "$auth" = "1" ] ||  [ "$auth" = "2" ]
					then
						uci set network."$InterfaceName".auth="$authentication"
					    uci set network."$InterfaceName".username="$username"
					    uci set network."$InterfaceName".password="$password"
					fi                                                                
				elif [ "$PDP" = "IPV4V6" ] 
				then
					uci set network."$InterfaceName"=interface
					uci set network."$InterfaceName".ifname="wwan0"
					uci set network."$InterfaceName".proto="qmi"
					uci set network."$InterfaceName".device="/dev/cdc-wdm0"                                                                
					uci set network."$InterfaceName".apn="$APN"
					uci set network."$InterfaceName".pdptype="ipv4v6"  
					metric=$(uci get mwan3config.$InterfaceName.wanpriority)                                                                
						if [ "$policy_type" = "failover" ];then
							if [ -z "$metric" ];then
								uci set network."$InterfaceName".metric=2 
							else 
								uci set network."$InterfaceName".metric="$metric"  
							fi							
						else
							uci set network."$InterfaceName".metric="1"
						fi
					if [ "$auth" = "1" ] ||  [ "$auth" = "2" ]
					then
						uci set network."$InterfaceName".auth="$authentication"
					    uci set network."$InterfaceName".username="$username"
					    uci set network."$InterfaceName".password="$password"
					fi 						 
				fi
			 fi  
				uci commit network
				if [ "$Protocol" = "cdcether" ]
				then
					if [ "$cellularmodem1" = "QuectelRM500U" ] 
					then
						SetATCommandsRM500U
					else
						SetATCommands 
					fi
				elif  [ "$Protocol" = "qmi" ]
				then  
				    SetATCommandsQMI
				fi                         
				ubus call network reload
				ifup "$InterfaceName" > /dev/null 2>&1
				ifup "$InterfaceName" > /dev/null 2>&1
				ifup "$IPV6InterfaceName" > /dev/null 2>&1
				echo "status=Enabled" > "$AddIfaceStatusFile"
		else
				echo "status=Disabled" > "$AddIfaceStatusFile" 
		fi
				
	/etc/init.d/smstools3 start
	#to glow sim led
	sim=$(cat /sys/class/gpio/gpio${SimSelectGpio}/value)
	if [ "$sim" = "$Sim1SelectValue" ]
	then
		echo "$Sim1LedGpioOnvalue" > /sys/class/gpio/gpio${Sim1LedGpio}/value
		echo "$Sim2LedGpioOffvalue" > /sys/class/gpio/gpio${Sim2LedGpio}/value
	elif [ "$sim" = "$Sim2SelectValue" ]
	then
		echo "$Sim1LedGpioOffvalue" > /sys/class/gpio/gpio${Sim1LedGpio}/value
		echo "$Sim2LedGpioOnvalue" > /sys/class/gpio/gpio${Sim2LedGpio}/value
	fi
	
	#to glow signal strength led's
	/root/InterfaceManager/script/Update_Analytics_data.sh > /dev/null 2>&1
	echo "AddIfaceRunningstatus=0" > /tmp/AddIfaceRunningstatus
}

#
# Input arguments and Default Parameters
#
InterfaceName="$1"
setpdp()
{
if [ "$InterfaceName" = "CWAN1_0" ] || [ "$InterfaceName" = "CWAN1" ]
then 

     Apntype=$Sim1apntype
	 IPV6InterfaceName=wan6c1
	 PDP=$PDP1
	 Source=modem
	 Simno=Sim1
	 uci set system.system.simNum="SIM-1"
	if [ -z "$username" ]
	then
		username=""
		password=""
	else
		username=$username
		password=$password
	fi
	if [ -z "$Sim1mtu" ]
	then
		Sim1mtu=""
	else
		mtu=$Sim1mtu
	fi 
       
	 auth=$auth
		cellularmode=$(uci get sysconfig.sysconfig.CellularOperationMode)

		if [ "$PDP1" = "IPV4" ] 
		then
			PDPN=1
			PDP_QMI=IP  		
			var=$(grep -w "option name 'CWAN1_0'" /etc/config/firewall)

		elif [ "$PDP1" = "IPV6" ] 
		then
			PDPN=2
			PDP_QMI=IPV6
		elif [ "$PDP1" = "IPV4V6" ] 
		then
			PDPN=3
			PDP_QMI=IPV4V6
			cellularmode=$(uci get sysconfig.sysconfig.CellularOperationMode)
		fi
elif [ "$InterfaceName" = "CWAN1_1" ]
then 
	 uci set system.system.simNum="SIM-2"
        Apntype=$Sim2apntype

	 IPV6InterfaceName=wan6c2
	 Simno=Sim2
	 PDP=$PDP2
         if [ -z "$sim2username" ]                                         
        then                                                           
          username=""                                                  
          password=""                                                  
         else                                                          
         username=$sim2username                                           
         password=$sim2password                                        
        fi                  
	 auth=$sim2auth
	 
	if [ -z "$Sim2mtu" ]
	then
		Sim2mtu=""
	else
		mtu=$Sim2mtu
	fi 
	 
		if [ "$PDP2" = "IPV4" ] 
		then
			  PDPN=1
			  PDP_QMI=IP
			  cellularmode=$(uci get sysconfig.sysconfig.CellularOperationMode)
		elif [ "$PDP2" = "IPV6" ] 
		then
			  PDPN=2
			  PDP_QMI=IPV6
		elif [ "$PDP2" = "IPV4V6" ] 
		then
			  PDPN=3
			  PDP_QMI=IPV4V6
			  cellularmode=$(uci get sysconfig.sysconfig.CellularOperationMode)
		fi
	
fi
}


ModemConfigFile="/etc/config/modem"
ScriptStatustDir="/tmp/InterfaceManager/status"
ScriptLogDir="/tmp/InterfaceManager/log"
PortDetailsFile="$ScriptStatustDir/$InterfaceName"".ports"
portdetails="$ScriptStatustDir/ports.txt"
AddIfaceStatusFile="$ScriptStatustDir/$InterfaceName"".AddIfaceStatus"
DeleteStatusFile="$ScriptStatustDir/$InterfaceName"".DeleteIfaceStatus"
lockfile="/var/run/$InterfaceName""AddIface.lockfile"
SleepAfterIfdown=2
SleepForEnumerationOfAllPorts=7
SystemConfigFile="/etc/config/sysconfig"
GcomScript="/etc/gcom/getcardqccidinfo.gcom"
SetnetDev="/etc/gcom/setnetdev.gcom"
GetnetDev="/etc/gcom/getnetdev.gcom"
SetApn="/etc/gcom/setapn.gcom"
SetRawIp="/etc/gcom/setrawip.gcom"
SetQiAct="/etc/gcom/setqiact.gcom"
GetQiAct="/etc/gcom/getqiact.gcom"
Updatebandlock="/root/InterfaceManager/script/cellular/Bandlock.sh"
UpdateEsim_ATCommands="/root/InterfaceManager/script/cellular/Esim_ATCommands.sh"
Updateoperatorlock="/root/InterfaceManager/script/cellular/operatorlock.sh"
Findapn="/root/InterfaceManager/script/cellular/findapn.sh"
LogrotateConfigFile="/etc/logrotate.d/AddInterfaceLogrotateConfig"
Logfile="/root/ConfigFiles/Logs/AddIfaceLog.txt"
[ -d "$ScriptStatustDir" ]  || mkdir -p "$ScriptStatustDir"
[ -d "$ScriptLogDir" ]  || mkdir -p "$ScriptLogDir"
cellular1wan6interface=wan6c1
cellular1wan6interface=wan6c2
#
# verify input arguments
#
if [ "x$InterfaceName" = "x" ]
then
		echo "Usage: $0 InterfaceName"
		echo "status=Invalid interface" > "$AddIfaceStatusFile"
		exit 1
fi

#
# 
#
if (set -o noclobber; echo $$ > "$lockfile") 2> /dev/null
then
enablecellular=$(uci get sysconfig.sysconfig.enablecellular)
		if [ "$enablecellular" = "1" ];then
			trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
			
			date=$(date)
			echo "============$date After lockfile ============" >> "$Logfile"
			Interface=`echo $InterfaceName | cut -d '_' -f1`
			ifdown "$Interface"  > /dev/null 2>&1
			ifdown "$Interface"_0  > /dev/null 2>&1
			ifdown "$Interface"_1  > /dev/null 2>&1
			
			sleep 1                                                                    
			pids=$(ps x | grep -i "mwan3.lock" | grep -v grep | awk '{print $1}')      
			kill -9 $pids                                                              
			sleep 1
			
			/usr/sbin/mwan3 ifdown wan6c1_4 > /dev/null 2>&1
			sleep 1                                                                    
			pids=$(ps x | grep -i "mwan3.lock" | grep -v grep | awk '{print $1}')      
			kill -9 $pids                                                              
			sleep 1
			/usr/sbin/mwan3 ifdown wan6c2_4 > /dev/null 2>&1
			sleep 1                                                                    
			pids=$(ps x | grep -i "mwan3.lock" | grep -v grep | awk '{print $1}')      
			kill -9 $pids                                                              
			sleep 1
			/usr/sbin/mwan3 ifdown wan6c1 > /dev/null 2>&1
			sleep 1                                                                    
			pids=$(ps x | grep -i "mwan3.lock" | grep -v grep | awk '{print $1}')      
			kill -9 $pids                                                              
			sleep 1
			/usr/sbin/mwan3 ifdown wan6c2 > /dev/null 2>&1
			sleep 1                                                                    
			pids=$(ps x | grep -i "mwan3.lock" | grep -v grep | awk '{print $1}')      
			kill -9 $pids                                                              
			sleep 1
			
			/bin/sleep "$SleepAfterIfdown"
			/bin/sleep "$SleepForEnumerationOfAllPorts"
			
			date=$(date)
			echo "============$date After mwan3 ifdown check============" >> "$Logfile"
			
			ReadModemConfigFile
			ReadSystemConfigFile
			ReadSystemGpioFile
			setpdp
			uci delete network."$Interface" > /dev/null 2>&1
			uci delete network."$Interface"_0 > /dev/null 2>&1
			uci delete network."$Interface"_1 > /dev/null 2>&1
			uci delete network.wan6c1 > /dev/null 2>&1
			uci delete network.wan6c2 > /dev/null 2>&1
			uci commit network
			ubus call network reload
	
			if [ "$ModemEnable" -ne 1 ]
			then
					rm -f "$PortDetailsFile"
					rm -f "$AddIfaceStatusFile"
					exit 0
			fi
			rm -f "$DeleteStatusFile"
			PortSearch
			/bin/sleep 3
			ubus call network.interface."$InterfaceName" up
			ubus call network.interface."$IPV6InterfaceName" up
			/usr/sbin/mwan3 ifup "$InterfaceName"
			/usr/sbin/mwan3 ifup "$IPV6InterfaceName"
			if [ "$cellularmodem1" = "QuectelRM500U" ] 
			then
				/bin/qnetdevctl.sh $ComPortSymLink $InterfaceName "qnetdevctl1" & 
	        fi      
			rm -f "$lockfile"				
			trap - INT TERM EXIT
		fi
fi
echo "AddIfaceRunningstatus=0" > /tmp/AddIfaceRunningstatus
logrotate "$LogrotateConfigFile"

#For snmp agent Modem1_Output.sh script is run to get the basic information of Modem.
/bin/Modem1_Output.sh &

exit 0
