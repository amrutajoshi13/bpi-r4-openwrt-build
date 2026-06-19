#!/bin/sh


mkdir -p /reap/disk/AppData/Gateway
mkdir -p /reap/disk/AppData/Gateway/Upgrade
mkdir -p /reap/disk/AppData/Gateway/Upgrade/AutoUpgradeLog

#
# Defaults
#

DLPath="/tmp"
UpgradeManagerGeneric="/etc/config/UpgradeManagerGeneric"
AutoUpgradeExecLogConfig="/etc/logrotate.d/UpgradeLogrotateConfig"
AutoUpgradeLogDir="/reap/disk/AppData/Gateway"
AutoUpgradeLogDirCheck="/reap/disk/AppData/Gateway/Upgrade"
AutoUpgradeLogDirCheckFinal="/reap/disk/AppData/Gateway/Upgrade/AutoUpgradeLog"
AutoUpgradeLog="${AutoUpgradeLogDirCheckFinal}/AutoUpgradeLog.txt"
RebootScript="/root/usrRPC/script/Board_Recycle_12V_Script.sh"
AutoUpgradeFilesPath="/etc/AutoUpgradeFilesPath.cfg"
BoardconfigFile="/etc/config/boardconfig"
DownloadedIPKInfoFile="ipkinfo.txt"
DownloadedFirmwareInfoFile="firmwareinfo.txt"
DownloadedFirmwareInfoFileTCPSlave="TCPSlavefirmwareinfo.txt"
LogrotateConfigFile="/etc/logrotate.d/AutoUpgradeLogRotateConfig"
#Hostnm=$(uci get system.system.ipkname)
#EnableWifi=$(uci get system.system.enablewifi)
#EnableGps=$(uci get system.system.enablegps)

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

if [ -d "$AutoUpgradeLogDir" ]
then
	if [ ! -d "$AutoUpgradeLogDirCheck" ]
	then
		mkdir -p "$AutoUpgradeLogDirCheck"
	fi
	if [ ! -d "$AutoUpgradeLogDirCheckFinal" ]
	then
		mkdir -p "$AutoUpgradeLogDirCheckFinal"
	fi
fi

ReadConfigurations()
{
    
    AutoUpgradeEnable=$(uci get UpgradeManagerGeneric.global.enable 2>&1)
    Authentication=$(uci get UpgradeManagerGeneric.global.authentication 2>&1)
    User=$(uci get UpgradeManagerGeneric.global.user 2>&1)
    Password=$(uci get UpgradeManagerGeneric.global.password 2>&1)
    FirmwareURL=$(uci get UpgradeManagerGeneric.global.url 2>&1)
    ConnectTimeout=$(uci get UpgradeManagerGeneric.global.connectiontimeout 2>&1)
    OperationTimeout=$(uci get UpgradeManagerGeneric.global.operationtimeout 2>&1)
   
    [ "$AutoUpgradeEnable" != "1" ] && return 1

    return 0
}


#
# set options for curl utility
#
SetCurlOptions() {
    WriteOutFormatOption='--write-out "ResponseCode=%{response_code}"'
    QuietModeOption="--silent"
    ShowErrorOption="--show-error"

    CurlOptions="$WriteOutFormatOption $QuietModeOption $ShowErrorOption"

    if [ "$Authentication" = "1" ]; then
        if [ -n "$User" ] && [ -n "$Password" ]; then
            # Quote the combined user:password safely with single quotes for eval
            CurlAuth="-u '$User:$Password'"
        fi
    fi

    [ -n "$ConnectTimeout" ] && CurlTimeouts="--connect-timeout $ConnectTimeout"
    [ -n "$OperationTimeout" ] && CurlTimeouts="$CurlTimeouts --max-time $OperationTimeout"

    CurlOptions="$CurlOptions $CurlTimeouts"
    [ -n "$CurlAuth" ] && CurlOptions="$CurlOptions $CurlAuth"
}

