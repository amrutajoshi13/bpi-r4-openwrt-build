#!/bin/sh

. /lib/functions.sh

greconfigfile="/etc/config/greconfig"
enablegre=$(uci get vpnconfig1.general.enablegre)

DeleteGreConfig() {

  greread="$1"
  config_get tunnelname "$greread" tunnelname
    uci delete network.$tunnelname
    uci delete network."$tunnelname"_static
    uci delete network.tunnel_$tunnelname
    uci commit network
}

config_load "$greconfigfile"
config_foreach DeleteGreConfig greconfig

exit 0
