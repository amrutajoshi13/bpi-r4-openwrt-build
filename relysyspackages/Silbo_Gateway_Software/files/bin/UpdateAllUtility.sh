  #!/bin/sh
. /lib/functions.sh

# Define paths to the configurations file
SNMPConfigFile="/root/InterfaceManager/Utilities/SNMP_Utility/Config.txt"
SNMPUtilityPath="/root/InterfaceManager/Utilities/SNMP_Utility"
Temp_UtilityPath="/root/InterfaceManager/Utilities/RTD_Utility"

#############################Gateway paths##################################################
EMeterRS485APIPath="/root/RS485UtilityComponent"
EMeterRS232APIPath="/root/RS232UtilityComponent"
DIIndividualAPIPath="/root/DIUtilityIndividualTestComponent"
DOIndividualAPIPath="/root/DOUtilityIndividualTestComponent"
AnalogInputAPIPath="/root/ADCUtilityComponent"

RS485APIConfigFile="/root/RS485UtilityComponent/etc/Config/RS485utilityConfig"
#RS232APIConfigFile="/root/config.txt"
RS232UtilityCfgPath="/root/RS232UtilityComponent/etc/Config/RS232utilityConfig"

. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfigParameters.cfg
. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfig.cfg
. /usr/local/bin/Testscripts/testscriptconfig.cfg
. /root/ReadAIAppComponent/etc/Config/ReadAIAppWebConfig.cfg
. /root/RS232UtilityComponent/etc/Config/RS232utilityConfig.cfg

# --------------------------------------------------
# Board Detection Logic
# --------------------------------------------------

# Read board ID from flash offset 0xF020
flash_val_f020=$(dd if=/dev/mtd2 bs=1 skip=$((0xF020)) count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')

# Read board subtype from flash offset 0xF021 (decimal)
flash_val_f021=$(dd if=/dev/mtd2 bs=1 skip=$((0xF021)) count=1 2>/dev/null | hexdump -v -e '1/1 "%u"')

# Default values
[ -z "$flash_val_f020" ] && flash_val_f020="FF"
[ -z "$flash_val_f021" ] && flash_val_f021="255"

# Decide board name
case "$flash_val_f020" in
    0B)
        board_name="IDB54-C-GW"
        ;;
    0F)
        board_name="IDF54-C-GW"
        ;;
    47)
        case "$flash_val_f021" in
            88)
                board_name="silbo-IDG50-GW"
                ;;
            99)
                board_name="silbo-RVWG50-GW"
                ;;
            *)
                board_name="silbo-RVWG50-GW"
                ;;
        esac
        ;;
    *)
        board_name=$(cat /tmp/sysinfo/board_name)
        ;;
esac

echo "Detected Board Name : $board_name" >&2

# echo "Detected Board Name : $board_name"

# Decide RS485 serial port
if echo "$board_name" | grep -qE "(IDG|RVWG)"
then
    SERIAL_PORT="/dev/ttyUSB0"
else
    SERIAL_PORT="/dev/ttyS1"
fi

# echo "Using SERIAL_PORT : $SERIAL_PORT"
echo "Using SERIAL_PORT : $SERIAL_PORT" >&2

# Read arguments
Actiontype="$1"
ActionData="$2"

# Function to extract values from JSON
extract_json_value() {
    key="$1"
    echo "$ActionData" | grep -o "\"$key\":\"[^\"]*\"" | sed -E "s/\"$key\":\"([^\"]*)\"/\1/"
}

# Extract values from the JSON data

#RS485 and RS232
SlaveID=$(extract_json_value 'slaveid')
StartRegister=$(extract_json_value 'StartRegister')
NumberOfRegister=$(extract_json_value 'NoofRegister')
Baudrate=$(extract_json_value 'baudrate')
Parity=$(extract_json_value 'parity')
Databits=$(extract_json_value 'Databits')
Stopbits=$(extract_json_value 'Stopbits')
FunctionCode=$(extract_json_value 'functioncode')
StdModbusEnable=$(extract_json_value 'ModbusEnable')
DataType=$(extract_json_value 'DataType')
WriteData=$(extract_json_value 'DataWrite')
Mode=$(extract_json_value 'Mode')
Port=$(extract_json_value 'portnumber')
Protocol=$(extract_json_value 'Protocal')
TCPIPAdress=$(extract_json_value 'CommunicationIP')
TCPPort=$(extract_json_value 'CommunicationPort')
TCPtimeout=$(extract_json_value 'Communicationtimeout')
RS232ListenTime=$(extract_json_value 'ListenTime')
Flowcontrol=$(extract_json_value 'Flowcontrol')
 
