#!/bin/sh

# Build single-line interface string
conn_info=$(uci show network | grep '=interface' | cut -d. -f2 | cut -d= -f1 | while read -r uci_iface; do
	phy_ifaces=$(uci -q get network.$uci_iface.ifname)
	for phy_iface in $phy_ifaces; do
		ipaddr=$(ip -o -4 addr show dev "$phy_iface" 2>/dev/null | awk '{print $4}' | cut -d/ -f1) 2>&1 > /dev/null
		macaddr=$(cat /sys/class/net/"$phy_iface"/address 2>/dev/null)
		[ -z "$ipaddr" ] && ipaddr="none"
		[ -z "$macaddr" ] && macaddr="none"
		echo "${uci_iface}(${phy_iface})=${ipaddr}/${macaddr}"
	done
done 
) 
# Inject into TR-069 parameter

echo "$conn_info" > /tmp/out.txt
#common_execute_method_param "$DMROOT.Credential.connection" "0" "echo \"$conn_info\"" "" "" "1"

exit 0
