#!/bin/sh


mkdir -p /reap/disk/AppData/Securico
mkdir -p /reap/disk/AppData/Securico/Upgrade
mkdir -p /reap/disk/AppData/Securico/Upgrade/AutoUpgradeLog

#
# Defaults
#

DLPath="/tmp"
UpgradeManagerGeneric="/etc/config/UpgradeManagerGeneric"
AutoUpgradeExecLogConfig="/etc/logrotate.d/UpgradeLogrotateConfig"
AutoUpgradeLogDir="/reap/disk/AppData/Securico"
AutoUpgradeLogDirCheck="/reap/disk/AppData/Securico/Upgrade"
AutoUpgradeLogDirCheckFinal="/reap/disk/AppData/Securico/Upgrade/AutoUpgradeLog"
AutoUpgradeLog="${AutoUpgradeLogDirCheckFinal}/AutoUpgradeLog.txt"
RebootScript="/root/usrRPC/script/Board_Recycle_12V_Script.sh"
AutoUpgradeFilesPath="/etc/AutoUpgradeFilesPath.cfg"
BoardconfigFile="/etc/config/boardconfig"
DownloadedIPKInfoFile="${DLPath}/ipkinfo.txt"

Hostnm=$(uci get system.system.ipkname)
EnableWifi=$(uci get system.system.enablewifi)
EnableGps=$(uci get system.system.enablegps)

ReadConfigurations()
{
    UpgradeManagerGeneric
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

SetCurlOptions()
{
	
    WriteOutFormatOption="--write-out \"ResponseCode=%{response_code}\""
    QuietModeOption="--silent"
    ShowErrorOption="--show-error"

    CurlOptions="$WriteOutFormatOption $QuietModeOption $ShowErrorOption"
    
    if [ "$Authentication" = "1" ]
    then
       [ "x$User" != "x" ] && [ "x$Password" != "x" ] && CurlOptions="$CurlOptions -u $User:$Password"
    fi

    [ "x$ConnectTimeout" != "x" ] &&  CurlOptions="$CurlOptions --connect-timeout $ConnectTimeout"
    [ "x$OperationTimeout" != "x" ] &&  CurlOptions="$CurlOptions --max-time $OperationTimeout"

    return 0
}

DownloadtarFile()
{
    Tmpurl=$(echo "$FirmwareURL" | sed 's/\/$//')
    #~ Path=$(awk -F'"' '/path/{print $2}' ${AutoUpgradeFilesPath} 2>&1)
    #~ Tmpurl="${Tmpurl}/${Path}"
    ModuleType=$(uci get boardconfig.board.moduletype 2>&1)
    
    if [ "$ModuleType" == 1 ] || [ "$ModuleType" == 2 ]
    then
     if [ "$EnableWifi" = "0" ]
     then
		ModuleFirmware="${Hostnm}_EC200T_Upgrade.tar.gz"
	 else
	    ModuleFirmware="${Hostnm}_EC200T_WIFI_Upgrade.tar.gz"
	 fi
	elif [ "$ModuleType" == 3 ] || [ "$ModuleType" == 4 ]
	then
	  if [ "$EnableGps" = "0" ] || [ "$EnableWifi" = "0" ]
	  then
		ModuleFirmware="${Hostnm}_EC20_Upgrade.tar.gz"
	  elif [ "$EnableGps" = "1" ] || [ "$EnableWifi" = "0" ]
	  then
	    ModuleFirmware="${Hostnm}_EC20_GPS_Upgrade.tar.gz"
	  elif [ "$EnableGps" = "0" ] || [ "$EnableWifi" = "1" ]
	  then
	    ModuleFirmware="${Hostnm}_EC20_WIFI_Upgrade.tar.gz"
	  else
	    ModuleFirmware="${Hostnm}_EC20_GPS_WIFI_Upgrade.tar.gz"
	  fi
	elif [ "$ModuleType" == 8 ] || [ "$ModuleType" == 9 ]
	then
	     if [ "$EnableWifi" = "0" ]
		 then
			ModuleFirmware="SilboRC44_RouterSoftwareEC200A_WIFI_Upgrade.tar.gz"
		 else
			ModuleFirmware="SilboRC44_RouterSoftwareEC200A_WIFI_Upgrade.tar.gz"
		 fi
	else
	  echo "unknown module type"
	fi
	FirmwareServerURL="${Tmpurl}/${ModuleFirmware}"
	ModuleFirmwareDownloadPath="${DLPath}/${ModuleFirmware}"
    ResponseMsg=$(curl -o "$ModuleFirmwareDownloadPath" $CurlOptions "$FirmwareServerURL" 2>&1)
    ResponseCode=$(echo "$ResponseMsg" | awk -F"=" '/ResponseCode/{print $2}')
    ResponseCode=$(echo "$ResponseCode" | tr -d '"')
    printf "ResponseMsg=%s\nResponseCode=%s\n" "$ResponseMsg" "$ResponseCode" >> "$AutoUpgradeLog"
    [ ! -s "$ModuleFirmwareDownloadPath" ] && return 1
    
    
    return 0
}

#
# Untarring Downloaded File
#

UntarUpgrade()
{
	tar -zxv -f "${DLPath}/${ModuleFirmware}" -C "${DLPath}" 2>&1
	unret=$?
	if [ "$unret" == 0 ]
	then
	    rm -f "${DLPath}/${ModuleFirmware}"
		echo "Untarring Successful"
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
    
    IPKInfo=$(uci get boardconfig.board.ApplicationSwVer 2>&1)

	InstalledIPKVersion="$IPKInfo"
    
    RemoteIPKVer=$(sed -n 4p $DownloadedIPKInfoFile)
    #RemoteIPKVer=$(echo $line | cut -d "_" -f3 | cut -d "-" -f1)
    
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

#
# Run Smart Script
#

RunSmartScript()
{
	Exe="/tmp/SmartScript_${RemoteIPKVersion}.sh"
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
	uci set boardconfig.board.ApplicationSwVer="$RemoteIPKVer" 2>&1
	uci commit boardconfig
	return 0
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

VerifyIPKUpgrade
VerifyIPKUpgradeRetVal=$?
if [ "$VerifyIPKUpgradeRetVal" == "1" ] ||  [ "$VerifyIPKUpgradeRetVal" == "2" ]
then
	exit 0
elif [ "$VerifyIPKUpgradeRetVal" == "0" ]
then
	RunSmartScript
	ReturnVal=$?
fi

if [ "$ReturnVal" == 1 ]
then
	UpdateVersion
	UpdateVersionRet=$?
	if [ "$UpdateVersionRet" == 0 ]
	then
		rm -r /etc/backupconfig/
		$RebootScript &
	fi 
fi


exit 0