#SNMP
IPAddress=$(extract_json_value 'SNMPIPAddress')
SNMPVersion=$(extract_json_value 'SNMPversion')
CommunityString=$(extract_json_value 'SNMPCommunityString')
portnumber=$(extract_json_value 'SNMPportnumber')
OID=$(extract_json_value 'SNMPoid')
Enterpriseid=$(extract_json_value 'SNMPEnterpriseid')
MIBFileName=$(extract_json_value 'MIBFileName')

#DO_Write
DOPinNumber=$(extract_json_value 'DOPinNumber')
DOPinAction=$(extract_json_value 'DOPinAction')

case "$Actiontype" in

RS485)

	if [ "$Protocol" = "RTU" ]; then

		{
			echo "Mode=$Mode"
			echo "StartRegister=$StartRegister"
			echo "NumberOfRegisters=$NumberOfRegister"
			echo "Baudrate=$Baudrate"
			echo "Stopbits=$Stopbits"
			echo "Databits=$Databits"
			echo "Parity=$Parity"
			echo "Datatype=$DataType"
			echo "Slaveid=$SlaveID"

			# --------------------------------------------------
			# Serial Port Handling
			# --------------------------------------------------

			if [ "$Port" = "/dev/ttyS2" ]; then
				echo "SerialPort=\"/dev/ttyS2\""
			else
				echo "SerialPort=\"$SERIAL_PORT\""
			fi

			echo "ModbusProtocol=\"$Protocol\""
			echo "DataForMode2=\"$WriteData\""
			echo "StdModbusEnable=$StdModbusEnable"

			# TCP defaults for RTU
			echo "modbusCommip=\"0.0.0.0\""
			echo "modbusCommport=502"
			echo "modbusCommtimeout=10"

			# Function Code based on Mode
			echo "FunctionalCode=$FunctionCode"

		} > "${RS485APIConfigFile}.cfg"

	else

		# ===== TCP Mode =====
		{
		    echo "Mode=$Mode"
			echo "StartRegister=$StartRegister"
			echo "NumberOfRegisters=$NumberOfRegister"
			echo "Baudrate=9600"
			echo "Stopbits=1"
			echo "Databits=8"
			echo "Parity=0"
			echo "Datatype=$DataType"
			echo "Slaveid=$SlaveID"

			echo "SerialPort=\"0\""
			echo "ModbusProtocol=\"$Protocol\""
			echo "DataForMode2=\"$WriteData\""
			echo "StdModbusEnable=$StdModbusEnable"

			# TCP Parameters from JSON
			if [ -z "$TCPIPAdress" ]; then
				echo "modbusCommip=\"0.0.0.0\""
			else
				echo "modbusCommip=\"$TCPIPAdress\""
			fi

			if [ -z "$TCPPort" ]; then
				echo "modbusCommport=502"
			else
				echo "modbusCommport=$TCPPort"
			fi

			if [ -z "$TCPtimeout" ]; then
				echo "modbusCommtimeout=10"
			else
				echo "modbusCommtimeout=$TCPtimeout"
			fi

			echo "FunctionalCode=$FunctionCode"

		} > "${RS485APIConfigFile}.cfg"

	fi

	# Run the RS485 utility and capture its output
	cd "$EMeterRS485APIPath"

	UtilityOutput=$("${EMeterRS485APIPath}/RS485Utility" 2>&1)

	UtilityExitCode=$?

	# Return the output as is
	if [ $UtilityExitCode -eq 0 ]; then
		echo "{\"code\":0,\"output\":\"$UtilityOutput\"}"
	else
		echo "{\"code\":1,\"output\":\"Failed to run RS485 utility\", \"utility_output\":\"$UtilityOutput\"}"
	fi
	;;
        
        
        
        
RS232)
if [ "$Protocol" == "1" ]; then

    {
		
        echo "slave_id=$SlaveID"
        echo "start_reg=$StartRegister"
        echo "No_of_reg=$NumberOfRegister"
        echo "baud=$Baudrate"
        echo "stop_bits=$Stopbits"
        echo "data_bits=$Databits"
        echo "function_id=$FunctionCode"
        echo "parity=$Parity"
        echo "flow_control=$Flowcontrol"
        echo "delay=500"
        echo "SerialPort=\"$SerialPort\""
        echo "sleep_in_milliseconds=500"
    } > "${RS232UtilityCfgPath}.cfg"

