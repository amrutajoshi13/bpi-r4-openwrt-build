
#!/bin/sh
. /lib/functions.sh
 
MacConfigFile="/etc/config/macconfig"
 
# Function to delete all config host sections in dhcp
delete_all_hosts() {
    while uci show dhcp | grep '=host' > /dev/null; do
        uci delete dhcp.@host[0]
    done
    uci commit dhcp
}
 
ReadMacBindingConfigFile()
{
        config_load "$MacConfigFile"
        config_foreach UpdateMacBindingConfigInDhcp macconfig
}
 
UpdateMacBindingConfigInDhcp()
{
    local MacBindingSection="$1"
    
    #Don't add host in dhcp config if the MacBindingSection is 0.
    if [ -n "$MacBindingSection" ]
    then
        NoOfSectionCount=$((NoOfSectionCount + 1))
        echo "NoOfSectionCount is $NoOfSectionCount" > /dev/null
 
        config_get DeviceName "$MacBindingSection" name
        config_get MacAddress "$MacBindingSection" macaddress
        config_get IPAddress "$MacBindingSection" ipaddress
        
        uci set dhcp.$NoOfSectionCount=host
        uci set dhcp.$NoOfSectionCount.name=$DeviceName
        uci set dhcp.$NoOfSectionCount.mac=$MacAddress
        uci set dhcp.$NoOfSectionCount.ip=$IPAddress
        uci commit dhcp
    fi
}
 
RestartInitScript()
{
    /etc/init.d/dnsmasq restart
}
 
# Delete all existing host sections.
delete_all_hosts
 
#Read macbinding configuration.
ReadMacBindingConfigFile
 
#Update dhcp config file with hosts.
UpdateMacBindingConfigInDhcp
 
#Restart dnsmasq.
RestartInitScript
logger -t config -p customs.info "dhcp configuration changed"
exit 0
