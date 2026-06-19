#!/bin/sh

action="$1"

echo "action : $action"

# Create directory if not exists
create_dir()
{
    dest_path="$1"

    if [ ! -d "$dest_path" ]; then
        mkdir -p "$dest_path"
        chmod -R 777 "$dest_path"
    fi
}

# Set full permission
set_full_permission()
{
    path="$1"

    if [ -e "$path" ]; then
        chmod -R 777 "$path"
    fi
}

# Safe copy function
safe_cp()
{
    src="$1"
    dest="$2"

    create_dir "$dest"

    if ls $src >/dev/null 2>&1; then
        cp -rf $src "$dest"/
        chmod -R 777 "$dest"
    fi
}

# Safe move function
safe_mv()
{
    src="$1"
    dest="$2"

    create_dir "$dest"

    if ls $src >/dev/null 2>&1; then
        mv $src "$dest"/
        chmod -R 777 "$dest"
    fi
}

UpdateDefaultConfigGateway()
{
    safe_cp /etc/config/RS232DeviceConfigGeneric /Web_Page_Gateway_Apps/Default_Gateway/config
    safe_cp /etc/config/RS232UtilityConfigGeneric /Web_Page_Gateway_Apps/Default_Gateway/config
    safe_cp /etc/config/applist_config /Web_Page_Gateway_Apps/Default_Gateway/config

    safe_cp /etc/mbusdconfig.conf /Web_Page_Gateway_Apps/Default_Gateway/etc
    safe_cp /etc/mbusdconfig2.conf /Web_Page_Gateway_Apps/Default_Gateway/etc
    safe_cp /etc/ser2net.conf /Web_Page_Gateway_Apps/Default_Gateway/etc
    safe_cp /etc/crontabs/root /Web_Page_Gateway_Apps/Default_Gateway/etc/crontabs

    safe_cp "/root/ADCUtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/ADCUtilityComponent/etc/Config
    safe_cp "/root/ApaasAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/ApaasAppComponent/etc/Config
    safe_cp "/root/AzureAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/AzureAppComponent/etc/Config
    safe_cp "/root/BLControlAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/BLControlAppComponent/etc/Config
    safe_cp "/root/CmdProcessorAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/CmdProcessorAppComponent/etc/Config
    safe_cp "/root/DIUtilityIndividualTestComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/DIUtilityIndividualTestComponent/etc/Config
    safe_cp "/root/DOUtilityIndividualTestComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
    safe_cp "/root/DataCollectorAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/DataCollectorAppComponent/etc/Config
    safe_cp "/root/EnergyMeterAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/EnergyMeterAppComponent/etc/Config
    safe_cp "/root/FixedPacketAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/FixedPacketAppComponent/etc/Config
    safe_cp "/root/JSONParametersAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/JSONParametersAppComponent/etc/Config
    safe_cp "/root/RS232ReadAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/RS232ReadAppComponent/etc/Config
    safe_cp "/root/RS232UtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/RS232UtilityComponent/etc/Config
    safe_cp "/root/RS485UtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/RS485UtilityComponent/etc/Config
    safe_cp "/root/ReadAIAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/ReadAIAppComponent/etc/Config
    safe_cp "/root/ReadAllTemperatureSensorsUtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/ReadAllTemperatureSensorsUtilityComponent/etc/Config
    safe_cp "/root/ReadDIAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/ReadDIAppComponent/etc/Config
    safe_cp "/root/ReadSingleTemperatureSensorUtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/ReadSingleTemperatureSensorUtilityComponent/etc/Config
    safe_cp "/root/ReadTemperatureSensorAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/ReadTemperatureSensorAppComponent/etc/Config
    safe_cp "/root/RequestGeneratorAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/RequestGeneratorAppComponent/etc/Config
    safe_cp "/root/SenderAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/SenderAppComponent/etc/Config
    safe_cp "/root/SoftwareVersionComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/SoftwareVersionComponent/etc/Config
    safe_cp "/root/SourceAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/SourceAppComponent/etc/Config
    safe_cp "/root/rtumd/etc/config/*" /Web_Page_Gateway_Apps/Default_Gateway/root/rtumd/etc/config
}

