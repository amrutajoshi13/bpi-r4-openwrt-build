#!/bin/sh
. /lib/functions.sh

IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral 2>/dev/null || echo 0)

cleanup_ipsec_rules() {
	type="$1"
	case "$type" in
		failover)
			for rule in $(uci show firewall | grep '=rule' | grep 'ipsec_fo_rule' | cut -d'.' -f2 | cut -d'=' -f1); do
				uci delete firewall.$rule 2>/dev/null
			done
			;;
		balanced)
			for rule in $(uci show firewall | grep '=rule' | grep 'ipsec_lb_rule' | cut -d'.' -f2 | cut -d'=' -f1); do
				uci delete firewall.$rule 2>/dev/null
			done
			;;
		all)
			for rule in $(uci show firewall | grep '=rule' | grep -E 'ipsec_(lb|fo)_rule' | cut -d'.' -f2 | cut -d'=' -f1); do
				uci delete firewall.$rule 2>/dev/null
			done
			;;
	esac
}

commit_and_restart_ipsec() {
	uci commit ipsec
	uci commit firewall
	sleep 1
	/sbin/fw3 reload > /dev/null 2>&1
	/etc/init.d/ipsec stop
	sleep 1
	/etc/init.d/ipsec start
	sleep 4
	/usr/sbin/ipsec restart
}

