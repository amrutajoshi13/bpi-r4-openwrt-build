#!/bin/sh

. /lib/functions.sh

Routing_Config="/etc/config/routingconfig"

##ipcal_Script inbuild Openwrt script ##
ipcal="/rom/bin/ipcalc.sh"

ReadRoutingConfig() {
    config_load "$Routing_Config"
    config_foreach Advanced_Custom_Rules rule
    config_foreach Static_RoutingConfig routes
    config_foreach Static_Routingipv6_Config route6
}

Static_RoutingConfig() {

    local RoutingConfigSection="$1"
    
    config_get  Interface  "$RoutingConfigSection" interface
    config_get  Target  "$RoutingConfigSection" target
    config_get  Ipv4netmask  "$RoutingConfigSection" ipv4netmask
    config_get  Metric  "$RoutingConfigSection" metric
    config_get  Ipv4gateway  "$RoutingConfigSection" ipv4gateway
    config_get  Routetype  "$RoutingConfigSection" routetype
    config_get  Tableid  "$RoutingConfigSection" tableid
    config_get  Name "$RoutingConfigSection" name
    

    # var=$($ipcal $Target $Ipv4netmask)
    # Static_Network_prefix=$(echo \"$var\  | awk -F' |=' '/NETWORK=/{network=$2} /PREFIX=/{prefix=$10} END{print network "/" prefix}')

	section_type="route"     # or "rule" — set this based on the context (route or rule)

	# Set common fields
	uci set network.$Name="$section_type"
	uci set network.$Name.name="$Name"

	# Set optional fields if available
	[ -n "$Interface" ] && uci set network.$Name.interface="$Interface"
	[ -n "$Routetype" ] && uci set network.$Name.type="$Routetype"
	[ -n "$Tableid" ] &&  uci set network.$Name.table="$Tableid"
	[ -n "$Target" ] && uci set network.$Name.target="$Target"
    [ -n "$Ipv4netmask" ] && uci set network.$Name.netmask="$Ipv4netmask"
	[ -n "$Ipv4gateway" ] && uci set network.$Name.gateway="$Ipv4gateway"
	[ -n "$Metric" ] && uci set network.$Name.metric="$Metric"

	# Commit network
	uci commit network

}

Static_Routingipv6_Config() {

    local RoutingConfigSection="$1"
    
    config_get  Interface  "$RoutingConfigSection" interface
    config_get  Target  "$RoutingConfigSection" target
    config_get  Ipv6prefix  "$RoutingConfigSection" ipv6prefix
    config_get  Metric  "$RoutingConfigSection" metric
    config_get  Ipv6gateway  "$RoutingConfigSection" ipv6gateway
    config_get  Routetype  "$RoutingConfigSection" routetype
    #config_get  Tableid  "$RoutingConfigSection" tableid
    config_get  Name "$RoutingConfigSection" name
    

    

	section_type="route6"     # or "rule" — set this based on the context (route or rule)

	# Set common fields
	uci set network.$Name="$section_type"
	uci set network.$Name.name="$Name"

	# Set optional fields if available
	[ -n "$Interface" ] && uci set network.$Name.interface="$Interface"
	[ -n "$Routetype" ] && uci set network.$Name.type="$Routetype"
	[ -n "$Target" ] && uci set network.$Name.target="$Target/$Ipv6prefix"
    #[ -n "$Ipv6prefix" ] && uci set network.$Name.netmask="$Ipv6prefix"
	[ -n "$Ipv6gateway" ] && uci set network.$Name.gateway="$Ipv6gateway"
	[ -n "$Metric" ] && uci set network.$Name.metric="$Metric"

	# Commit network
	uci commit network

}

Advanced_Custom_Rules() {
    local RoutingConfigSection="$1"

    # Fetch values from config
    config_get Ruletype "$RoutingConfigSection" ruletype
    config_get To "$RoutingConfigSection" to
    config_get From "$RoutingConfigSection" from
    config_get Netmask "$RoutingConfigSection" ipv4netmask
    config_get Table "$RoutingConfigSection" table
    config_get Priority "$RoutingConfigSection" priority
    config_get Enable_iif "$RoutingConfigSection" enable_iif
    config_get Interface_iif "$RoutingConfigSection" interface_iif
    config_get Enable_oif "$RoutingConfigSection" enable_oif
    config_get Interface_oif "$RoutingConfigSection" interface_oif
    config_get Enable_fwmark "$RoutingConfigSection" enable_fwmark
    config_get Hex_fwmark "$RoutingConfigSection" Hex_fwmark
    config_get Name "$RoutingConfigSection" name

    # Generate CIDR from IP and Netmask (e.g., 192.168.1.0 + 255.255.255.0 → 192.168.1.0/24)

    var=$($ipcal $To $Netmask)
    Advanced_Static_Network_prefix=$(echo \"$var\  | awk -F' |=' '/NETWORK=/{network=$2} /PREFIX=/{prefix=$10} END{print network "/" prefix}')

    echo The value of static netmask is $Advanced_Static_Network_prefix

    # uci section creation
    section_type="rule"
    uci set network."$Name"="$section_type"
    uci set network."$Name".name="$Name"

    # Set values if present
    [ -n "$Ruletype" ] && [ "$Ruletype" != "unicast" ] uci set network."$Name".action="$Ruletype"
    [ -n "$From" ] && uci set network."$Name".src="$From"
    [ -n "$Advanced_Static_Network_prefix" ] && uci set network."$Name".dest="$Advanced_Static_Network_prefix"
    [ -n "$Table" ] &&  uci set network."$Name".lookup="$Table"
    [ -n "$Priority" ] && uci set network."$Name".priority="$Priority"

    # Set optional fields only if enabled
    [ "$Enable_iif" = "1" ] && [ -n "$Interface_iif" ] && uci set network."$Name".in="$Interface_iif"
    [ "$Enable_oif" = "1" ] && [ -n "$Interface_oif" ] && uci set network."$Name".out="$Interface_oif"
    [ "$Enable_fwmark" = "1" ] && [ -n "$Hex_fwmark" ] && uci set network."$Name".mark="$Hex_fwmark"

    # Commit Network
    uci commit network

}

ReadRoutingConfig

ubus call network reload