else

    {
        #echo "slave_id=0"
        #echo "start_reg=0"
        #echo "No_of_reg=0"
        echo "baud=$Baudrate"
        echo "stop_bits=$Stopbits"
        echo "data_bits=$Databits"
        echo "function_id=0"
        echo "parity=$Parity"
        echo "flow_control=$Flowcontrol"
        echo "delay=500"
        echo "SerialPort=\"$SerialPort\""
        echo "sleep_in_milliseconds=500"
    } > "${RS232UtilityCfgPath}.cfg"

fi

        
        # Run the RS232 utility and capture its output
	    cd $EMeterRS232APIPath
        UtilityOutput=$(${EMeterRS232APIPath}/RS232UtilityGD44 2>&1)

        UtilityExitCode=$?

        # Return the output as is
        if [ $UtilityExitCode -eq 0 ]; then
            echo "{\"code\":0,\"output\":\"$UtilityOutput\"}"
        else
            echo "{\"code\":1,\"output\":\"Failed to run RS232 utility\", \"utility_output\":\"$UtilityOutput\"}"
        fi
        ;;
        
        
        
 #RS232)
          #if [ "$Protocol" == "1" ]; then
           
            
          ## Write parameters to the config file for RS232
          #{
            
            #echo "SlaveID=$SlaveID"
            #echo "FunctionCode=$FunctionCode"
            #echo "StartRegister=$StartRegister"
            #echo "NumberOfRegister=$NumberOfRegister"
            #echo "Port=$Port"
            #echo "Baudrate=$Baudrate"
            #echo "Parity=$Parity"
            #echo "Databits=$Databits"
            #echo "Stopbits=$Stopbits"
            #echo "ListenTime=0"
            #echo "Flowcontrol=$Flowcontrol"
            #echo "Delay=500"
            #echo "Query Interval=500"
            #echo "Protocol=$Protocol"
        #} > "$RS232ConfigFile"
#else
        #{
           
            #echo "SlaveID=0"
            #echo "FunctionCode=0"
            #echo "StartRegister=0"
            #echo "NumberOfRegister=0"
            #echo "Port=$Port"
            #echo "Baudrate=$Baudrate"
            #echo "Parity=$Parity"
            #echo "Databits=$Databits"
            #echo "Stopbits=$Stopbits"
            #echo "ListenTime=$RS232ListenTime"
            #echo "Flowcontrol=$Flowcontrol"
            #echo "Delay=500"
            #echo "Query Interval=500"
            #echo "Protocol=$Protocol"
        #} > "$RS232ConfigFile"
        #fi
        ## Run the RS232 utility and capture its output
	    #cd $RS232UtilityPath
        #UtilityOutput=$(${EMeterRS232APIPath}/RS232Utility 2>&1)

        #UtilityExitCode=$?

        ## Return the output as is
        #if [ $UtilityExitCode -eq 0 ]; then
            #echo "{\"code\":0,\"output\":\"$UtilityOutput\"}"
        #else
            #echo "{\"code\":1,\"output\":\"Failed to run RS232 utility\", \"utility_output\":\"$UtilityOutput\"}"
        #fi
        #;;
        
        
DI_Utility)
    # Load configuration

    result=""
    i=1
    while [ "$i" -le "$NoOfDInput" ]
    do
        eval mode=\${DIOMode$i}
                if [ "$mode" = "0" ]; then
				cd $DIIndividualAPIPath
				UtilityOutput=$(${DIIndividualAPIPath}/DIUtilityIndividual "$i" 2>&1 \
                | awk -F'= ' 'NF>1{print $2}' \
                | tail -n1 \
                | tr -d '[:space:]')
				result="${result} DI$i=$UtilityOutput;"
				fi
        i=$((i + 1))
    done

    echo "{\"code\":0,\"output\":\"$result\"}"
    ;;

 
     
        
