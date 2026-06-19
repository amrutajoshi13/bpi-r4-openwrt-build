#!/bin/sh

. /lib/functions.sh

OpenvpnUCIPath=/etc/config/openvpn

EnableOpenvpn=$(uci get vpnconfig1.general.enableopenvpngeneral)

##Delete wireguard names for Client from the network file.###
Bridge="/root/InterfaceManager/script/vpn/openvpn/bridge.sh"
chmod 700 /root/InterfaceManager/script/vpn/openvpn/bridge.sh

#Run the "/root/InterfaceManager/script/vpn/wireguard/ucidelete2.sh" which deletes the names from the network file.
var = $($Bridge)

#Delete the ucidelete2.sh and then create a new one for every update button pressed.
rm /root/InterfaceManager/script/vpn/openvpn/bridge.sh

ReadOpenvpnUCIConfig() {
    config_load "$OpenvpnUCIPath"
    config_foreach OpenvpnConfigParameters openvpn1
    config_foreach OpenvpnConfig_CCD openvpn1
}

OpenvpnConfigParameters() {
    local OpenvpnConfigSection="$1"
    config_get Name "$OpenvpnConfigSection" name
    config_get Enable "$OpenvpnConfigSection" enable
    config_get Mode "$OpenvpnConfigSection" mode
    config_get Bridge "$OpenvpnConfigSection" bridge
    config_get Interface "$OpenvpnConfigSection" interface

     if [ "$EnableOpenvpn" = "1" ]; then
    
        uci set firewall.openvpn=zone
        uci set firewall.openvpn.name="tun"
        uci set firewall.openvpn.input="ACCEPT"
        uci set firewall.openvpn.output="ACCEPT"
        uci set firewall.openvpn.forward="ACCEPT"
        uci set firewall.openvpn.network="tun"
        uci set firewall.openvpn.device="tun+"
        uci set firewall.openvpn.masq="1"
        uci set firewall.openvpn.mtu_fix="1"

        echo uci delete firewall.openvpn

      lanCount=$(cat /etc/internetoverlan.txt | wc -l)
        for k in $(seq 1 ${lanCount}); do
                lan=$(cat /etc/internetoverlan.txt | head -${k} | tail -1)

                uci set firewall.src${lan}_vpn="forwarding"
                uci set firewall.src${lan}_vpn.src="tun"
                uci set firewall.src${lan}_vpn.dest=${lan}

                uci set firewall.des${lan}_vpn="forwarding"
                uci set firewall.des${lan}_vpn.src=${lan}
                uci set firewall.des${lan}_vpn.dest="tun"

                echo uci delete firewall.src${lan}_vpn
                echo uci delete firewall.des${lan}_vpn

        done
        
        uci commit firewall 

        echo uci commit firewall 

    fi


    #Check the generalopenvpn && Opnvpn Enable
    if [ "$Enable" = "1" ] && [ "$EnableOpenvpn" = "1" ]; then

        if [ "$Mode" = "TUN" ]; then

            if [ "$Bridge" == "1" ]; then
                uci set openvpn.$Name.bridge="0"
                uci commit openvpn
            fi
        fi

        if [ "$Mode" = "TAP" ]; then
            #Get ifname.
            ifname=$(uci get networkinterfaces.$Interface.ifname)

            if [ "$Bridge" == "1" ]; then

                #Get Bridge.sh File
                echo uci delete network.$Interface.type
                echo uci delete network.$Interface.ifname
                echo uci commit network
                echo sleep 1

                enable_bridge=$(uci get networkinterfaces.$Interface.enable_bridge)

                if [ "$enable_bridge" = "1" ]; then
                    bridge_interfaces=$(uci get networkinterfaces.$Interface.bridge_interfaces)
                    echo uci set network.$Interface.type='bridge'
                    echo uci set network.$Interface.ifname="'$ifname $bridge_interfaces'"
                fi

                uci set network.$Interface.type='bridge'
                uci set network.$Interface.ifname="$ifname $bridge_interfaces tap_$Name"

            else
                enable_bridge=$(uci get networkinterfaces.$Interface.enable_bridge)

                if [ "$enable_bridge" = "1" ]; then
                    bridge_interfaces=$(uci get networkinterfaces.$Interface.bridge_interfaces)
                    uci set network.$Interface.type='bridge'
                    uci set network.$Interface.ifname="$ifname $bridge_interfaces"

                    echo uci set network.$Interface.type='bridge'
                    echo uci set network.$Interface.ifname="'$ifname $bridge_interfaces'"
                else
                    uci delete network.$Interface.type
                    echo uci set network.$Interface.ifname="$ifname"
                fi
            fi
        fi
    else
        ifname=$(uci get networkinterfaces.$Interface.ifname)
        enable_bridge=$(uci get networkinterfaces.$Interface.enable_bridge)

        if [ "$enable_bridge" = "1" ]; then
            bridge_interfaces=$(uci get networkinterfaces.$Interface.bridge_interfaces)
            uci set network.$Interface.type='bridge'
            uci set network.$Interface.ifname="$ifname $bridge_interfaces"

            echo uci set network.$Interface.type='bridge'
            echo uci set network.$Interface.ifname="'$ifname $bridge_interfaces'"
        else
            uci delete network.$Interface.type
            uci set network.$Interface.ifname="$ifname"

            echo uci set network.$Interface.ifname="$ifname"
        fi
    fi

    uci commit network
    echo uci commit network

    #/etc/init.d/network restart
    ubus call network reload
    echo ubus call network reload
    #Firewall reload 
    /etc/init.d/firewall reload > /dev/null 2>&1 

}

