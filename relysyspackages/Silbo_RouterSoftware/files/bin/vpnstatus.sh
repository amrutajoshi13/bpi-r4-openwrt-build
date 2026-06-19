#!/bin/sh
. /lib/functions.sh

OpenvpnUCIPath=/etc/config/openvpn                                                  
                                                                                    
ReadOpenvpnUCIConfig() {                                                            
    config_load "$OpenvpnUCIPath"                                                   
    config_foreach OpenvpnConfigParameters openvpn1                                  
}
                                                                                   
OpenvpnConfigParameters() {                                                         
    local OpenvpnConfigSection="$1"                                                 
    config_get Name "$OpenvpnConfigSection" name                                    
    config_get Mode "$OpenvpnConfigSection" mode                                                                                                    
                                                                                                    
#Live status Updated#

    status="" # Initialize status variable

    if [ "$Mode" = "TUN" ]; then
        status=$(ifconfig | grep -w "tun_$Name" | cut -d' ' -f1 | cut -d '_' -f2)
        address=$(ifconfig | grep -w "tun_$Name" -A1 | awk '/inet addr/{print $2}' | cut -d: -f2)
    fi
    if [ "$Mode" = "TAP" ]; then
        status=$(ifconfig | grep -w "tap_$Name" | cut -d' ' -f1 | cut -d '_' -f2)
        address=$(ifconfig | grep -w "tap_$Name" -A1 | awk '/inet addr/{print $2}' | cut -d: -f2)

    fi

    if [ -n "$status" ]; then
        Status="UP"
    else
        Status="DOWN"
    fi

                                                                                    
uci set openvpn.$Name.status=$Status

uci set openvpn.$Name.address=$address


}
                                                                                                    
                                                                                                     
ReadOpenvpnUCIConfig

uci commit openvpn