DownloadtarFile()
{
    Tmpurl=$(echo "$FirmwareURL" | sed 's/\/$//')
    ModuleType=$(uci get boardconfig.board.moduletype 2>&1)

    FirmwareServerURL="${Tmpurl}"
    ModuleFirmware="Upgrade.tar.gz"
    ModuleFirmwareDownloadPath="${DLPath}/${ModuleFirmware}"

    # Use eval to preserve quotes around special characters
    ResponseMsg=$(eval curl -o "$ModuleFirmwareDownloadPath" $CurlOptions "$FirmwareServerURL" 2>&1)

    ResponseCode=$(echo "$ResponseMsg" | awk -F"=" '/ResponseCode/{print $2}' | tr -d '"')
    printf "ResponseMsg=%s\nResponseCode=%s\n" "$ResponseMsg" "$ResponseCode" >> "$AutoUpgradeLog"

    [ ! -s "$ModuleFirmwareDownloadPath" ] && return 1
    return 0
}



#
# Untarring Downloaded File
#

UntarUpgrade()
{
	
	tar -xvf "${DLPath}/${ModuleFirmware}" -C "${DLPath}" 2>&1
	unret=$?
	if [ "$unret" == 0 ]
	then
	    #rm -f "${DLPath}/${ModuleFirmware}"
		echo "Untar Successful"
	else
		echo "Unable to Untar the Upgrade file"
		return 1
	fi
	return 0
}

#
# Check wheather upgrade is needed 
#

VerifyIPKUpgrade()
{
    #
    
    IPKInfo=$(uci get boardconfig.board.GWApplicationSwVer 2>&1)

	InstalledIPKVersion="$IPKInfo"
    
    RemoteIPKVer=$(sed -n 4p $DLPath/$DownloadedIPKInfoFile)
    RemoteIPKName=$(sed -n 3p $DLPath/$DownloadedIPKInfoFile)
    
    LocalIPKVersion=$(echo "$InstalledIPKVersion" | awk -F'.' '{ printf("%d%03d\n", $1,$2); }')
    RemoteIPKVersion=$(echo "$RemoteIPKVer" | awk -F'.' '{ printf("%d%03d\n", $1,$2); }')
    
    if [ "$LocalIPKVersion" -gt "$RemoteIPKVersion" ]
    then
        echo "installed IPK version is newer than IPK version available on server" >> "$AutoUpgradeLog"
        return 2
    elif [ "$LocalIPKVersion" -eq "$RemoteIPKVersion" ]
    then
        echo "installed IPK version is identical to IPK version available on server" >> "$AutoUpgradeLog"
        return 1
    else
        echo "installed IPK version is older than IPK version available on server" >> "$AutoUpgradeLog"
    fi
    
    return 0
}


VerifyFirmwareUpgrade()
{
    #
    
    FirmwareInfo=$(uci get boardconfig.board.GWApplicationSwVer 2>&1)

	InstalledFirmwareVersion="$FirmwareInfo"
    
    RemoteFirmwareVer=$(sed -n 4p $DLPath/$DownloadedFirmwareInfoFile)
    RemoteFirmwareName=$(sed -n 3p $DLPath/$DownloadedFirmwareInfoFile)
    
    LocalFirmwareVersion=$(echo "$InstalledFirmwareVersion" | awk -F'.' '{ printf("%d%03d\n", $1,$2); }')
    RemoteFirmwareVersion=$(echo "$RemoteFirmwareVer" | awk -F'.' '{ printf("%d%03d\n", $1,$2); }')
    
    if [ "$LocalFirmwareVersion" -gt "$RemoteFirmwareVersion" ]
    then
        echo "installed Firmware version is newer than Firmware version available on server" >> "$AutoUpgradeLog"
      
        return 2
    elif [ "$LocalFirmwareVersion" -eq "$RemoteFirmwareVersion" ]
    then
        echo "installed Firmware version is identical to Firmware version available on server" >> "$AutoUpgradeLog"
       
        return 1
    else
        echo "installed Firmware version is older than Firmware version available on server" >> "$AutoUpgradeLog"
    fi
        
    return 0
}


