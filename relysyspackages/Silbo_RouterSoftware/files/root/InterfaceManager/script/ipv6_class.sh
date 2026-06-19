#!/bin/sh

. /lib/functions.sh

NetworkvpnUCIPath="/etc/config/networkinterfaces"

ReadNetworkUCIConfig() {
    config_load "$NetworkvpnUCIPath"
    config_foreach NetworkConfigParameters redirect
}

NetworkConfigParameters() {
    local NetworkConfigSection="$1"
    config_get Interfaces "$NetworkConfigSection" interface
    config_get ipv6prefixclass "$NetworkConfigSection" ipv6prefixclass
    config_get ifname "$NetworkConfigSection" ifname
    config_get ipmodelan "$NetworkConfigSection" ipmodelan

if [[ "$ipmodelan" = "IPV4+IPV6" ]]; then
    uci set network.$ipv6prefixclass.clientlan=$ifname
   fi
}

ReadNetworkUCIConfig

uci commit network 


