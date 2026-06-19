#!/bin/sh
. /lib/functions.sh

mkdir -p /reap/disk/AppData/Securico
mkdir -p /reap/disk/AppData/Securico/Upgrade
mkdir -p /reap/disk/AppData/Securico/Upgrade/ManualUpgradeLog

#
# Defaults
#
DLPath="/tmp"
FirmwareInfoFile="${DLPath}/firmwareinfo.txt"
IPKInfoFile="${DLPath}/ipkinfo.txt"
ManualUpgradeLogDir="/reap/disk/AppData/Securico"
ManualUpgradeLogDirCheck="/reap/disk/AppData/Securico/Upgrade"
ManualUpgradeLogDirCheckFinal="/reap/disk/AppData/Securico/Upgrade/ManualUpgradeLog"
ManualUpgradeLog="${ManualUpgradeLogDirCheckFinal}/ManualUpgradeLog.txt"
AutoUpgradeExecLogConfig="/etc/logrotate.d/UpgradeLogrotateConfig"
RebootScript="/root/usrRPC/script/Board_Recycle_12V_Script.sh"

#
# Untarring Downloaded File
#

Hostnm=$(uci get system.system.ipkname)
EnableWifi=$(uci get system.system.enablewifi)
EnableGps=$(uci get system.system.enablegps)

UntarUpgrade()
{
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
			ModuleFirmware="${Hostnm}_EC200A_Upgrade.tar.gz"
		 else
			ModuleFirmware="${Hostnm}_EC200A_WIFI_Upgrade.tar.gz"
		 fi
	else
	  echo "unknown module type"
	fi
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
    
    RemoteIPKVer=$(sed -n 4p $IPKInfoFile)
    #RemoteIPKVer=$(echo $line | cut -d "_" -f3 | cut -d "-" -f1)
    
    LocalIPKVersion=$(echo "$InstalledIPKVersion" | awk -F'.' '{ printf("%d%03d\n", $1,$2); }')
    RemoteIPKVersion=$(echo "$RemoteIPKVer" | awk -F'.' '{ printf("%d%03d\n", $1,$2); }')
    
    if [ "$LocalIPKVersion" -gt "$RemoteIPKVersion" ]
    then
        echo "installed IPK version is newer than IPK version available on server"
        return 2
    elif [ "$LocalIPKVersion" -eq "$RemoteIPKVersion" ]
    then
        echo "installed IPK version is identical to IPK version available on server"
        return 1
    else
        echo "installed IPK version is older than IPK version available on server"
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
		echo "ManualUpgrade Successfull" > /reap/disk/AppData/Securico/Upgrade/ManualUpgradeLog/WebInfoFile
		rm -r /etc/backupconfig/
		$RebootScript &
	fi 
fi


exit 0