VerifyFirmwareUpgradeTCPSlave()
{
    #
    
    FirmwareInfoTCPSlave=$(uci get boardconfig.board.TCPSlaveApplicationSwVer 2>&1)

	InstalledFirmwareVersionTCPSlave="$FirmwareInfoTCPSlave"
    
    RemoteFirmwareVerTCPSlave=$(sed -n 4p $DLPath/$DownloadedFirmwareInfoFileTCPSlave)
    RemoteFirmwareNameTCPSlave=$(sed -n 3p $DLPath/$DownloadedFirmwareInfoFileTCPSlave)
    
    LocalFirmwareVersionTCPSlave=$(echo "$InstalledFirmwareVersionTCPSlave" | awk -F'.' '{ printf("%d%03d\n", $1,$2); }')
    RemoteFirmwareVersionTCPSlave=$(echo "$RemoteFirmwareVerTCPSlave" | awk -F'.' '{ printf("%d%03d\n", $1,$2); }')
    
    if [ "$LocalFirmwareVersionTCPSlave" -gt "$RemoteFirmwareVersionTCPSlave" ]
    then
        echo "installed TCP Slave Firmware version is newer than Firmware version available on server" >> "$AutoUpgradeLog"
      
        return 2
    elif [ "$LocalFirmwareVersionTCPSlave" -eq "$RemoteFirmwareVersionTCPSlave" ]
    then
        echo "installed TCP Slave Firmware version is identical to Firmware version available on server" >> "$AutoUpgradeLog"
       
        return 1
    else
        echo "installed TCP Slave Firmware version is older than Firmware version available on server" >> "$AutoUpgradeLog"
    fi
        
    return 0
}
#
# Run Smart Script
#

RunSmartScript()
{
	Exe="$DLPath/SmartScript_${RemoteIPKVersion}.sh"
	chmod 777 "$Exe" 2>&1
	$Exe
	Runret=$?
    return $Runret
}

StartUp()
{
	echo "[$(date +"%Y-%m-%d %H:%M:%S")] : AutoUpgradeLog" >> "$AutoUpgradeLog"
    
    #
    ReadConfigurations
    ReadConfigurationsRetVal=$?
    if [ "$ReadConfigurationsRetVal" != 0 ]
    then
        echo "AutoUpgradeStatus=Auto Upgrade disabled" >> "$AutoUpgradeLog"
        echo "[$(date +"%Y-%m-%d %H:%M:%S")] : Auto Upgrade disabled" >> "$AutoUpgradeExecLog"
        return 1
    fi
	
	SetCurlOptions 
	
}

#
# Update Software Version
#
UpdateVersion()
{
	Ipkversion=$(opkg list | grep -i RouterSoftware | tr -d ' ' | awk -F'-' '{print $2}')
	uci set boardconfig.board.ApplicationSwVer="$Ipkversion" 2>&1
	uci commit boardconfig
	return 0
}

UpdateFirmwareVersion()
{
	Firmwareversion=$(opkg list | grep -i Silbo_Gateway_Software | tr -d ' ' | awk -F'-' '{print $2}')
	GWFirmwareVer=$(uci get boardconfig.board.GWFirmwareVer)
	uci set boardconfig.board.GWApplicationSwVer="$Firmwareversion" 2>&1
	uci set softwareversion.softwareversion.softwareversion="$Ipkversion" 2>&1
	uci set softwareversion.softwareversion.cweversion="\"$GWFirmwareVer\"" 2>&1
	uci commit boardconfig
	uci commit softwareversion
	
	return 0
}

UpdateFirmwareVersionTCPSlave()
{
	FirmwareversionTCPSlave=$(opkg list | grep -i ModbusTCPSlave | tr -d ' ' | awk -F'-' '{print $2}')
	TCPSlaveFirmwareVer=$(uci get boardconfig.board.TCPSlaveFirmwareVer)
	uci set boardconfig.board.TCPSlaveApplicationSwVer="$FirmwareversionTCPSlave" 2>&1
	uci commit boardconfig
		
	return 0
}