Backup_Gateway_Config()
{
    safe_mv /etc/mbusdconfig.conf /Web_Page_Gateway_Apps/Backup_Gateway/etc
    safe_mv /etc/mbusdconfig2.conf /Web_Page_Gateway_Apps/Backup_Gateway/etc
    safe_mv /etc/ser2net.conf /Web_Page_Gateway_Apps/Backup_Gateway/etc
    safe_mv /etc/crontabs/root /Web_Page_Gateway_Apps/Backup_Gateway/etc/crontabs

    safe_mv "/root/ADCUtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/ADCUtilityComponent/etc/Config
    safe_mv "/root/ApaasAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/ApaasAppComponent/etc/Config
    safe_mv "/root/AzureAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/AzureAppComponent/etc/Config
    safe_mv "/root/BLControlAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/BLControlAppComponent/etc/Config
    safe_mv "/root/CmdProcessorAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/CmdProcessorAppComponent/etc/Config
    safe_mv "/root/DIUtilityIndividualTestComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/DIUtilityIndividualTestComponent/etc/Config
    safe_mv "/root/DOUtilityIndividualTestComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config
    safe_mv "/root/DataCollectorAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/DataCollectorAppComponent/etc/Config
    safe_mv "/root/EnergyMeterAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/EnergyMeterAppComponent/etc/Config
    safe_mv "/root/FixedPacketAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/FixedPacketAppComponent/etc/Config
    safe_mv "/root/JSONParametersAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/JSONParametersAppComponent/etc/Config
    safe_mv "/root/RS232ReadAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/RS232ReadAppComponent/etc/Config
    safe_mv "/root/RS232UtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/RS232UtilityComponent/etc/Config
    safe_mv "/root/RS485UtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/RS485UtilityComponent/etc/Config
    safe_mv "/root/ReadAIAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/ReadAIAppComponent/etc/Config
    safe_mv "/root/ReadAllTemperatureSensorsUtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/ReadAllTemperatureSensorsUtilityComponent/etc/Config
    safe_mv "/root/ReadDIAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/ReadDIAppComponent/etc/Config
    safe_mv "/root/ReadSingleTemperatureSensorUtilityComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/ReadSingleTemperatureSensorUtilityComponent/etc/Config
    safe_mv "/root/ReadTemperatureSensorAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/ReadTemperatureSensorAppComponent/etc/Config
    safe_mv "/root/RequestGeneratorAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/RequestGeneratorAppComponent/etc/Config
    safe_mv "/root/SenderAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/SenderAppComponent/etc/Config
    safe_mv "/root/SoftwareVersionComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/SoftwareVersionComponent/etc/Config
    safe_mv "/root/SourceAppComponent/etc/Config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/SourceAppComponent/etc/Config
    safe_mv "/root/rtumd/etc/config/*" /Web_Page_Gateway_Apps/Backup_Gateway/root/rtumd/etc/config
}

Restore_Gateway_Config()
{
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/ADCUtilityComponent/etc/Config/*" /root/ADCUtilityComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/ApaasAppComponent/etc/Config/*" /root/ApaasAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/AzureAppComponent/etc/Config/*" /root/AzureAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/BLControlAppComponent/etc/Config/*" /root/BLControlAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/CmdProcessorAppComponent/etc/Config/*" /root/CmdProcessorAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/DIUtilityIndividualTestComponent/etc/Config/*" /root/DIUtilityIndividualTestComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/DOUtilityIndividualTestComponent/etc/Config/*" /root/DOUtilityIndividualTestComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/DataCollectorAppComponent/etc/Config/*" /root/DataCollectorAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/EnergyMeterAppComponent/etc/Config/*" /root/EnergyMeterAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/FixedPacketAppComponent/etc/Config/*" /root/FixedPacketAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/JSONParametersAppComponent/etc/Config/*" /root/JSONParametersAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/RS232ReadAppComponent/etc/Config/*" /root/RS232ReadAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/RS232UtilityComponent/etc/Config/*" /root/RS232UtilityComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/RS485UtilityComponent/etc/Config/*" /root/RS485UtilityComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/ReadAIAppComponent/etc/Config/*" /root/ReadAIAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/ReadAllTemperatureSensorsUtilityComponent/etc/Config/*" /root/ReadAllTemperatureSensorsUtilityComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/ReadDIAppComponent/etc/Config/*" /root/ReadDIAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/ReadSingleTemperatureSensorUtilityComponent/etc/Config/*" /root/ReadSingleTemperatureSensorUtilityComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/ReadTemperatureSensorAppComponent/etc/Config/*" /root/ReadTemperatureSensorAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/RequestGeneratorAppComponent/etc/Config/*" /root/RequestGeneratorAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/SenderAppComponent/etc/Config/*" /root/SenderAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/SoftwareVersionComponent/etc/Config/*" /root/SoftwareVersionComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/SourceAppComponent/etc/Config/*" /root/SourceAppComponent/etc/Config
    safe_mv "/Web_Page_Gateway_Apps/Backup_Gateway/root/rtumd/etc/config/*" /root/rtumd/etc/config
}

if [ "$action" = "0" ]; then
    echo "Default Gateway Files"
    UpdateDefaultConfigGateway

elif [ "$action" = "1" ]; then
    echo "Backup Gateway Files"
    Backup_Gateway_Config

elif [ "$action" = "2" ]; then
    echo "Restore Gateway Files"
    Restore_Gateway_Config
fi

# Final permission update
chmod -R 777 /Web_Page_Gateway_Apps 2>/dev/null
chmod -R 777 /root 2>/dev/null
chmod -R 777 /etc/config 2>/dev/null
chmod -R 777 /etc/crontabs 2>/dev/null

exit 0
