#!/bin/sh

. /lib/functions.sh

vrrpdUCIPath=/etc/config/vrrpd
EnableVRRP=$(uci get vrrpd.general.enablevrrpd)

ReadvrrpdUCIConfig() {
    config_load "$vrrpdUCIPath"
    config_foreach vrrpdConfigParameters vrrpd
}

vrrpdConfigParameters() {
    local vrrpdConfigSection="$1"
    NoOfSectionCount=$((NoOfSectionCount + 1))

    config_get name "$vrrpdConfigSection" name
    config_get Enable "$vrrpdConfigSection" enable
    config_get state "$vrrpdConfigSection" state
    config_get virtual_router_id "$vrrpdConfigSection" virtual_router_id
    config_get priority "$vrrpdConfigSection" priority
    config_get unicast_src_ip "$vrrpdConfigSection" unicast_src_ip
    config_get interface "$vrrpdConfigSection" interface
    config_get unicast_peer "$vrrpdConfigSection" unicast_peer
    config_get virtual_ipaddress "$vrrpdConfigSection" virtual_ipaddress
    config_get authentication "$vrrpdConfigSection" authentication
    config_get password "$vrrpdConfigSection" password
    config_get track_interface "$vrrpdConfigSection" track_interface

if [ "$Enable" = "0" ] || [ "$EnableVRRP" = "0" ]; then
    exit 1
fi


if [ "$authentication" == "1" ]; then
    auth_type="PASS"
    fi
    

    lan=$(uci get networkinterfaces.${interface}.ifname)


    # Generate the vrrpd instance configuration string
    config_string=$(
        cat <<EOF
vrrp_instance VI_$NoOfSectionCount {
    state $state
    interface $lan
    virtual_router_id $virtual_router_id
    priority $priority
    advert_int 1
    unicast_src_ip $unicast_src_ip
    unicast_peer {
        $unicast_peer
    }
    authentication {
        auth_type $auth_type
        auth_pass $password
    }
    virtual_ipaddress {
        $virtual_ipaddress
    }
    track_interface {
        $lan
    }
}
EOF
    )

    # Append the configuration string to the output file
    echo "$config_string" >>"$OUTPUT_FILE"
if [ "$authentication" == "0" ]; then 
        auth=$(grep -w "auth_type" "$OUTPUT_FILE")     
        auth_replace=" "                                                
        sed -i "s/${auth}/${auth_replace}/" "$OUTPUT_FILE"              
                                                          
        password=$(grep -w "auth_pass" "$OUTPUT_FILE")                 
        password_replace=" "                                            
        sed -i "s/${password}/${password_replace}/" "$OUTPUT_FILE"
fi
   
}

# Path to the output file
OUTPUT_FILE="/etc/keepalived/keepalived.conf"

# Initialize the output file
echo "" >"$OUTPUT_FILE"

# Read and process the configuration
ReadvrrpdUCIConfig

# Notify the user
echo "vrrpd instance configuration has been written to $OUTPUT_FILE"

sleep 3

/etc/init.d/keepalived restart  
