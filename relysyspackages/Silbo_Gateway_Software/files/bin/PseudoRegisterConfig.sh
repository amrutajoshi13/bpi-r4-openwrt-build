#!/bin/sh
. /lib/functions.sh

# Configuration paths
RS485DeviceCfgDirPath="/root/EnergyMeterAppComponent/etc/Config"
PseudoConfigCfgPath="${RS485DeviceCfgDirPath}/PseudoDeviceConfig"
PseudoConfigFile="PseudoRegisterconfig"
RegisterConfigFile="registerconfig"
PseudoParamConfigFile="pseudoParamconfig"
DeviceConfigGeneric="DeviceConfigGeneric"
slavedatasendingenable=$(uci get cloudconfig.cloudconfig.slaveDataSending)

# Remove existing config file to start fresh
rm -f "${PseudoConfigCfgPath}.cfg"
NoOfDeviceCount=0
ORDER_FILE="/tmp/ordered_sections.txt"
rm -f "$ORDER_FILE"

# Collect sections from pseudoParamconfig in correct order
collect_sections() {
    local section="$1"
    echo "$section" >> "$ORDER_FILE"  # Store section order
}

# Process PseudoRegisterconfig in collected order
process_ordered_pseudo_config() {
    while read -r section; do
        process_pseudo_config "$section"
    done < "$ORDER_FILE"
}

process_pseudo_config() {
    local section="$1"
    NoOfDeviceCount=$((NoOfDeviceCount + 1))
    local cfg_index=1  # Reset cfg_index for each new device

    write_pseudo_device_config "$NoOfDeviceCount" "$section"
    echo "section in process_pseudo_config : $section"
    config_load "$PseudoConfigFile"
    local i=0
    while :; do
        config_get PseudoRegisterName "$section" "pseudoRegisterName_${i}"
        config_get RegisterName "$section" "pseudoSlaveRegister_${i}"
        config_get SlaveId "$section" "SlaveId_${i}"

        echo "PseudoRegisterName : $PseudoRegisterName"
        echo "RegisterName : $RegisterName"
        echo "SlaveId : $SlaveId"

        # Stop only if all three values are empty
        if [ -z "$PseudoRegisterName" ] && [ -z "$RegisterName" ] && [ -z "$SlaveId" ]; then
            break
        fi
        
        SlaveIdextracted=$(echo "$SlaveId" | awk -F'_' '{print $NF}')
        echo "Physical_SlaveID_${NoOfDeviceCount}_${cfg_index}=${SlaveIdextracted}" >> "${PseudoConfigCfgPath}.cfg"

        compare_register_names "$PseudoRegisterName" "$RegisterName" "$NoOfDeviceCount" "$cfg_index" "$SlaveId"

        cfg_index=$((cfg_index + 1))
        i=$((i + 1))
    done
}

write_pseudo_device_config() {
    local NoOfDeviceCount="$1"
    local section="$2"

    {
        echo ""
        echo "# Pseudo Device $NoOfDeviceCount"
        echo "EnergyMeterType_${NoOfDeviceCount}=0"
        echo "Model_${NoOfDeviceCount}=\"Pseudo${NoOfDeviceCount}\""
        echo "Baudrate_${NoOfDeviceCount}=999999"
        echo "Parity_${NoOfDeviceCount}=9"
        echo "Databits_${NoOfDeviceCount}=9"
        echo "Stopbits_${NoOfDeviceCount}=9"
        echo "InterfaceID_${NoOfDeviceCount}=3"
        echo "MeterID_${NoOfDeviceCount}=99"
        echo "SerialPort_${NoOfDeviceCount}=\"/dev/ttyPseudo\""
        echo "stdModbusEnable_${NoOfDeviceCount}=9"
        echo "CommType_${NoOfDeviceCount}=1"
        echo "CommIP_${NoOfDeviceCount}=\"0.0.0.0\""
        echo "CommPort_${NoOfDeviceCount}=0"
        echo "CommTimeout_${NoOfDeviceCount}=0"
    } >> "${PseudoConfigCfgPath}.cfg"
}

