#!/bin/sh

. /lib/functions.sh

# Accessing from webpage 
Interface="$1"

if [ "x$Interface" = "x" ]
then
     echo "Please provide interface name" > /tmp/bridge_created.txt
else     
     uci set network.SW_LAN.type='bridge'
     uci set network.SW_LAN.ifname="eth0.1 $Interface"

     uci commit network

     # restart the SW_LAN 
     ubus call network reload '{"config": "SW_LAN", "apply": true}'

     echo "Bridge created" > /tmp/bridge_created.txt
     
     /etc/init.d/openvpn restart
fi






