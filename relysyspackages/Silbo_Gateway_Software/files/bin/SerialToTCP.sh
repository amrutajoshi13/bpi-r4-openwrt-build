#!/bin/sh
. /lib/functions.sh

LOCKDIR="/tmp/SerialToTCP.lock"

# atomic lock
if ! mkdir "$LOCKDIR" 2>/dev/null; then
    echo "SerialToTCP already running"
    exit 0
fi

trap 'rmdir "$LOCKDIR"' EXIT

# --------------------------------------------------
# Board Detection Logic
# --------------------------------------------------

# Read board ID from flash offset 0xF020
flash_val_f020=$(dd if=/dev/mtd2 bs=1 skip=$((0xF020)) count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')

# Read board subtype from flash offset 0xF021 (decimal)
flash_val_f021=$(dd if=/dev/mtd2 bs=1 skip=$((0xF021)) count=1 2>/dev/null | od -An -tu1 | tr -d ' ')

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

echo "Detected Board Name : $board_name"

# Decide serial port
if echo "$board_name" | grep -qE "(IDG|RVWG)"
then
    SERIAL_PORT="/dev/ttyUSB0"
else
    SERIAL_PORT="/dev/ttyS1"
fi

echo "Using Serial Port : $SERIAL_PORT"

# --------------------------------------------------
# SerialToTCP
# --------------------------------------------------

SerialToTCPSerialcfg="/root/rtumd/etc/config/SerialPortConfig.cfg"
SerialToTCPTCPcfg="/root/rtumd/etc/config/TcpPortConfig.cfg"
SerialToTCPUcifile="/etc/config/portconfig"

noOfClients=0

# Clear config files safely
> "$SerialToTCPSerialcfg"
> "$SerialToTCPTCPcfg"

UpdateTCPClients()
{
	client="$1"
	
	config_get clientIP                 "${client}"     clientIP
	config_get clientPort               "${client}"     clientPort
	config_get SlaveID                  "${client}"     SlaveID
	config_get ResponseWaitTime         "${client}"     ResponseWaitTime
	config_get ConnectionTimeout        "${client}"     ConnectionTimeout
	
	if [ ! -z "${clientIP}" ]
	then
		noOfClients=$((noOfClients+1))

		{
			echo "clientIP${noOfClients} = \"${clientIP}\""
			echo "clientPort${noOfClients} = ${clientPort}"
			echo "SlaveID${noOfClients} = ${SlaveID}"
			echo "ResponseWaitTime${noOfClients} = ${ResponseWaitTime}"
			echo "ConnectionTimeout${noOfClients} = ${ConnectionTimeout}"
		} >> "${SerialToTCPTCPcfg}"
	fi
}

UpdateSerialToTCP()
{	
	portConfig="$1"

	config_get mbusdBaudrate1                   "$portConfig"     mbusdBaudrate1
	config_get mbusdParity1                     "$portConfig"     mbusdParity1
	config_get mbusdNoOfStopbits1               "$portConfig"     mbusdNoOfStopbits1
	config_get mbusdDatabits1                   "$portConfig"     mbusdDatabits1
	
	config_get mbusdtcpIP                       "$portConfig"     mbusdtcpIP
	config_get mbusdtcpslaveport1               "$portConfig"     mbusdtcpslaveport1
	config_get mbusdmaxretries1                 "$portConfig"     mbusdmaxretries1
	config_get mbusddelaybetweeneachrequest1    "$portConfig"     mbusddelaybetweeneachrequest1
	config_get mbusdconnectiontimeout1          "$portConfig"     mbusdconnectiontimeout1
	config_get mbusdresponsewaittime1           "$portConfig"     mbusdresponsewaittime1
	config_get mbusdinactivitytimeout1          "$portConfig"     mbusdinactivitytimeout1
	
	{
		echo "SerialPort = \"${SERIAL_PORT}\""
		echo "Baudrate = ${mbusdBaudrate1}"
		echo "Parity = ${mbusdParity1}"
		echo "Databits = ${mbusdDatabits1}"
		echo "Stopbits = ${mbusdNoOfStopbits1}"
	} >> "${SerialToTCPSerialcfg}"
	
	{
		echo "AdressFamily = \"IPv4\""
		echo "NoOfRetries = ${mbusdmaxretries1}"
		echo "DelayBetweenConnectionRequest = ${mbusddelaybetweeneachrequest1}"
		echo "InactivityTimeout = ${mbusdinactivitytimeout1}"
		echo "MaxNumberOfThreads = 2"
		echo "LogLevel = 1"
	} >> "${SerialToTCPTCPcfg}"
}

config_load "$SerialToTCPUcifile"

#config_foreach UpdateSerialToTCP portconfig
UpdateSerialToTCP portconfig1

config_load "$SerialToTCPUcifile"

#config_foreach UpdateTCPClients tcpClient
config_foreach UpdateTCPClients tcpClient_1

echo "noOfClients = ${noOfClients}" >> "${SerialToTCPTCPcfg}"
exit 0
