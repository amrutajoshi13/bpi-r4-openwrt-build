#!/bin/ash -f

cellularwan1interface="CWAN1"
cellularwan2interface="CWAN2"
cellularwan3interface="CWAN3"
cellularwan1sim1interface="CWAN1_0"
cellularwan1sim2interface="CWAN1_1"

# Function to Ckeck AT Port of Modem1 at singlecellulardualsim(scds)
at1_port_scds()
{	
	simnum=$(cat /tmp/simnumfile)                                                                                         
	if [ "$simnum" = "1" ];then
		ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim1interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
		modem_comport=$cellularwan1sim1interface
		at1=$(/bin/at-cmd $ComPort at | awk 'NR==2 {print $1}')
		echo "$at1"
		if [ "$at1" = "OK" ];then
			echo "comport is working"
		else
			ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim1interface.ports" | grep -iw "DataPort" | cut -d "=" -f 2)
		fi
	else
		ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim2interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
		modem_comport=$cellularwan1sim2interface
		at1=$(/bin/at-cmd $ComPort at | awk 'NR==2 {print $1}')
		echo "$at1"
		if [ "$at1" = "OK" ];then
			echo "comport is working"
		else
			ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim2interface.ports" | grep -iw "DataPort" | cut -d "=" -f 2)
		fi
	fi
}

# Function to Ckeck AT Port of Modem1 at singlecellularsinglesim(scss)
at1_port_scss()
{
	ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
	modem_comport=$cellularwan1interface
	at1=$(/bin/at-cmd $ComPort at | awk 'NR==2 {print $1}')
	echo "$at1"
	if [ "$at1" = "OK" ];then
		echo "comport is working"
	else
		ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1interface.ports" | grep -iw "DataPort" | cut -d "=" -f 2)
	fi
}

