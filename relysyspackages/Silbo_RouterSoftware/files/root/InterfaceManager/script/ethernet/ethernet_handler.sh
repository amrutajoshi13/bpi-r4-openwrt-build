
#This script manages Ethernet and it's related settings:

#1. Detects changes to VLAN and Ethernet configuration.
#2. Checks if DHCP relay server is enabled.
#3. Restarts the network to apply interface, DHCP, and firewall changes.
#4. After the network is back up, applies flow offloading and SMP IRQ affinity.
#5. Runs multiple_scripts_restart to restart VPNs, PBR, and NoDogSplash.
#6. Finally, executes dynamic_relay, which includes a dnsmasq restart and requires the new IP.

#Note: dynamic_relay must run last because it depends on the network being fully up.

#######################################################################################################################

#!/bin/sh

. /lib/functions.sh

#For untagged/tagged Vlans.
#/root/InterfaceManager/script/ethernet/Port_Based_Vlan.sh

#loopback
loopbackip=$(uci get sysconfig.loopback.loopbackip)
loopbacknetmask=$(uci get sysconfig.loopback.loopbacknetmask)

uci set network.loopback.ipaddr=$loopbackip
uci set network.loopback.netmask=$loopbacknetmask
uci commit network 

#For Ethernet settings.
/root/InterfaceManager/script/ethernet/Network_Interface.sh

sleep 1

#emptying the file /etc/dnsmasq.conf
echo -n > /etc/dnsmasq.conf 
#create DHCP relay server if it is enabled...
/root/InterfaceManager/script/ethernet/DHCP_Relay.sh

ubus call firewall reload
ubus call dhcp reload

touch /tmp/mwan-ignore-CWAN1_0
touch /tmp/mwan-ignore-CWAN1
touch /tmp/mwan-ignore-wan6c1
#Restart the network.
/etc/init.d/network restart > /dev/null 2>&1

echo > /proc/net/nf_conntrack

#Make sure to change the below in systemboot as well. Once done, delete this comment.
#Check flow_offloading & Smp IRQ Affinity
#/root/InterfaceManager/script/ethernet/FlowOffloading.sh

#Restart VPNs, PBR & nodogsplash.
/root/InterfaceManager/script/ethernet/multiple_scripts_restart.sh

sleep 1

#Set dhcp-relay in case of dynamic protocol.
/root/InterfaceManager/script/ethernet/dynamic_relay.sh

exit 0
