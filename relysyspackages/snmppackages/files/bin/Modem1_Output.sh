#!/bin/sh

. /lib/functions.sh

#Add Modem1 Related Output in /etc/config/modemstaus for snmp agent

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
		at1=$(/bin/at-cmd $ComPort at | awk 'NR==2 {print $1}')
		echo "$at1"
		if [ "$at1" = "OK" ];then
			echo "comport is working"
		else
			ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim1interface.ports" | grep -iw "DataPort" | cut -d "=" -f 2)
		fi
	else
		ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim2interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
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
	at1=$(/bin/at-cmd $ComPort at | awk 'NR==2 {print $1}')
	echo "$at1"
	if [ "$at1" = "OK" ];then
		echo "comport is working"
	else
		ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1interface.ports" | grep -iw "DataPort" | cut -d "=" -f 2)
	fi
}

get_at_value_1() {
	at-cmd $ComPort "$1" | awk NR==2 | tr -d '\011\012\013\014\015\040'
}	

get_modem_info1() {	
	#ModemRevision,Manufacturer and Model is store in modem1_detail file through ATI...
	at-cmd $ComPort ATI > /tmp/modem1_detail
	ModemRevision=$(cat /tmp/modem1_detail | awk '/Revision:/ {print $2}')
	Manufacturer=$(cat /tmp/modem1_detail | awk NR==2 | tr -d '\011\012\013\014\015\040')
	Model=$(cat /tmp/modem1_detail | awk NR==3 | tr -d '\011\012\013\014\015\040')
	IMSI=$(get_at_value_1 'AT+CIMI')
	for i in $(seq 1 3)
	do
		len_IMSI=$(echo ${#IMSI})
		# if [ "$len_IMSI" -eq "15" ];then
		if [ "$len_IMSI" -eq "15" ] && [ -n "$IMSI" ] && [[ "$IMSI" != "-" ]] && [[ "$IMSI" != *"Entry not found"* ]] && [[ "$IMSI" != *"ERROR"* ]]; then
			break
		else
			IMSI=$(get_at_value_1 'AT+CIMI')
		fi
	done
	Imei=$(get_at_value_1 'AT+GSN')
	for i in $(seq 1 3)
	do
		len_Imei=$(echo ${#Imei})
		# if [ "$len_Imei" -eq "15" ];then
		if [ "$len_Imei" -eq "15" ] && [ -n "$Imei" ] && [[ "$Imei" != "-" ]] && [[ "$Imei" != *"Entry not found"* ]] && [[ "$Imei" != *"ERROR"* ]]; then
			break
		else
			Imei=$(get_at_value_1 'AT+GSN')
		fi
	done
}

check_get_modem_info1()
{
for i in $(seq 1 3)
do
	if [ -z "$ModemRevision" ] || [ -z "$Manufacturer" ] || [ -z "$IMSI" ] || [ -z "$Model" ] || [ -z "$Imei" ]
	then
		echo "Attempt $i: trying to get modem info..."
		get_modem_info1
	else
		echo "All information are gathered..."
		break
	fi
done
}

# Function to store Modem1 values in a file (/bin/snmp/modem1_version)
modem1_value() {
	{
		echo ModemRevision=$ModemRevision 
		echo Manufacturer=$Manufacturer 
		echo IMSI=$IMSI 
		echo Model=$Model 
		echo Imei=$Imei 
	} | tr -d '\r' > /bin/snmp/modem1_version
	
	uci set modemstatus.modemstatus.ModemRevision=$ModemRevision
	uci set modemstatus.modemstatus.Manufacturer=$Manufacturer
	uci set modemstatus.modemstatus.IMSI=$IMSI
	uci set modemstatus.modemstatus.Model=$Model
	uci set modemstatus.modemstatus.Imei=$Imei
	uci commit modemstatus
}

touch /bin/snmp/modem1_version

enablecellular=$(uci get sysconfig.sysconfig.enablecellular)
cellularmode=$(uci get sysconfig.sysconfig.CellularOperationMode)

if [ $enablecellular = 0 ]
then 
	exit 0
fi

if [ "$cellularmode" = "singlecellularsinglesim" ];then
	at1_port_scss
    get_modem_info1
    at1_port_scss
    check_get_modem_info1
    modem1_value
    
elif [ "$cellularmode" = "singlecellulardualsim" ];then
	at1_port_scds
    get_modem_info1
    at1_port_scds
    check_get_modem_info1
    modem1_value

elif [ "$cellularmode" = dualcellularsinglesim ];then
	ComPort1=$(uci get modem.CWAN1.ComPortSymLink)
	ComPort2=$(uci get modem.CWAN2.ComPortSymLink)  
fi
			
exit 0
