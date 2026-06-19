#!/bin/sh

. /lib/functions.sh

greconfigfile="/etc/config/greconfig"
Enablegre=$(uci get vpnconfig1.general.enablegre)

Status_Gre() {
    greread="$1"
    config_get peertunnelIP "$greread" peertunnelIP
    config_get Tunnelname "$greread" tunnelname
    config_get peertunnelIPv6 "$greread" peertunnelIPv6
    config_get modes "$greread" modes

    if [ "$Enablegre" = "1" ]; then
        echo "Enablegre is enabled"
        if [ -n "$peertunnelIP" ] || [ -n "$peertunnelIPv6" ]; then

            ping_output_ipv4=$(ping -w 4 "$peertunnelIP" 2>&1)
            ping_output_ipv6=$(ping6 -w 4 "$peertunnelIPv6" 2>&1)

            if [ "$modes" = "IPV4" ]; then
                packet_loss=$(echo "$ping_output_ipv4" | awk '/packet loss/ {print $7}')
            else
                packet_loss=$(echo "$ping_output_ipv6" | awk '/packet loss/ {print $7}')
            fi

            if [ "$packet_loss" = "0%" ]; then
                uci set greconfig."$Tunnelname".status="UP"
                uci commit greconfig  
            elif [ "$packet_loss" = "100%" ];  then
                uci set greconfig."$Tunnelname".status="DOWN"
                uci commit greconfig  
            fi
        fi
    else 
       uci set greconfig."$Tunnelname".status="DOWN"                           
       uci commit greconfig 
    fi
}

config_load "$greconfigfile"
config_foreach Status_Gre greconfig

exit 0