#Backup_Gateway_Config()
#{
    ##mv /etc/config/ADCUtilityConfigGeneric /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/DiagnosticIOUtilities /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/portconfig /Web_Page_Gateway_Apps/Backup_Gateway              
	##mv /etc/config/RS485UtilityConfigGeneric /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/analoginputconfig /Web_Page_Gateway_Apps/Backup_Gateway       
	##mv /etc/config/digitalinputconfig /Web_Page_Gateway_Apps/Backup_Gateway        
	##mv /etc/config/RS232DeviceConfigGeneric /Web_Page_Gateway_Apps/Backup_Gateway  
	###mv /etc/config/softwareversion /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/cloudconfig /Web_Page_Gateway_Apps/Backup_Gateway           
	##mv /etc/config/FixedPacketConfigGeneric /Web_Page_Gateway_Apps/Backup_Gateway 
	##mv /etc/config/RS232UtilityConfigGeneric /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/sourceconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/command /Web_Page_Gateway_Apps/Backup_Gateway               
	##mv /etc/config/importexportgatewayconfig /Web_Page_Gateway_Apps/Backup_Gateway  
	###mv /etc/config/RS485DeviceConfigGeneric /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/temperatureconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/applist_config /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/UpgradeManagerGeneric /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/BLControlSensorEventsActions /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/DeviceConfigGeneric /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/Jsonconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/registerconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/blockconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/alarmconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/cloudconfigGeneric /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/PseudoCloudconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/pseudoParamconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/PseudoRegisterconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/Storageconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/applicationoverviewconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/watchdogconfigsw /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/eventConfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/config/applicationdeletedatabaseconfig /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/mbusdconfig.conf /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/mbusdconfig2.conf /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /etc/ser2net.conf /Web_Page_Gateway_Apps/Backup_Gateway
    ##mv /root/exclude.txt /Web_Page_Gateway_Apps/Backup_Gateway
    ##mv /root/include.txt /Web_Page_Gateway_Apps/Backup_Gateway
    ##mv /etc/crontabs/root /Web_Page_Gateway_Apps/Backup_Gateway
    
    
    #mv /etc/mbusdconfig.conf /Web_Page_Gateway_Apps/Default_Gateway/etc/
	#mv /etc/mbusdconfig2.conf /Web_Page_Gateway_Apps/Default_Gateway/etc/
	#mv /etc/ser2net.conf /Web_Page_Gateway_Apps/Default_Gateway/etc/
	#mv /etc/crontabs/root /Web_Page_Gateway_Apps/Default_Gateway/etc/crontabs
	
	#mv /root/ADCUtilityComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/ADCUtilityComponent/etc/Config
	#mv /root/ApaasAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/ApaasAppComponent/etc/Config
	#mv /root/AzureAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/AzureAppComponent/etc/Config
	#mv /root/BLControlAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/BLControlAppComponent/etc/Config
	#mv /root/CmdProcessorAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/CmdProcessorAppComponent/etc/Config
	#mv /root/DIUtilityIndividualTestComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DIUtilityIndividualTestComponent/etc/Config
	#mv /root/DOUtilityIndividualTestComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/DataCollectorAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/EnergyMeterAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/FixedPacketAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/JSONParametersAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/RS232ReadAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/RS232UtilityComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/RS485UtilityComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/ReadAIAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/ReadAllTemperatureSensorsUtilityComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/ReadDIAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/ReadSingleTemperatureSensorUtilityComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/ReadTemperatureSensorAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/RequestGeneratorAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/SenderAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/SoftwareVersionComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/SourceAppComponent/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	#mv /root/rtumd/etc/Config/* /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
	
#}


Backup_Gateway_Config_TCPSlave()
{
	mv /etc/config/tcpconfig /Web_Page_Gateway_Apps/Backup_Gateway
}


