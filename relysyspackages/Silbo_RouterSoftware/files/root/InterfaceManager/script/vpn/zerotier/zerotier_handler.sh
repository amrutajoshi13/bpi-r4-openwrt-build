#!/bin/sh

. /lib/functions.sh

zerotirestop="/etc/init.d/zerotier stop"
zerotirestart="/etc/init.d/zerotier start"

Enablezerotire="$(uci get vpnconfig1.general.enablezerotiergeneral 2>/dev/null)"
enablecellular="$(uci get sysconfig.sysconfig.enablecellular 2>/dev/null)"
CellularOperationMode="$(uci get sysconfig.sysconfig.CellularOperationMode 2>/dev/null)"

wanCount="$(wc -l < /etc/waninterface.txt)"
lanCount="$(wc -l < /etc/internetoverlan.txt)"

if [ "$Enablezerotire" = "1" ]; then
	response=$($zerotirestart)

	# Zerotier zone
	uci set firewall.zerotier=zone
	uci set firewall.zerotier.name="zerotier"
       uci set firewall.zerotier.network="zerotier"
	uci set firewall.zerotier.input="ACCEPT"
	uci set firewall.zerotier.output="ACCEPT"
	uci set firewall.zerotier.forward="ACCEPT"
	uci set firewall.zerotier.device="zt+"
	uci set firewall.zerotier.masq="1"
	uci set firewall.zerotier.mtu_fix="1"

	# Cellular mode mapping
	case "$CellularOperationMode" in
		dualcellularsinglesim)
			modem1="CWAN1"
			modem2="CWAN1"
			;;
		singlecellulardualsim)
			modem1="CWAN1_0"
			modem2="CWAN1_1"
			;;
		singlecellularsinglesim)
			modem1="CWAN1"
			modem2=""
			;;
	esac

	# Cellular forwardings
	if [ "$enablecellular" = "1" ] && [ -n "$modem1" ]; then
		uci set firewall.${modem1}zerotier=forwarding
		uci set firewall.${modem1}zerotier.src="zt"
		uci set firewall.${modem1}zerotier.dest="$modem1"

		uci set firewall.zerotier${modem1}=forwarding
		uci set firewall.zerotier${modem1}.src="$modem1"
		uci set firewall.zerotier${modem1}.dest="zt"
	fi

	if [ "$enablecellular" = "1" ] && [ -n "$modem2" ]; then
		uci set firewall.${modem2}zerotier=forwarding
		uci set firewall.${modem2}zerotier.src="zt"
		uci set firewall.${modem2}zerotier.dest="$modem2"

		uci set firewall.zerotier${modem2}=forwarding
		uci set firewall.zerotier${modem2}.src="$modem2"
		uci set firewall.zerotier${modem2}.dest="zt"
	fi

	# WAN forwardings
	for j in $(seq 1 "$wanCount"); do
		wan="$(sed -n "${j}p" /etc/waninterface.txt)"

		uci set firewall.${wan}zerotier=forwarding
		uci set firewall.${wan}zerotier.src="zt"
		uci set firewall.${wan}zerotier.dest="$wan"

		uci set firewall.zerotier${wan}=forwarding
		uci set firewall.zerotier${wan}.src="$wan"
		uci set firewall.zerotier${wan}.dest="zt"
	done

	# LAN forwardings
	for j in $(seq 1 "$lanCount"); do
		lan="$(sed -n "${j}p" /etc/internetoverlan.txt)"

		uci set firewall.${lan}zerotier=forwarding
		uci set firewall.${lan}zerotier.src="zt"
		uci set firewall.${lan}zerotier.dest="$lan"

		uci set firewall.zerotier${lan}=forwarding
		uci set firewall.zerotier${lan}.src="$lan"
		uci set firewall.zerotier${lan}.dest="zt"
	done

else
	response=$($zerotirestop)
       #Before we are deleting all Zones and forwardings.
       uci -q delete firewall.zerotier

       # Always clean all cellular zerotier forwardings (mode-independent)
       for m in CWAN1 CWAN1_0 CWAN1_1; do
              uci -q delete firewall.${m}zerotier
              uci -q delete firewall.zerotier${m}
       done

       #WanInterfaces 
       for j in $(seq 1 "$wanCount"); do
              wan="$(sed -n "${j}p" /etc/waninterface.txt)"
              uci -q delete firewall.${wan}zerotier
              uci -q delete firewall.zerotier${wan}
       done
       #LanInterfaces 
       for j in $(seq 1 "$lanCount"); do
              lan="$(sed -n "${j}p" /etc/internetoverlan.txt)"
              uci -q delete firewall.${lan}zerotier
              uci -q delete firewall.zerotier${lan}
       done
fi

uci commit firewall
/sbin/fw3 reload >/dev/null 2>&1
