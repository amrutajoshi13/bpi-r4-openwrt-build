#!/bin/sh

. /lib/functions.sh

interfaces=$(wg show | awk '/interface:/ {print $2}')
endpoint_v4=$(wg show | awk '/endpoint:/ {print $2}' | cut -d ':' -f 1)
endpoint_v6=$(wg show | grep 'endpoint' | awk '{print $2}' | sed 's/\[\(.*\)\]:.*/\1/')

if [ -n "$interfaces" ]; then

    # Loop over each interface

    for interface in $interfaces; do

        Role=$(uci get wireguard.$interface.role)

        if [ "$Role" == "CLIENT" ]; then

            /root/InterfaceManager/script/vpn/wireguard/wireguard_failover.sh &
        fi

        status=$(ifconfig | grep -w "$interface")

        # Check if it's IPv4
        if echo "$endpoint_v4" | grep -Eq "^([0-9]{1,3}\.){3}[0-9]{1,3}$"; then
            echo "The IP address is IPv4"
            address=$(ifconfig | grep -w "$interface" -A1 | awk '/inet addr/{print $2}' | cut -d: -f2)

        # Check if it's IPv6 (including shorthand forms like ::)
        elif echo "$endpoint_v6" | grep -Eq "^([0-9a-fA-F]{1,4}:){1,7}([0-9a-fA-F]{1,4})?$|::"; then
            echo "The IP address is IPv6"
            address=$(ifconfig | grep -w "$interface" -A3 | awk '/inet6 addr/{print $3}' | cut -d/ -f1)

        # If it doesn't match either pattern
        else
            echo "Invalid IP address"
        fi

        # Run wg show for the current interface and get the latest handshake line

        handshake=$(wg show $interface | grep "latest handshake")

        # Extract the latest handshake time for the current interface

        latest_handshake=$(echo "$handshake" | awk '{print $3, $4, $5, $6}')

        # Print the complete information along with the latest handshake time

        echo "Interface: $interface"

        echo "Handshake: $handshake"

        echo "Latest Handshake: $latest_handshake"

        # Check if the handshake time contains minutes or hours

        if echo "$latest_handshake" | grep -q "hour"; then

            hours=$(echo "$latest_handshake" | awk '{print $1}')

            minutes=$(echo "$latest_handshake" | awk '{print $3}')

            seconds=$(echo "$latest_handshake" | awk '{print $5}')

            total_seconds=$((hours * 3600 + minutes * 60 + seconds))

        elif echo "$latest_handshake" | grep -q "minute"; then

            minutes=$(echo "$latest_handshake" | awk '{print $1}')

            seconds=$(echo "$latest_handshake" | awk '{print $3}')

            total_seconds=$((minutes * 60 + seconds))

        else

            seconds=$(echo "$latest_handshake" | awk '{print $1}')

            total_seconds=$seconds

        fi

        # Set the status based on the total_seconds and presence of status

        if [ "$total_seconds" -lt 180 ] && [ -n "$status" ]; then

            Status="UP"

        else

            Status="DOWN"

        fi

        # Print total_seconds and set UCI configuration

        echo "$total_seconds"

        echo $Name

        echo $Status

        echo $address

        uci set wireguard.$interface.status="$Status"

        uci set wireguard.$interface.address="$address"

        uci commit wireguard

    done

else

    wirevpnUCIPath=/etc/config/wireguard

    ReadwirevpnUCIConfig() {

        config_load "$wirevpnUCIPath"

        config_foreach wirevpnConfigParameters wireguard

    }

    wirevpnConfigParameters() {

        local wirevpnConfigSection="$1"

        config_get Name "$wirevpnConfigSection" name

        echo The value of name is $Name

        if [ -n "$status" ]; then

            Status="UP"

        else

            Status="DOWN"

        fi

        uci set wireguard.$Name.status=$Status

        uci set wireguard.$Name.address=$address

    }

    ReadwirevpnUCIConfig

    uci commit wireguard

fi
