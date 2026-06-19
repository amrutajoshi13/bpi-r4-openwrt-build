#!/bin/sh

. /lib/functions.sh

ipsec_configfile="/etc/config/vpnconfig1"

IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)

ipsec_handle_policy() {

	IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)	
	enablecellular=$(uci get sysconfig.sysconfig.enablecellular)
	CellularOperationModelocal=$(uci get sysconfig.sysconfig.CellularOperationMode)

	if [ "$enablecellular" = "1" ]
	then
		#singlecellulardualsim
		if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
			CWAN1_0_get_pdp=$(uci get modem.CWAN1_0.pdp)
			CWAN1_1_get_pdp=$(uci get modem.CWAN1_1.pdp)
			CWAN1_0ifname=$(uci get modem.CWAN1_0.interfacename)
			CWAN1_1ifname=$(uci get modem.CWAN1_1.interfacename)

			if [ "$CWAN1_0_get_pdp" = "IPV4" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.cwan1_0.extra_src="-i ${CWAN1_0ifname} -m policy --dir in --pol none"
					uci set firewall.cwan1_0.extra_dest="-o ${CWAN1_0ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.cwan1_0.extra_src >/dev/null 2>&1
					uci delete firewall.cwan1_0.extra_dest >/dev/null 2>&1
				fi
			fi

			if [ "$CWAN1_0_get_pdp" = "IPV6" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.wan6c1.extra_src="-i ${CWAN1_0ifname} -m policy --dir in --pol none"
					uci set firewall.wan6c1.extra_dest="-o ${CWAN1_0ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.wan6c1.extra_src >/dev/null 2>&1
					uci delete firewall.wan6c1.extra_dest >/dev/null 2>&1
				fi
			fi

			if [ "$CWAN1_1_get_pdp" = "IPV4" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.cwan1_1.extra_src="-i ${CWAN1_1ifname} -m policy --dir in --pol none"
					uci set firewall.cwan1_1.extra_dest="-o ${CWAN1_1ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.cwan1_1.extra_src >/dev/null 2>&1
					uci delete firewall.cwan1_1.extra_dest >/dev/null 2>&1
				fi
			fi

			if [ "$CWAN1_1_get_pdp" = "IPV6" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.wan6c2.extra_src="-i ${CWAN1_1ifname} -m policy --dir in --pol none"
					uci set firewall.wan6c2.extra_dest="-o ${CWAN1_1ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.wan6c2.extra_src >/dev/null 2>&1
					uci delete firewall.wan6c2.extra_dest >/dev/null 2>&1
				fi
			fi

		#singlecellularsinglesim
		else
			CWAN1_get_pdp=$(uci get modem.CWAN1.pdp)
			CWAN1ifname=$(uci get modem.CWAN1.interfacename)

			if [ "$CWAN1_get_pdp" = "IPV4" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.cwan1.extra_src="-i ${CWAN1ifname} -m policy --dir in --pol none"
					uci set firewall.cwan1.extra_dest="-o ${CWAN1ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.cwan1.extra_src >/dev/null 2>&1
					uci delete firewall.cwan1.extra_dest >/dev/null 2>&1
				fi
			fi

			if [ "$CWAN1_get_pdp" = "IPV6" ] || [ "$CWAN1_1_get_pdp" = "IPV4V6" ]
			then
				if [ "$IpsecEnable" = "1" ]; then
					uci set firewall.wan6c1.extra_src="-i ${CWAN1ifname} -m policy --dir in --pol none"
					uci set firewall.wan6c1.extra_dest="-o ${CWAN1ifname} -m policy --dir out --pol none"
				else
					uci delete firewall.wan6c1.extra_src >/dev/null 2>&1
					uci delete firewall.wan6c1.extra_dest >/dev/null 2>&1
				fi
			fi
		fi
		uci commit firewall
	fi
}

ipsec_config() {

	ipsec_read="$1"
	config_get Name "$ipsec_read" name
	config_get Status $ipsec_read status

	if [ "$Status" = "DOWN" ]; then
		
		#Add/Remove policy because the ifname isn't fixed.
		ipsec_handle_policy
		
		/sbin/fw3 reload > /dev/null 2>&1

		#Firewall rules creation & deletion in case of Failover & Load Balancing 
		/root/InterfaceManager/script/common_scripts/Ipsec_firewall.sh 

	else
	     return 0  # just skip and go to next config section

	fi
}

config_load "$ipsec_configfile"

config_foreach ipsec_config vpnconfig1

