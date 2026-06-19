#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

ADCUtilityConfig="/etc/config/ADCUtilityConfigGeneric"
adcutilityconfigsection="adcutilityconfig"
CONFIG_FILE="/root/ADCUtilityComponent/etc/Config/ADCUtilityConfig.cfg"

# Load the configuration
config_load "$ADCUtilityConfig"
config_get CurDevResistance_1 "$adcutilityconfigsection" CurDevResistance_1
config_get CurDevResistance_2 "$adcutilityconfigsection" CurDevResistance_2
config_get CurDevResistance_3 "$adcutilityconfigsection" CurDevResistance_3
config_get CurDevResistance_4 "$adcutilityconfigsection" CurDevResistance_4

# Update the configuration file
sed -i '/^CurDevResistance_1=/d' "$CONFIG_FILE"
sed -i '/^CurDevResistance_2=/d' "$CONFIG_FILE"
sed -i '/^CurDevResistance_3=/d' "$CONFIG_FILE"
sed -i '/^CurDevResistance_4=/d' "$CONFIG_FILE"

{
    echo "CurDevResistance_1=$CurDevResistance_1"
    echo "CurDevResistance_2=$CurDevResistance_2"
    echo "CurDevResistance_3=$CurDevResistance_3"
    echo "CurDevResistance_4=$CurDevResistance_4"
} >> "$CONFIG_FILE"
