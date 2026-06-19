#!/bin/sh

# Configuration paths
WG_CONFIG="/etc/config/wireguard"
NETWORK_CONFIG="/etc/config/network"
PREVIOUS_ENDPOINT_FILE="/tmp/previous_endpoint"
TMP_FILE="/tmp/fallback_logs.txt"
LogrotateConfigFile="/etc/logrotate.d/WireguardFailoverLogrotateConfig"

#echo "Running" >> /root/tmp.txt
# Extract the name from the wireguard configuration
WG_NAME=$(awk -F"'" '/option name/ {print $2}' $WG_CONFIG)
echo $WG_NAME

# Extract the IPv6 and IPv4 endpoints from the wireguard configuration
IPV6_ENDPOINT=$(awk -F"'" '/option endpoint_hostipv6/ {print $2}' $WG_CONFIG)
IPV4_ENDPOINT=$(awk -F"'" '/option endpoint_hostipv4/ {print $2}' $WG_CONFIG)
MASTER_ENDPOINT=$(awk -F"'" '/option master_endpoint/ {print $2}' $WG_CONFIG)

echo $IPV6_ENDPOINT
echo $IPV4_ENDPOINT
echo $MASTER_ENDPOINT

# Function to set WireGuard endpoint
set_endpoint() {
    local endpoint=$1
    uci set network.wireguard_$WG_NAME.endpoint_host=$endpoint
    uci commit network
    /etc/init.d/network restart
    echo "$(date):WireGuard endpoint set to $endpoint"
}

# Read the previous endpoint from the file
if [ -f $PREVIOUS_ENDPOINT_FILE ]; then
    PREVIOUS_ENDPOINT=$(cat $PREVIOUS_ENDPOINT_FILE)
    #echo $PREVIOUS_ENDPOINT >> /root/tmp.txt
else
    PREVIOUS_ENDPOINT=""
fi

logrotate "$LogrotateConfigFile"

# Check connectivity based on the preferred endpoint
if [ "$MASTER_ENDPOINT" == "IPV6" ]; then
    if ping -c 3 -W 1 $IPV6_ENDPOINT &> /dev/null; then
        echo "$(date): IPv6 is available" >> $TMP_FILE
        if [ "$PREVIOUS_ENDPOINT" != "$IPV6_ENDPOINT" ]; then
            set_endpoint $IPV6_ENDPOINT
            echo $IPV6_ENDPOINT > $PREVIOUS_ENDPOINT_FILE
        else
            echo "$(date): IPv6 is already set no need to restart the network" >> $TMP_FILE
        fi
    else
        echo "$(date): IPv6 is not available, falling back to IPv4" >> $TMP_FILE
        if [ "$PREVIOUS_ENDPOINT" != "$IPV4_ENDPOINT" ]; then
            set_endpoint $IPV4_ENDPOINT
            echo $IPV4_ENDPOINT > $PREVIOUS_ENDPOINT_FILE
        else
            echo "$(date): IPv4 is already set" >> $TMP_FILE
        fi
    fi
elif [ "$MASTER_ENDPOINT" == "IPV4" ]; then
    if ping -c 3 -W 1 $IPV4_ENDPOINT &> /dev/null; then
        echo "$(date): IPv4 is available" >> $TMP_FILE
        if [ "$PREVIOUS_ENDPOINT" != "$IPV4_ENDPOINT" ]; then
            set_endpoint $IPV4_ENDPOINT
            echo $IPV4_ENDPOINT > $PREVIOUS_ENDPOINT_FILE
        else
            echo "$(date): IPv4 is already set" >> $TMP_FILE
        fi
    else
        echo "$(date): IPv4 is not available, falling back to IPv6" >> $TMP_FILE
        if [ "$PREVIOUS_ENDPOINT" != "$IPV6_ENDPOINT" ]; then
            set_endpoint $IPV6_ENDPOINT
            echo $IPV6_ENDPOINT > $PREVIOUS_ENDPOINT_FILE
        else
            echo "$(date): IPv6 is already set" >> $TMP_FILE
        fi
    fi
else
    echo "Error: Invalid flag value!" >> $TMP_FILE
    exit 1
fi