#Restore_Gateway_Config()
#{
    ##mv /Web_Page_Gateway_Apps/Backup_Gateway/ADCUtilityConfigGeneric /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/DiagnosticIOUtilities /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/portconfig /etc/config             
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/RS485UtilityConfigGeneric /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/analoginputconfig /etc/config     
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/digitalinputconfig /etc/config        
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/RS232DeviceConfigGeneric /etc/config  
	###mv /etc/config/softwareversion /Web_Page_Gateway_Apps/Backup_Gateway
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/cloudconfig /etc/config           
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/FixedPacketConfigGeneric /etc/config 
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/RS232UtilityConfigGeneric /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/sourceconfig /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/command /etc/config              
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/importexportgatewayconfig /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/RS485DeviceConfigGeneric /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/temperatureconfig /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/applist_config /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/UpgradeManagerGeneric /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/BLControlSensorEventsActions /etc/config/
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/DeviceConfigGeneric /etc/config/ 
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/Jsonconfig /etc/config/
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/registerconfig /etc/config/
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/blockconfig /etc/config/
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/alarmconfig /etc/config/
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/cloudconfigGeneric /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/PseudoCloudconfig /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/pseudoParamconfig /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/PseudoRegisterconfig /etc/config
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/Storageconfig /etc/config/ 
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/applicationoverviewconfig /etc/config/ 
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/watchdogconfigsw /etc/config/ 
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/eventConfig /etc/config/ 
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/applicationdeletedatabaseconfig /etc/config/ 
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/mbusdconfig.conf /etc/
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/mbusdconfig2.conf /etc/
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/ser2net.conf  /etc/
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/exclude.txt /root
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/include.txt /root
	##mv /Web_Page_Gateway_Apps/Backup_Gateway/root /etc/crontabs/ 
    
    ##/bin/UpdateConfigurationsGateway ucitoappcfg 2>&1
    ##/bin/UpdateCalibValues.sh 2>&1
    
    
    #mv /etc/mbusdconfig.conf /Web_Page_Gateway_Apps/Default_Gateway/etc/
	#mv /etc/mbusdconfig2.conf /Web_Page_Gateway_Apps/Default_Gateway/etc/
	#mv /etc/ser2net.conf /Web_Page_Gateway_Apps/Default_Gateway/etc/
	#mv /etc/crontabs/root /Web_Page_Gateway_Apps/Default_Gateway/etc/crontabs
	
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/ADCUtilityComponent/etc/Config/* /root/ADCUtilityComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/ApaasAppComponent/etc/Config/* /root/ApaasAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/AzureAppComponent/etc/Config/* /root/AzureAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/BLControlAppComponent/etc/Config/* /root/BLControlAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/CmdProcessorAppComponent/etc/Config/* /root/CmdProcessorAppComponent/etc/Config/ 
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DIUtilityIndividualTestComponent/etc/Config/* /root/DIUtilityIndividualTestComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/DOUtilityIndividualTestComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/DataCollectorAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/EnergyMeterAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/FixedPacketAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/JSONParametersAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/RS232ReadAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/RS232UtilityComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/RS485UtilityComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/ReadAIAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/ReadAllTemperatureSensorsUtilityComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/ReadDIAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/ReadSingleTemperatureSensorUtilityComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/ReadTemperatureSensorAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/RequestGeneratorAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/SenderAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/SoftwareVersionComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/SourceAppComponent/etc/Config/
	#mv /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/* /root/rtumd/etc/Config/

#}

Restore_Gateway_Config_TCPSlave()
{
	mv /Web_Page_Gateway_Apps/Backup_Gateway/tcpconfig /etc/config
}

############### Main Code ##################

StartUp
StartUpRetVal=$?
if [ "$StartUpRetVal" != "0" ] 
then
	exit $StartUpRetVal
fi

DownloadtarFile
DownloadtarFileRetVal=$?
if [ "$DownloadtarFileRetVal" != "0" ] 
then
	echo "Download Fail"
	exit 0
fi

UntarUpgrade
UntarUpgradeRetVal=$?
if [ "$UntarUpgradeRetVal" != "0" ] 
then
	echo "Unable to Untar"
	exit 0
fi

################# IPK (Platform related) Upgrade ########################################

#if [ ! -s $DLPath/$DownloadedIPKInfoFile ]
    #then
        #echo "DownloadedFirmwareInfoFile does not exists" >> "$AutoUpgradeLog"
        #RetVal=1
#else     
     #VerifyIPKUpgrade
	 #VerifyIPKUpgradeRetVal=$?
	#if [ "$VerifyIPKUpgradeRetVal" == "1" ] ||  [ "$VerifyIPKUpgradeRetVal" == "2" ]
	#then
		#exit 0
	#elif [ "$VerifyIPKUpgradeRetVal" == "0" ]
	#then
	   #p=$(pidof iSenseApp)                                     
       #kill -9 $p
       #mv /home/guest/iSenseApp /tmp
       ##/etc/init.d/cron stop
      ## /etc/init.d/monit stop
     ## /bin/sed '/check.sh/d' /etc/crontabs/root
     ## /etc/init.d/cron restart
       ##sed -e "${line}d" /etc/crontabs/root
	   #RunSmartScript
	   #ReturnVal=$?
	#fi
	
	##if [ "$ReturnVal" == 1 ]
	##then
		###UpdateVersion
		###UpdateVersionRet=$?
		###if [ "$UpdateVersionRet" == 0 ]
		###then
			###rm -r /etc/backupconfig/
			####$RebootScript &
		###fi 
	##fi
	
#fi

####################### Firmware (Gateway Application Upgrade) ############################################

	 

if [ ! -s $DLPath/$DownloadedFirmwareInfoFile ]
    then
        echo "DownloadedFirmwareInfoFile does not exists" >> "$AutoUpgradeLog"
        RetVal=1
else     
     VerifyFirmwareUpgrade
	 VerifyFirmwareUpgradeRetVal=$?
	if [ "$VerifyFirmwareUpgradeRetVal" == "1" ] ||  [ "$VerifyFirmwareUpgradeRetVal" == "2" ]
	then
		exit 0
	elif [ "$VerifyFirmwareUpgradeRetVal" == "0" ]
	then
	 /bin/mount tmpfs /tmp -t tmpfs -o remount,size=15000k,nosuid,nodev
	    sh /etc/init.d/GD44AppManager stop
	    /etc/init.d/sms3 stop
	    killall -9 owfs
	     
	     #Take Backup of configuration
	    # Backup_Gateway_Config
	    
	    sh /bin/defaultbackupRestoreGateway.sh 1
	     
	    opkg remove Silbo_Gateway_Software
		
		OpkginstallFirmwareOutput=$(opkg --force-overwrite install $DLPath/$RemoteFirmwareName 2>&1)
        OpkginstallFirmwareOutputRetVal=$?
	    if [ "$OpkginstallFirmwareOutputRetVal" != 0 ]
	    then
			Firmwarevalue=1
			echo "Error in Installing Firmware" >> "$AutoUpgradeLog"
	    else
	       	Firmwarevalue=0	
		fi
	    
	    if [ $Firmwarevalue = "0" ]
	    then
			echo "Success Installing Firmware" >> "$AutoUpgradeLog"
			
			
		else
		  
		   	return 1
	    fi
		FirmwareReturnVal=$?
	fi
	
	
fi


#############################################################################################

####################### Firmware TCP Slave  ############################################
	 

if [ ! -s $DLPath/$DownloadedFirmwareInfoFileTCPSlave ]
    then
        echo "DownloadedFirmwareInfoFileTCPSlave does not exists" >> "$AutoUpgradeLog"
        RetValTCPSlave=1
else     
     VerifyFirmwareUpgradeTCPSlave
	 VerifyFirmwareUpgradeRetValTCPSlave=$?
	if [ "$VerifyFirmwareUpgradeRetValTCPSlave" == "1" ] ||  [ "$VerifyFirmwareUpgradeRetValTCPSlave" == "2" ]
	then
		exit 0
	elif [ "$VerifyFirmwareUpgradeRetValTCPSlave" == "0" ]
	then
	 /bin/mount tmpfs /tmp -t tmpfs -o remount,size=15000k,nosuid,nodev
	    
	   
	    killall -9 TCP_Slave_Utility_project
	     
	     #Take Backup of configuration
	     Backup_Gateway_Config_TCPSlave
	     
	    opkg remove ModbusTCPSlave
		
		OpkginstallFirmwareOutputTCPSlave=$(opkg --force-overwrite install $DLPath/$RemoteFirmwareNameTCPSlave 2>&1)
        OpkginstallFirmwareOutputRetValTCPSlave=$?
	    if [ "$OpkginstallFirmwareOutputRetValTCPSlave" != 0 ]
	    then
			FirmwarevalueTCPSlave=1
			echo "Error in Installing Firmware TCPSlave " >> "$AutoUpgradeLog"
	    else
	       	FirmwarevalueTCPSlave=0	
		fi
	    
	    if [ $FirmwarevalueTCPSlave = "0" ]
	    then
			echo "Success Installing Firmware" >> "$AutoUpgradeLog"
			
			
		else
		  
		   	return 1
	    fi
		FirmwareReturnValTCPSlave=$?
	fi
	
	
fi

if [ ! -s $DLPath/$DownloadedFirmwareInfoFile ]
then
     echo "Firmware info File doesn't exists"
else
     
	#Restore_Gateway_Config
	sh /bin/defaultbackupRestoreGateway.sh 2
	UpdateVersion
	UpdateFirmwareVersion
fi	

if [ ! -s $DLPath/$DownloadedFirmwareInfoFileTCPSlave ]
then
     echo "TCP slave info File doesn't exists"
else
	Restore_Gateway_Config_TCPSlave
	UpdateFirmwareVersionTCPSlave
fi

sleep 5

#uci set applist_config.appconfig.running="1"
#uci commit applist_config

chmod -R 777 /www

if [ "$UpdateVersionRet" == 0 ] || [ "$FirmwareReturnVal" == 0 ] || [ "$FirmwareReturnValTCPSlave" == 0 ]
then
		$RebootScript &		
fi

	
logrotate "$LogrotateConfigFile"
exit 0

