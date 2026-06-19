#!/bin/sh
. /lib/functions.sh


MacConfigFile="/etc/config/macconfig"

ReadMacConfigFile()
{
        config_load "$MacConfigFile"
        config_foreach UpdateMacConfigindhcp macconfig
}


UpdateMacConfigindhcp()
{
	local FirewallConfigSection="$1"
    NoOfSectionCount=$((NoOfSectionCount + 1))
    echo "NoOfSectionCount is $NoOfSectionCount"

    config_get DeviceName "$FirewallConfigSection" name
    config_get MacAddress "$FirewallConfigSection" macaddress
    config_get IPAddress "$FirewallConfigSection" ipaddress
    
	uci set dhcp.$NoOfSectionCount=host
	uci set dhcp.$NoOfSectionCount.name=$DeviceName
	uci set dhcp.$NoOfSectionCount.mac=$MacAddress
	uci set dhcp.$NoOfSectionCount.ip=$IPAddress
	uci commit dhcp
}

RestartInitScript()
{
	/etc/init.d/dnsmasq restart
}


MacConfigFile="/etc/config/macconfig"

ReadMacConfigFile
UpdateMacConfigindhcp
RestartInitScript
 
 
exit 0
