#!/bin/sh
. /lib/functions.sh

PptpVpnUCIPath=/etc/config/pptp_i_config                                               
                                                                                    
ReadPptpVpnUCIConfig() {                                                            
    config_load "$PptpVpnUCIPath"                                                   
    config_foreach PptpVpnConfigParameters service                               
}
                                                                                   
PptpVpnConfigParameters() {                                                         
    local PptpVpnConfigSection="$1"                                                 
    config_get Name "$PptpVpnConfigSection" name                                                                                                                                        
    config_get Type "$PptpVpnConfigSection" type  
                                                  
# Live status Updated. That is, shows if tunnel is up/down.                                                  
# Check if the pptp tunnel has been created.                   
                                                                                          
if [ "$Type" == "CLIENT" ]; then
    tunnel_check=$(ifconfig | grep -o "pptp-$Name")
    
    if [ -n "$tunnel_check" ]; then
        Status="UP"
        address=$(ifconfig "pptp-$Name" | awk '/inet / {print $2}' | cut -d: -f2)
    else
        Status="DOWN"
        address=""
        logger -t customs.info -p pptp "Unable to establish the pptp connection"
    fi
    
    uci set pptp_i_config.$Name.status=$Status
    uci set pptp_i_config.$Name.address=$address
fi
                                         
if [ "$Type" == "SERVER" ]; then
    
	for i in 0 1 2 3 4 5 6 7 8 9 10
        do
		tunnel_status=$(ifconfig | grep -o "ppp${i}")
		
		#echo $i
		#echo The value of tunnel_status is : $tunnel_status

        # If the interface is found, set the Status accordingly
        if [ -n "$tunnel_status" ]; then
            Status="UP"
            address=$(ifconfig "ppp${i}" | awk '/inet / {print $2}' | cut -d: -f2)
            break
        else
            Status="DOWN"
            address=""
            logger -t customs.info -p pptp "Unable to establish the pptp connection"
        fi
    done
    
    uci set pptp_i_config.$Name.status=$Status
    uci set pptp_i_config.$Name.address=$address
fi

uci commit pptp_i_config
}
                                                                                                                                                                                                       
ReadPptpVpnUCIConfig
