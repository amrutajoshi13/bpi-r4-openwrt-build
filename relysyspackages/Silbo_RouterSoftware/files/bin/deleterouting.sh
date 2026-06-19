#!/bin/sh

. /lib/functions.sh

Routingpath="/etc/config/routingconfig"

ipcal="/rom/bin/ipcalc.sh"


ReadRoutingConfig()
{
    config_load "$Routingpath"
    config_foreach RoutingConfigParameters routes
    config_foreach RoutingConfigParameters1 rule
}

RoutingConfigParameters()
{
    local RoutingConfigSection="$1"
    config_get iface "$RoutingConfigSection" interface
    config_get destination "$RoutingConfigSection" target
    config_get Genmask "$RoutingConfigSection" ipv4netmask
    config_get Metric "$RoutingConfigSection" metric
    config_get Gateway "$RoutingConfigSection" ipv4gateway

var=$($ipcal $destination $Genmask)
network_prefix=$(echo \"$var\ | awk -F' |=' '/NETWORK=/{network=$2} /PREFIX=/{prefix=$10} END{print network "/" prefix}')
	
####syntax of ip route delete command#### 

        ip route delete $network_prefix via $Gateway dev $iface table main metric $Metric 
}

RoutingConfigParameters1()
{
    local RoutingConfigSection="$1"
    config_get iface "$RoutingConfigSection" interface
    config_get dest "$RoutingConfigSection" to
    config_get source "$RoutingConfigSection" from
    config_get netmask "$RoutingConfigSection" ipv4netmask
    config_get table "$RoutingConfigSection" table
    config_get priority "$RoutingConfigSection" priority

var1=$($ipcal $dest $netmask)                                                
network_prefix1=$(echo \"$var1\ | awk -F' |=' '/NETWORK=/{network=$2} /PREFIX=/{prefix=$10} END{print network "/" prefix}')


var=$source                                                                      
                                                          
if [[ -z  $var ]]                                                                             
then                                                                                          
     ip rule delete to $network_prefix1 iif $iface lookup $table  priority $priority
else                                 
                                                                                                                         
     ip rule delete from $source to $network_prefix1 iif $iface lookup $table  priority $priority
fi                                    

}

ReadRoutingConfig
 