OpenvpnConfig_CCD() {
    local OpenvpnConfigSection="$1"
    config_get Name "$OpenvpnConfigSection" name
    config_get Enable "$OpenvpnConfigSection" enable
    config_get Role1 "$OpenvpnConfigSection" role1
    config_get Iroute_name "$OpenvpnConfigSection" iroute_name
    config_get Iroute_name1 "$OpenvpnConfigSection" iroute_name1
    config_get Iroute_Addresses1 "$OpenvpnConfigSection" iroute_address1
    config_get Iroute_Netmask1 "$OpenvpnConfigSection" iroute_netmask1
    config_get Iroute_name2 "$OpenvpnConfigSection" iroute_name2
    config_get Iroute_Addresses2 "$OpenvpnConfigSection" iroute_address2
    config_get Iroute_Netmask2 "$OpenvpnConfigSection" iroute_netmask2
    config_get Iroute_name3 "$OpenvpnConfigSection" iroute_name3
    config_get Iroute_Addresses3 "$OpenvpnConfigSection" iroute_address3
    config_get Iroute_Netmask3 "$OpenvpnConfigSection" iroute_netmask3
    config_get Iroute_name4 "$OpenvpnConfigSection" iroute_name4
    config_get Iroute_Addresses4 "$OpenvpnConfigSection" iroute_address4
    config_get Iroute_Netmask4 "$OpenvpnConfigSection" iroute_netmask4
    config_get Iroute_name5 "$OpenvpnConfigSection" iroute_name5
    config_get Iroute_Addresses5 "$OpenvpnConfigSection" iroute_address5
    config_get Iroute_Netmask5 "$OpenvpnConfigSection" iroute_netmask5

    config_get Enable_authentication "$OpenvpnConfigSection" enable_authentication
    config_get Username "$OpenvpnConfigSection" username
    config_get Password "$OpenvpnConfigSection" password
    config_get auth "$OpenvpnConfigSection" auth_pass
    config_get ask "$OpenvpnConfigSection" ask_pass
    config_get enable_askpass "$OpenvpnConfigSection" enable_askpass
    config_get auth_key "$OpenvpnConfigSection" auth_key
    config_get Enable_peer_lan "$OpenvpnConfigSection" enable_peer_lan

    #config_get Config "$OpenvpnConfigSection" config

    ccd="/etc/openvpn/ccd"
    #auth="/etc/openvpn"


    # # Create CCD file if Role is SERVER and Iroute_name is set
	if [ "$Role1" = "SERVER" ] && [ -n "$Iroute_name" ] && [ "$Enable_peer_lan" == "1" ]; then
            mkdir -p "$ccd"
            chmod 777 "$ccd"

            for i in $(seq 1 "$Iroute_name"); do
                name=$(eval echo "\$Iroute_name$i")
                addresses=$(eval echo "\$Iroute_Addresses$i")
                netmask=$(eval echo "\$Iroute_Netmask$i")

                if [ -n "$name" ] && [ -n "$addresses" ] && [ -n "$netmask" ]; then
                    > "$ccd/$name"  # clear/create file

                    for subnet in $addresses; do
                        echo "iroute $subnet $netmask" >> "$ccd/$name"  #Redirection particular filename  
                    done

                    chmod 777 "$ccd/$name"     #Executable format
                    echo "rm $ccd/$name"
                fi
            done
        fi

   # Create authentication file if authentication is enabled
    if [ "$Enable_authentication" = "1" ] && [ -n "$Username" ] && [ -n "$Password" ] && [ -n "$auth" ]; then
        file_path="$auth"
        {
            echo "$Username"
            echo "$Password"
        } > "$file_path"
        
        # set the file permissions to secure it  
        chmod 777 "$file_path"

        echo rm "$auth"
    fi

    # Create authentication file if authentication is enabled
    if [ "$enable_askpass" = "1" ] && [ -n "$auth_key" ] && [ -n "$ask" ]; then
        file_path_ask="$ask"

        # Create the file and write the auth_key
        echo "$auth_key" > "$file_path_ask"

        # Set file permissions to secure it (optional but recommended)
        chmod 777 "$file_path_ask"

        # Log what would be the cleanup command
        echo rm $file_path_ask
    fi


}

ReadOpenvpnUCIConfig >>/root/InterfaceManager/script/vpn/openvpn/bridge.sh