handle_failover_ipsec() {
	interface_list=$(ip route get 8.8.8.8 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')

	check_pppoe=$(echo "$interface_list" | cut -d "-" -f1)
	if [ "$check_pppoe" = "pppoe" ]; then
		pppoe_interface=$(echo "$interface_list" | cut -d "-" -f2)
		interface_name="$pppoe_interface"
	else
		wanCount=$(wc -l < /etc/waninterface.txt)
		for j in $(seq 1 "$wanCount"); do
			wan=$(sed -n "${j}p" /etc/waninterface.txt)
			match_ifname=$(uci get network.$wan.ifname)
			if [ "$match_ifname" = "$interface_list" ]; then
				interface_name="$wan"
				break
			fi
		done
	fi

	if [ -n "$interface_name" ]; then
		interface_src="$interface_name"
	elif [ "$interface_list" = "apcli0" ]; then
		interface_src="WIFI_WAN"
	else
		Cellular_mode=$(uci get sysconfig.sysconfig.CellularOperationMode)
		CWAN1_Enable=$(uci get modem.CWAN1.modemenable)
		CWAN2_Enable=$(uci get modem.CWAN2.modemenable)
		if [ "$Cellular_mode" = "dualcellularsinglesim" ]; then
			if [ "$CWAN1_Enable" = "1" ]; then
				CWAN1_Ifname=$(uci get modem.CWAN1.interfacename)
			fi
			if [ "$CWAN2_Enable" = "1" ]; then
				CWAN2_Ifname=$(uci get modem.CWAN2.interfacename)
			fi
			if [ "$interface_list" = "$CWAN1_Ifname" ]; then
				interface_src="CWAN1"
			elif [ "$interface_list" = "$CWAN2_Ifname" ]; then
				interface_src="CWAN2"
			fi
		elif [ "$Cellular_mode" = "singlecellulardualsim" ]; then
			if echo "$interface_list" | grep -Eq 'usb0|wwan0|usb1|wwan1'; then
				simnum=$(cat /tmp/simnumfile)
				if [ "$simnum" = "1" ]; then
					interface_src="CWAN1_0"
				else
					interface_src="CWAN1_1"
				fi
			fi
		else
			if echo "$interface_list" | grep -Eq 'usb0|wwan0|usb1|wwan1'; then
				interface_src="CWAN1"
			fi
		fi
	fi

	uci batch <<EOF
set firewall.ipsec_fo_rule1=rule
set firewall.ipsec_fo_rule1.name='ipsec_fo_rule1'
set firewall.ipsec_fo_rule1.proto='udp'
set firewall.ipsec_fo_rule1.dest_port='500 4500'
set firewall.ipsec_fo_rule1.target='ACCEPT'
set firewall.ipsec_fo_rule1.src="${interface_src}"

set firewall.ipsec_fo_rule2=rule
set firewall.ipsec_fo_rule2.name='ipsec_fo_rule2'
set firewall.ipsec_fo_rule2.family='ipv4'
set firewall.ipsec_fo_rule2.src='*'
set firewall.ipsec_fo_rule2.dest='*'
set firewall.ipsec_fo_rule2.proto='all'
set firewall.ipsec_fo_rule2.target='ACCEPT'
set firewall.ipsec_fo_rule2.extra='-m policy --dir in --pol ipsec'

set firewall.ipsec_fo_rule3=rule
set firewall.ipsec_fo_rule3.name='ipsec_fo_rule3'
set firewall.ipsec_fo_rule3.family='ipv4'
set firewall.ipsec_fo_rule3.src='*'
set firewall.ipsec_fo_rule3.dest='*'
set firewall.ipsec_fo_rule3.proto='all'
set firewall.ipsec_fo_rule3.target='ACCEPT'
set firewall.ipsec_fo_rule3.extra='-m policy --dir out --pol ipsec'
EOF

	lanCount=$(wc -l < /etc/laninterface.txt)
	baseIndex=4
	for j in $(seq 1 "$lanCount"); do
		lan=$(sed -n "${j}p" /etc/laninterface.txt)
		ruleNum=$((baseIndex + j - 1))
		uci set firewall.ipsec_fo_rule${ruleNum}=rule
		uci set firewall.ipsec_fo_rule${ruleNum}.name="ipsec_fo_rule${ruleNum}"
		uci set firewall.ipsec_fo_rule${ruleNum}.proto='esp'
		uci set firewall.ipsec_fo_rule${ruleNum}.target='ACCEPT'
		uci set firewall.ipsec_fo_rule${ruleNum}.dest="${lan}"
		uci set firewall.ipsec_fo_rule${ruleNum}.src="${interface_src}"
	done

	if [ -n "$interface_src" ]; then
		uci set ipsec.general.interface="${interface_src}"
	fi
}

Ipsec_Config() {
	local IpsecConfigSection="$1"
	config_get Name "$IpsecConfigSection" name
	config_get Interface_list "$IpsecConfigSection" interface_list
	if echo "$unique_interfaces" | grep -qw "$Interface_list"; then
		return
	fi
	unique_interfaces="$unique_interfaces $Interface_list"
	lanCount=$(wc -l < /etc/laninterface.txt)
	baseIndex=$((baseIndex + 1))
	uci set firewall.ipsec_lb_rule${baseIndex}=rule
	uci set firewall.ipsec_lb_rule${baseIndex}.name="ipsec_lb_rule${baseIndex}"
	uci set firewall.ipsec_lb_rule${baseIndex}.proto='udp'
	uci set firewall.ipsec_lb_rule${baseIndex}.dest_port='500 4500'
	uci set firewall.ipsec_lb_rule${baseIndex}.target='ACCEPT'
	uci set firewall.ipsec_lb_rule${baseIndex}.src="${Interface_list}"

	for j in $(seq 1 "$lanCount"); do
		lan=$(sed -n "${j}p" /etc/laninterface.txt)
		baseIndex=$((baseIndex + 1))
		uci set firewall.ipsec_lb_rule${baseIndex}=rule
		uci set firewall.ipsec_lb_rule${baseIndex}.name="ipsec_lb_rule${baseIndex}"
		uci set firewall.ipsec_lb_rule${baseIndex}.proto='esp'
		uci set firewall.ipsec_lb_rule${baseIndex}.target='ACCEPT'
		uci set firewall.ipsec_lb_rule${baseIndex}.dest="${lan}"
		uci set firewall.ipsec_lb_rule${baseIndex}.src="${Interface_list}"
	done
}

handle_balanced_ipsec() {
	uci batch <<EOF
set firewall.ipsec_lb_rule1=rule
set firewall.ipsec_lb_rule1.name='ipsec_lb_rule1'
set firewall.ipsec_lb_rule1.family='ipv4'
set firewall.ipsec_lb_rule1.src='*'
set firewall.ipsec_lb_rule1.dest='*'
set firewall.ipsec_lb_rule1.proto='all'
set firewall.ipsec_lb_rule1.target='ACCEPT'
set firewall.ipsec_lb_rule1.extra='-m policy --dir in --pol ipsec'

set firewall.ipsec_lb_rule2=rule
set firewall.ipsec_lb_rule2.name='ipsec_lb_rule2'
set firewall.ipsec_lb_rule2.family='ipv4'
set firewall.ipsec_lb_rule2.src='*'
set firewall.ipsec_lb_rule2.dest='*'
set firewall.ipsec_lb_rule2.proto='all'
set firewall.ipsec_lb_rule2.target='ACCEPT'
set firewall.ipsec_lb_rule2.extra='-m policy --dir out --pol ipsec'
EOF
	baseIndex=2
	unique_interfaces=""
	config_load vpnconfig1
	config_foreach Ipsec_Config vpnconfig1
}

# main logic
if [ "$IpsecEnable" = "1" ]; then
	mode=$(uci get mwan3config.general.select 2>/dev/null)
	if [ "$mode" = "failover" ]; then
		cleanup_ipsec_rules "balanced"
		handle_failover_ipsec
		commit_and_restart_ipsec
	elif [ "$mode" = "balanced" ]; then
		cleanup_ipsec_rules "failover"
		cleanup_ipsec_rules "balanced"
		handle_balanced_ipsec
		commit_and_restart_ipsec
	fi
else
	cleanup_ipsec_rules "all"
	uci commit firewall
	/sbin/fw3 reload > /dev/null 2>&1
fi

