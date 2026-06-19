#!/bin/sh

. /lib/functions.sh

wireguardUCIPath=/etc/config/wireguard

ReadwireguardUCIConfig() {
    config_load "$wireguardUCIPath"
    config_foreach wireguardConfigParameters wireguard
}

wireguardConfigParameters() {
    local wireguardConfigSection="$1"
    config_get Name "$wireguardConfigSection" name
    config_get Role "$wireguardConfigSection" role
    config_get Public "$wireguardConfigSection" public_key

#"Role" == "client"
if [ "$Role" == "CLIENT" ] && [ -z "$Public" ]; then

    private_key=$(wg genkey)
    echo "$private_key" > /tmp/wgclient.key

    public_key=$(echo "$private_key" | wg pubkey)
    echo "$public_key" > /tmp/wgclient.pub

    client_pub_key=$(cat /tmp/wgclient.pub)                
    echo "client Public Key: $client_pub_key"            
    
    client_private_key=$(cat /tmp/wgclient.key)           
    echo "client Public Key: $client_private_key"    
    
    uci set wireguard.$Name.public_key=$client_pub_key     
                                                           
    uci set wireguard.$Name.private_key=$client_private_key



    #echo "The add list of IP  address is $ipaddress" 
fi

#"Role" == "server"
if [ "$Role" == "SERVER" ] && [ -z "$Public" ]; then     

    private_key=$(wg genkey)
    echo "$private_key" > /tmp/wgserver.key

    public_key=$(echo "$private_key" | wg pubkey)
    echo "$public_key" > /tmp/wgserver.pub

    server_pub_key=$(cat /tmp/wgserver.pub)
    echo "Server Public Key: $server_pub_key"

    server_private_key=$(cat /tmp/wgserver.key)               
    echo "Server Public Key: $server_private_key"

    uci set wireguard.$Name.public_key=$server_pub_key     
                                                  
    uci set wireguard.$Name.private_key=$server_private_key

   #echo "The add list of IP  address is $IPAddress"

fi
} 

ReadwireguardUCIConfig 

uci commit wireguard
logger -t config -p customs.info "wireguard configuration changed"