DO_Utility)
	. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfig.cfg

	result=""
	i=1

	while [ "$i" -le "$NoOfDInput" ]
	do
		eval mode=\${DIOMode$i}

		if [ "$mode" = "1" ]; then
		
	
			cd $DIIndividualAPIPath
			UtilityOutput=$(${DIIndividualAPIPath}/DIUtilityIndividual "$i" 2>&1 \
					| awk -F'= ' 'NF>1{print $2}' \
					| tail -n1 \
					| tr -d '[:space:]')
			result="${result} DO$i=$UtilityOutput;"
		fi

		i=$((i + 1))
	done

	echo "{\"code\":0,\"output\":\"$result\"}"
;;       

DO_Write_Utility)
    #Input1Value="$2"
    #Input2Value="$3"
	cd $DOIndividualAPIPath
	UtilityOutput=$(${DOIndividualAPIPath}/DOUtilityIndividual "$DOPinNumber" "$DOPinAction" 2>&1)
	

    # Extract only final value (0 or 1)
    DOValue=$(echo "$UtilityOutput" \
              | awk -F'= ' '/outputPinNumber Value/ {print $2}' \
              | tr -d '[:space:]')

    echo "{\"code\":0,\"output\":\"DO$Input1Value=$DOValue\"}"
;;    
AI_Utility)

	UtilityOutput=$(/bin/AIO_Utility.sh 2>&1)
    echo "{\"code\":0,\"output\":\"$UtilityOutput\"}"
;;    

#AI_Utility)

    #range=2

    #i=1
    #while [ "$i" -le "$NoOfAInput" ]
    #do
        ## Get ChannelType dynamically (ChannelType0, ChannelType1, etc.)
        #eval ChannelType=\$ChannelType$((i-1))
		#cd $AnalogInputAPIPath
        #AI_Out=$(${AnalogInputAPIPath}/ADCUtility "$i" "$range" 2>&1)

        #last_line=$(echo "$AI_Out" | tail -n 1)

        #value=$(echo "$last_line" | awk '{print $3}' | tr -d '[:space:]')

        #if [ "$ChannelType" = "1" ]; then
            #echo "{\"code\":0,\"channel\":\"AI$i\",\"output\":\"Current=$value\"}"
        #else
            #echo "{\"code\":0,\"channel\":\"AI$i\",\"output\":\"Voltage=$value\"}"
        #fi

        #i=$((i+1))
    #done
#;;





 SNMP)
       if [ "$Protocol" == "1" ]; then
        {
            echo "MIBDIRS=/usr/share/snmp/mibs/$MIBFileName"
            echo "OID=0"
            echo "SNMPVersion=$SNMPVersion"
            echo "CommunityString=$CommunityString"
            echo "Port=0"
            echo "Protocol=$Protocol"
            echo "Enterpriseid=$Enterpriseid"
            echo "IpAddress=$IPAddress" 
           
        } > "$SNMPConfigFile"
else
        {
            echo "MIBDIRS=/usr/share/snmp/mibs/$MIBFileName"
            echo "OID=$OID"
            echo "SNMPVersion=$SNMPVersion"
            echo "CommunityString=$CommunityString"
            echo "Port=$portnumber"
            echo "Protocol=$Protocol"
            echo "Enterpriseid=0"
            echo "IpAddress=$IPAddress"

        } > "$SNMPConfigFile"
        fi
        # Run the RS232 utility and capture its output
        cd $SNMPUtilityPath
        UtilityOutput=$(${SNMPUtilityPath}/SNMP_Utility 2>&1)
    
        UtilityExitCode=$?

        # Return the output as is
        if [ $UtilityExitCode -eq 0 ]; then
            echo "{\"code\":0,\"output\":\"$UtilityOutput\"}"
        else
            echo "{\"code\":1,\"output\":\"Failed to run SNMP utility\", \"utility_output\":\"$UtilityOutput\"}"
        fi
        ;;






Temp_Utility)
       
         cd $Temp_UtilityPath
       UtilityOutput=$(${Temp_UtilityPath}/RTD_Utility 2>&1)
          
        UtilityExitCode=$?

        # Return the output as is
        if [ $UtilityExitCode -eq 0 ]; then
            echo "{\"code\":0,\"output\":\"$UtilityOutput\"}"
           
        else
            echo "{\"code\":1,\"output\":\"Failed to run RTD utility\", \"utility_output\":\"$UtilityOutput\"}"
        fi
        ;;


    *)
        echo "{\"code\":1,\"output\":\"Invalid type specified\"}"
        ;;
esac

exit 0
