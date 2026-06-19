#!/bin/sh

. /lib/functions.sh

routingconfigfile="/etc/config/routingconfig"


DeleteroutingConfig()
{

	local RoutingConfigSection="$1"

	config_get Name "$RoutingConfigSection" name

    uci delete network.$Name

    uci commit network

}

config_load "$routingconfigfile" 
config_foreach DeleteroutingConfig routes
config_foreach DeleteroutingConfig rule

ubus call network reload 

exit 0

