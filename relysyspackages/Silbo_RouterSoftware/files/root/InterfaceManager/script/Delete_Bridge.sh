#!/bin/sh

. /lib/functions.sh

uci delete network.SW_LAN.type
uci set network.SW_LAN.ifname='eth0.1'

uci commit network

# restart the SW_LAN 
ubus call network reload '{"config": "SW_LAN", "apply": true}'

echo "Deleted Bridge" > /tmp/bridge_deleted.txt







