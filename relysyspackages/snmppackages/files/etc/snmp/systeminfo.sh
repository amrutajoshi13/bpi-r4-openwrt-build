#!/bin/sh

# Use awk to extract the value after the equals sign and remove leading whitespace
deviceModel=$(uci get boardconfig.board.model)
deviceSerialNum=$(uci get boardconfig.board.serialnum)
deviceHWVer=Rev-$(echo $deviceSerialNum | cut -c3)
deviceBatchNumber=$(echo $deviceSerialNum | cut -c4-7)
#Check deviceRouterFirmware is there or not...
device_FirmwareVer=$(uci get boardconfig.board.FirmwareVer)
device_ApplicationSwVer=$(uci get boardconfig.board.ApplicationSwVer)
deviceRouterFirmware=$(echo ${device_FirmwareVer}_${device_ApplicationSwVer})
if [ -z "$deviceRouterFirmware" ] || [ "$deviceRouterFirmware" == "_" ]; then
    deviceRouterFirmware="NA"
fi
#Check deviceGatewayFirmware is there or not...
device_GWFirmwareVer=$(uci get boardconfig.board.GWFirmwareVer)
device_GWApplicationSwVer=$(uci get boardconfig.board.GWApplicationSwVer)
deviceGatewayFirmware=$(echo ${device_GWFirmwareVer}_${device_GWApplicationSwVer})
if [ -z "$deviceGatewayFirmware" ] || [ "$deviceGatewayFirmware" == "_" ]; then
    deviceGatewayFirmware="NA"
fi
deviceUptime=
deviceTemperature=
deviceNoofModem=
deviceInternetStatus=
deviceConfiguredWANInterfaceName=
deviceActiveWANInterfaceName=
deviceActiveWANInterfaceStatus=
deviceActiveWANIP=
deviceActiveWANInternetUptime=
deviceEWANInternetStatus=
deviceCellularOperationMode=

store_systeminfo() {
    {
        echo "deviceModel=$deviceModel"
        echo "deviceSerialNum=$deviceSerialNum"
        echo "deviceHWVer=$deviceHWVer"
        echo "deviceBatchNumber=$deviceBatchNumber"
        echo "deviceRouterFirmware=$deviceRouterFirmware"
        echo "deviceGatewayFirmware=$deviceGatewayFirmware"
        echo "deviceUptime=$deviceUptime"
        echo "deviceTemperature=$deviceTemperature"
        echo "deviceNoofModem=$deviceNoofModem"
        echo "deviceInternetStatus=$deviceInternetStatus"
        echo "deviceConfiguredWANInterfaceName=$deviceConfiguredWANInterfaceName"
        echo "deviceActiveWANInterfaceName=$deviceActiveWANInterfaceName"
        echo "deviceActiveWANInterfaceStatus=$deviceActiveWANInterfaceStatus"
        echo "deviceActiveWANIP=$deviceActiveWANIP"
        echo "deviceActiveWANInternetUptime=$deviceActiveWANInternetUptime"
        echo "deviceEWANInternetStatus=$deviceEWANInternetStatus"
        echo "deviceCellularOperationMode=$deviceCellularOperationMode"
    } | tr -d '\r' > /etc/snmp/system_info.txt
}

store_systeminfo