compare_register_names() {
    local PseudoRegisterName="$1"
    local RegisterName="$2"
    local NoOfDeviceCount="$3"
    local cfg_index="$4"
    local SlaveId="$5"

    config_load "$RegisterConfigFile"
    config_foreach compare_in_registerconfig registerconfig "$PseudoRegisterName" "$RegisterName" "$NoOfDeviceCount" "$cfg_index" "$SlaveId"
}

compare_in_registerconfig() {
    local section="$1"
    local PseudoRegisterName="$2"
    local RegisterName="$3"
    local NoOfDeviceCount="$4"
    local cfg_index="$5"
    local SlaveIdr="$6"

    SlaveId=$(echo "$SlaveIdr" | awk -F'_' '{print $NF}')

    local j=0
    while true; do
        local registername=$(uci get "${RegisterConfigFile}.${section}.registername_$j" 2>/dev/null)
        local serialslaveid=$(uci get "${DeviceConfigGeneric}.${section}.serialslaveid" 2>/dev/null)

        if [ -z "$registername" ]; then
            break
        fi

        if [ "$RegisterName" = "$registername" ] && [ "$SlaveId" = "$serialslaveid" ]; then
            local startregister=$(uci get "${RegisterConfigFile}.${section}.startregister_$j" 2>/dev/null)
            local registercount=$(uci get "${RegisterConfigFile}.${section}.registercount_$j" 2>/dev/null)
            local Datatype=$(uci get "${RegisterConfigFile}.${section}.Datatype_$j" 2>/dev/null)
            local Multiplier=$(uci get "${RegisterConfigFile}.${section}.multifactor_$j" 2>/dev/null)

            [ -z "$Multiplier" ] && Multiplier=1.0

            {
                echo "Key_${NoOfDeviceCount}_${cfg_index}=\"$PseudoRegisterName\""
                echo "SelectRegister_${NoOfDeviceCount}_${cfg_index}=$startregister"
                echo "RegisterCount_${NoOfDeviceCount}_${cfg_index}=$registercount"
                echo "DataType_${NoOfDeviceCount}_${cfg_index}=$Datatype"
                echo "Multiplier_${NoOfDeviceCount}_${cfg_index}=$Multiplier"
                echo "PseudoEnable_${NoOfDeviceCount}_${cfg_index}=$slavedatasendingenable"
            } >> "${PseudoConfigCfgPath}.cfg"

            cfg_index=$((cfg_index + 1))
        fi

        j=$((j + 1))
    done
}

UpdatePseudoConfig() {
    rm -f "$ORDER_FILE"
    config_load "$PseudoParamConfigFile"
    config_foreach collect_sections pseudoConfig
    process_ordered_pseudo_config
}

ReadPseudoParamConfig() {
    config_load "$PseudoParamConfigFile"
    config_foreach process_pseudo_param_config pseudoConfig
}

process_pseudo_param_config() {
    local section1="$1"
    NoOfDeviceCount=$((NoOfDeviceCount + 1))

    config_get pseudoDeviceName "$section1" "pseudoDeviceName"
    config_get pseudoSlaveID "$section1" "pseudoSlaveID"
    config_get pseudoregisterlen "$section1" "pseudoregisterlen"

    {
        echo ""
        echo "# Pseudo Device Params for Device $NoOfDeviceCount"
        echo "DeviceName_${NoOfDeviceCount}=\"$pseudoDeviceName\""
        echo "SlaveID_${NoOfDeviceCount}=$pseudoSlaveID"
        echo "NumberOfRegisterMaps_${NoOfDeviceCount}=$pseudoregisterlen"
    } >> "${PseudoConfigCfgPath}.cfg"
}

UpdatePseudoConfig
NoOfDeviceCount=0
ReadPseudoParamConfig

{
    echo ""
    echo "# Number of meters to read"
    echo "NoOfDevices=$NoOfDeviceCount"
    echo "NoOfEMetersInLine3=$NoOfDeviceCount"
    echo "NoOfUniqueEMetersInLine3=$NoOfDeviceCount"
    echo "MaxNoOfRetries=3"
    echo "SleepRetries=10"
} >> "${PseudoConfigCfgPath}.cfg"
