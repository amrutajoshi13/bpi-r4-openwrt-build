#!/bin/sh
 
. /lib/functions.sh
 
Routingpath="/etc/config/routingconfig"
 
ipcal="/rom/bin/ipcalc.sh"
 
del="/root/InterfaceManager/script/features/routing/delete.sh"
chmod 700 /root/InterfaceManager/script/features/routing/delete.sh
DEL=$($del)
 
 
ReadRoutingConfig()
{
    config_load "$Routingpath"
    config_foreach RoutingConfigParameters routes
    config_foreach RoutingConfigParameters1 rule
    config_foreach RoutingConfigParameters2 table
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
 
####Syntax of ip route add command####
echo ip route delete $network_prefix via $Gateway dev $iface table main metric $Metric
ip route add $network_prefix via $Gateway dev $iface table main metric $Metric
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
 
     ip rule add to $network_prefix1 lookup $table  priority $priority
    echo ip rule delete to $network_prefix1 lookup $table  priority $priority
 
}
 
RoutingConfigParameters2()
{
    local RoutingConfigSection="$1"
    config_get Tableid "$RoutingConfigSection" tableid
    config_get TableName "$RoutingConfigSection" name
    config_get destination "$RoutingConfigSection" target
    config_get Genmask "$RoutingConfigSection" ipv4netmask
    config_get Metric "$RoutingConfigSection" metric
    config_get Gateway "$RoutingConfigSection" ipv4gateway
 
var2=$($ipcal $destination $Genmask)                                                
network_prefix2=$(echo \"$var2\ | awk -F' |=' '/NETWORK=/{network=$2} /PREFIX=/{prefix=$10} END{print network "/" prefix}')
 
echo ip route delete $network_prefix2 via $Gateway table $Tableid metric $Metric
 
ip route add $network_prefix2 via $Gateway table $Tableid metric $Metric
 
#echo ip route delete $network_prefix2 via $Gateway $TableName $Tableid metric $Metric
 
}
 
ReadRoutingConfig > /root/InterfaceManager/script/features/routing/delete.sh