#Function to get and store device information in /etc/snmp/system_info.txt file...
device_info()
{
	#To get deviceUptime...
	sh /bin/convert_time.sh  
	deviceUptime=$(cat /tmp/convert_time) 

	#To get deviceTemperature
	deviceTemperature=$(iwpriv ra0 stat |grep Temperature |cut -d "=" -f2 |tr -d ' ')
	
	#To get deviceNoofModem...
	deviceNoofModem=$(uci get modemstatus.modemstatus.deviceNoofModem)

	#To get CellularOperationMode...
	deviceCellularOperationMode=$(uci get modemstatus.modemstatus.CellularOperationMode)
	
	#To store Device information in .txt file to get the snmp output...
	sed -i "/^deviceUptime=/c\deviceUptime=$deviceUptime" /etc/snmp/system_info.txt
	sed -i "/^deviceTemperature=/c\deviceTemperature=$deviceTemperature" /etc/snmp/system_info.txt
	
	#If enablecellular is disable then cellular related parameters set as NA...
	if [ $enablecellular = 1 ];then 
		sed -i "/^deviceNoofModem=/c\deviceNoofModem=$deviceNoofModem" /etc/snmp/system_info.txt
		sed -i "/^deviceCellularOperationMode=/c\deviceCellularOperationMode=$deviceCellularOperationMode" /etc/snmp/system_info.txt
	else
		sed -i "/^deviceNoofModem=/c\deviceNoofModem=NA" /etc/snmp/system_info.txt
		sed -i "/^deviceCellularOperationMode=/c\deviceCellularOperationMode=NA" /etc/snmp/system_info.txt
	fi
	

	#changes by vijay
	InetInterfaceName=$(mwan3 interfaces | awk '/online|offline|disabled|down/ {print $2}')
	InetInterfaceName=$(echo "$InetInterfaceName" | tr '\n' ' ')
 
	Device1_ports=""
	Device1_status=""
	Device1_ip=""
	Device1_UPTIME=""
 
	for interface in $InetInterfaceName; do
 
    		Device_status_value1=$(mwan3 interfaces | grep "$interface" | awk '{print $4}')
 
    		# Default values for non-online
    		WANdetail="NA"
    		change_Internet_UPTIME="NA"
 
	    if [ "$Device_status_value1" = "online" ]; then
        	ifname=$(uci get network.$interface.ifname 2>/dev/null)
 
	        # Get IP
        	WANdetail=$(ifconfig "$ifname" 2>/dev/null | grep -oE 'inet addr:[0-9.]+' | grep -oE '[0-9.]+' )
        	[ -z "$WANdetail" ] && WANdetail="NA"
        	# Get raw uptime
	        Internet_UPTIME=$(mwan3 interfaces | grep "$interface" | awk '{print $5}' | sed 's/,$//')
 
       		 # Convert raw uptime
			if [ -n "$Internet_UPTIME" ]; then
    				raw_h=$(echo "$Internet_UPTIME" | cut -d: -f1)
    				raw_m=$(echo "$Internet_UPTIME" | cut -d: -f2)
    				raw_s=$(echo "$Internet_UPTIME" | cut -d: -f3)

    				# remove all non-digits
    					h=${raw_h//[!0-9]/}
    					m=${raw_m//[!0-9]/}
    					s=${raw_s//[!0-9]/}

					    h=${h:-0}
    					    m=${m:-0}
    					    s=${s:-0}

					    total=$((h * 3600 + m * 60 + s))

    					d=$((total / 86400))
    					h=$(( (total % 86400) / 3600 ))
    					m=$(( (total % 3600) / 60 ))
    					s=$(( total % 60 ))

				    change_Internet_UPTIME=$(printf "%dd:%02dh:%02dm:%02ds" "$d" "$h" "$m" "$s")
			fi
        	
    	fi
 
    		# Append values
    		if [ -z "$Device1_ports" ]; then
        		Device1_ports="$interface"
        		Device1_status="$Device_status_value1"
        		Device1_ip="$WANdetail"
       		 	Device1_UPTIME="$change_Internet_UPTIME"
    		else
       			Device1_ports="$Device1_ports || $interface"
        		Device1_status="$Device1_status || $Device_status_value1"
        		Device1_ip="$Device1_ip || $WANdetail"
        		Device1_UPTIME="$Device1_UPTIME || $change_Internet_UPTIME"
    		fi
 
	done
 
	# FINAL OUTPUT
	uci set modemstatus.modemstatus.deviceInterfaceName1="$Device1_ports"
	uci set modemstatus.modemstatus.deviceInterfacestatus1="$Device1_status"
	uci set modemstatus.modemstatus.deviceInterfaceip1="$Device1_ip"
	uci set modemstatus.modemstatus.deviceInterfacetime1="$Device1_UPTIME"
	
	#pulkit
	if [ "$Device_status_value1" = "online" ]; then
		deviceInternetStatus="online"
	else
		deviceInternetStatus="offline"
	fi


	wan_interfaces=$(mwan3 interfaces | grep -i EWAN)
	wan_interfaces_online=$(echo $wan_interfaces | grep -o online)
	if [ -n "$wan_interfaces_online" ];then
		deviceEWANInternetStatus="online"
	else
		deviceEWANInternetStatus="offline"
	fi

	CWAN_interfaces=$(mwan3 interfaces | grep -i CWAN)
	CWAN_interfaces_online=$(echo $CWAN_interfaces | grep -o online)
	if [ -n "$CWAN_interfaces_online" ];then
		SIM_Status="online"
	else
		SIM_Status="offline"
	fi
	uci set modemstatus.modemstatus.SIM_StatusONOFF=$SIM_Status
	# Replace " || " with "," (removing spaces) because we set these variable in modemstatus file...
	Device_ports=${Device1_ports// || /,}
	Device_status=${Device1_status// || /,}
	Device_ip=${Device1_ip// || /,}
	Device_UPTIME=${Device1_UPTIME// || /,}

	sed -i "/^deviceInternetStatus=/c\deviceInternetStatus=$deviceInternetStatus" /etc/snmp/system_info.txt
	uci set modemstatus.modemstatus.deviceInternetStatus=$deviceInternetStatus
	deviceConfiguredWANInterfaceName=$(echo "$InetInterfaceName" | tr ' ' ',')
	sed -i "/^deviceConfiguredWANInterfaceName=/c\deviceConfiguredWANInterfaceName=$deviceConfiguredWANInterfaceName" /etc/snmp/system_info.txt
	uci set modemstatus.modemstatus.deviceConfiguredWANInterfaceName=$deviceConfiguredWANInterfaceName
	sed -i "/^deviceActiveWANInterfaceName=/c\deviceActiveWANInterfaceName=$Device_ports" /etc/snmp/system_info.txt
	sed -i "/^deviceActiveWANInterfaceStatus=/c\deviceActiveWANInterfaceStatus=$Device_status" /etc/snmp/system_info.txt
	sed -i "/^deviceActiveWANIP=/c\deviceActiveWANIP=$Device_ip" /etc/snmp/system_info.txt
	sed -i "/^deviceActiveWANInternetUptime=/c\deviceActiveWANInternetUptime=$Device_UPTIME" /etc/snmp/system_info.txt
	sed -i "/^deviceEWANInternetStatus=/c\deviceEWANInternetStatus=$deviceEWANInternetStatus" /etc/snmp/system_info.txt
	uci commit modemstatus

}

# Function to get and store modem1 information in /etc/snmp/modem1_info.txt
modem1_info() {
	
	#To get modem1 information...
    ModemRevision=$(uci get modemstatus.modemstatus.ModemRevision)
    Manufacturer=$(uci get modemstatus.modemstatus.Manufacturer)
    IMSI=$(uci get modemstatus.modemstatus.IMSI)
    Model=$(uci get modemstatus.modemstatus.Model)
    Imei=$(uci get modemstatus.modemstatus.Imei)
    
    #To store modem1 information...
    {
        echo "modem1Revision=$ModemRevision"
        echo "modem1Manufacturer=$Manufacturer"
        echo "modem1IMSI=$IMSI"
        echo "modem1Model=$Model"
        echo "modem1IMEI=$Imei"
        echo "modem1ActiveSim=$ActiveSim"
    } | tr -d '\r' > /etc/snmp/modem1_info.txt
}

# Function to get and store modem1 sim information in /etc/snmp/modem1_sim${sim_num}_info.txt...
#sim_num value is depend on active sim...
#If sim_num is 1 then values are store in /etc/snmp/modem1_sim1_info.txt file...
#If sim_num is 2 then values are store in /etc/snmp/modem1_sim2_info.txt file...
modem1_sim_info() {
	
	sim_num="$1"
	file=$(echo /etc/snmp/modem1_sim${sim_num}_info.txt)
		
	#To get modem1 sim information...
	sim_Reg_State=$(uci get modemstatus.modemstatus.sim_Reg_State)
    PinState=$(uci get modemstatus.modemstatus.PinState)
    SignalStrength=$(uci get modemstatus.modemstatus.SignalStrength)
    Operator=$(uci get modemstatus.modemstatus.Operator)
    OperatorCode=$(uci get modemstatus.modemstatus.OperatorCode)
    CellID=$(uci get modemstatus.modemstatus.CellID)
    MBSentToday1=$(uci get modemstatus.modemstatus.SentToday1)
    MBReceivedToday1=$(uci get modemstatus.modemstatus.ReceivedToday1)
    MBConsumedToday1=$(uci get modemstatus.modemstatus.MBConsumedToday1)
    MBSentToday2=$(uci get modemstatus.modemstatus.SentToday2)
    MBReceivedToday2=$(uci get modemstatus.modemstatus.ReceivedToday2)
    MBConsumedToday2=$(uci get modemstatus.modemstatus.MBConsumedToday2)
    MBSentCurrentMonth1=$(uci get modemstatus.modemstatus.msent1)
    MBReceivedCurrentMonth1=$(uci get modemstatus.modemstatus.mreceived1)
    MBConsumedCurrentMonth1=$(uci get modemstatus.modemstatus.mMBconsumed1)
    MBSentCurrentMonth2=$(uci get modemstatus.modemstatus.msent2)
    MBReceivedCurrentMonth2=$(uci get modemstatus.modemstatus.mreceived2)
    MBConsumedCurrentMonth2=$(uci get modemstatus.modemstatus.mMBconsumed2)
	ConnectionState=$(mwan3 interfaces |grep "$modem_comport" | awk '{print $4}')
    ConnectionMode=$(uci get modemstatus.modemstatus.Connected)
    SINR=$(uci get modemstatus.modemstatus.SINR)
    RSRP=$(uci get modemstatus.modemstatus.RSRP)
    RSRQ=$(uci get modemstatus.modemstatus.RSRQ)
    RSSI=$(uci get modemstatus.modemstatus.RSSI)
    IP=$(cat /tmp/modem1_IP | tr ' ' ',' | sed 's/,$//')   
    QCCID=$QCCID
    FDDIMode=$(uci get modemstatus.modemstatus.MODE)
    BandNumber=$(uci get modemstatus.modemstatus.BAND)
    pinstate
    
    #To store modem1 sim information...
    {
		echo "modem1sim${sim_num}RegState=$sim_Reg_State"
        echo "modem1sim${sim_num}PinState=$PinState"
        echo "modem1sim${sim_num}SignalStrengthCSQ=$SignalStrength"
        echo "modem1sim${sim_num}Operator=$Operator"
        echo "modem1sim${sim_num}OperatorCode=$OperatorCode"
        echo "modem1sim${sim_num}CellID=$CellID"
        if [ "${sim_num}" = "1" ];then		
			echo "modem1sim${sim_num}MBSentToday=$MBSentToday1"
			echo "modem1sim${sim_num}MBReceivedToday=$MBReceivedToday1"
			echo "modem1sim${sim_num}MBConsumedToday=$MBConsumedToday1"
			echo "modem1sim${sim_num}MBSentCurrentMonth=$MBSentCurrentMonth1"
			echo "modem1sim${sim_num}MBReceivedCurrentMonth=$MBReceivedCurrentMonth1"
			echo "modem1sim${sim_num}MBConsumedCurrentMonth=$MBConsumedCurrentMonth1"
		else
			echo "modem1sim${sim_num}MBSentToday=$MBSentToday2"
			echo "modem1sim${sim_num}MBReceivedToday=$MBReceivedToday2"
			echo "modem1sim${sim_num}MBConsumedToday=$MBConsumedToday2"
			echo "modem1sim${sim_num}MBSentCurrentMonth=$MBSentCurrentMonth2"
			echo "modem1sim${sim_num}MBReceivedCurrentMonth=$MBReceivedCurrentMonth2"
			echo "modem1sim${sim_num}MBConsumedCurrentMonth=$MBConsumedCurrentMonth2"
		fi
        echo "modem1sim${sim_num}ConnectionState=$ConnectionState"
        echo "modem1sim${sim_num}ConnectionMode=$ConnectionMode"
        echo "modem1sim${sim_num}SINR=$SINR"
        echo "modem1sim${sim_num}RSRP=$RSRP"
        echo "modem1sim${sim_num}RSRQ=$RSRQ"
        echo "modem1sim${sim_num}RSSI=$RSSI"
        echo "modem1sim${sim_num}IP=$IP"
        echo "modem1sim${sim_num}QCCID=$QCCID"
        echo "modem1sim${sim_num}FDDIMode=$FDDIMode"
        echo "modem1sim${sim_num}BandNumber=$BandNumber"
    } > $file
}

#For snmp agent "ActiveSim" is fixed with the help of QCCID...
Sim_info()
{
	sim="$1"
	QCCID=$(uci get system.system.qccid | tr -d '\011\012\013\014\015\040')
	for i in $(seq 1 3)
    do
		len_qccid=$(echo ${#QCCID})
		if [ "$len_qccid" -eq "20" ]
		then
			ActiveSim=$sim
			break
		else
			ActiveSim=0
			QCCID=$(at-cmd $ComPort at+qccid | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		fi
		echo "$i"
	done
}

pinstate() {
	for i in $(seq 1 3)
    do
		if [ -z "$PinState" ]
		then
			PinState=$(at-cmd $ComPort at+cpin? | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		fi
		echo "$i"
	done
}

enablecellular=$(uci get sysconfig.sysconfig.enablecellular)
cellularmode=$(uci get sysconfig.sysconfig.CellularOperationMode)

#Call the function to get device information
device_info

if [ $enablecellular = 0 ]
then 
	exit 0
fi

if [ "$cellularmode" = "dualcellularsinglesim" ]
then
	ComPort1=$(uci get modem.CWAN1.ComPortSymLink)
	ComPort2=$(uci get modem.CWAN2.ComPortSymLink)
					
elif [ "$cellularmode" = "singlecellulardualsim" ]
then
	at1_port_scds                                                                                        
	if [ "$simnum" = "1" ]                                                                                                
	then
		Sim_info 1
		modem1_info
		modem1_sim_info 1
	else
		Sim_info 2
		modem1_info
		modem1_sim_info 2
	fi
else
	at1_port_scss
	Sim_info 1
	modem1_info
	modem1_sim_info 1
fi
