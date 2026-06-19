#This gets is called in init script.

#!/bin/sh

. /lib/functions.sh

zerotiervpnUCIPath=/etc/config/zerotier                                                  
                                                                                    
ReadzerotiervpnUCIConfig() {                                                            
    config_load "$zerotiervpnUCIPath"                                                   
    config_foreach zerotiervpnConfigParameters zerotier                                  
} 
                                                                                  
zerotiervpnConfigParameters() {                                                         
    local zerotiervpnConfigSection="$1"                                                 
    config_get Name "$zerotiervpnConfigSection" name
    config_get Secret "$zerotiervpnConfigSection" secret  

#first 10 digits of secret.
node_id=$(echo $Secret | grep -o '^.\{10\}')
                                                                                                                                  
uci set zerotier.$Name.nodeid=$node_id                                                                                        

}
                                                                                                  
ReadzerotiervpnUCIConfig

uci commit zerotier
logger -t config -p customs.info "zerotier configuration changed"
logger -t zerotier -p customs.info "Zerotier Configuration updated successfully"
