#!/bin/sh
. /lib/functions.sh
cellularmode=$(uci get sysconfig.sysconfig.CellularOperationMode)
cellularenable=$(uci get sysconfig.sysconfig.enablecellular)
wifienable=$(uci get sysconfig.wificonfig.wifi1enable)
guestwifienable=$(uci get sysconfig.guestwifi.guestwifienable)
wifi1mode=$(uci get sysconfig.wificonfig.wifi1mode)
pdp1=$(uci get sysconfig.sysconfig.pdp)
pdp2=$(uci get sysconfig.sysconfig.sim2pdp)


RemovefirewallZoneForwarding()
{
	lanCount=$(cat /etc/all_laninterface.txt | wc -l)
	if [ -n "$lanCount" ]
	then
		lan_interfaces=$(cat /etc/config/networkinterfaces | grep -i type | grep -c LAN)
		if [ "$lan_interfaces" -gt 0 ]  
		then                                               
		    lanCount=$(cat /etc/all_laninterface.txt | wc -l)				
			wanCount=$(cat /etc/all_waninterface.txt | wc -l)
			for i in $(seq 1 ${lanCount})
			do
				lan=$(cat /etc/all_laninterface.txt | head -${i} | tail -1)
				
				for j in $(seq 1 ${wanCount})
				do
					wan=$(cat /etc/all_waninterface.txt | head -${j} | tail -1)
					uci delete firewall.${wan}${lan}			
				done
			done				
	    fi	
	fi   
}

UpdateLanWanInterfaces()
{
rm /etc/all_laninterface.txt
rm /etc/all_waninterface.txt

cp /etc/waninterface.txt /etc/all_waninterface.txt
cp /etc/internetoverlan.txt /etc/all_laninterface.txt

if [ "$cellularenable" = "1" ]
then 
	if [ "$pdp1" = "IPV6" ] && ([ "$cellularmode" = "singlecellulardualsim" ] || [ "$cellularmode" = "singlecellularsinglesim" ]);then
		echo "wan6c1" >> /etc/all_waninterface.txt
	fi
	
	if [ "$pdp2" = "IPV6" ] && [ "$cellularmode" = "singlecellulardualsim" ];then
		echo "wan6c2" >> /etc/all_waninterface.txt
	fi
	
	if ([ "$pdp1" = "IPV4V6" ] || [ "$pdp1" = "IPV4" ]) && [ "$cellularmode" = "singlecellulardualsim" ];then
		echo "CWAN1_0" >> /etc/all_waninterface.txt
	elif ([ "$pdp1" = "IPV4V6" ] || [ "$pdp1" = "IPV4" ]) && [ "$cellularmode" = "singlecellularsinglesim" ];then
	 	echo "CWAN1" >> /etc/all_waninterface.txt
	fi
	
	if ([ "$pdp2" = "IPV4V6" ] || [ "$pdp2" = "IPV4" ]) && [ "$cellularmode" = "singlecellulardualsim" ];then
		echo "CWAN1_1" >> /etc/all_waninterface.txt
	fi
fi

if [ "$wifienable" = "1" ]
then
	if [ "$wifi1mode" = "apsta" ] || [ "$wifi1mode" = "ap" ];then
		echo "ra0" >> /etc/all_laninterface.txt
	fi
	
	if [ "$wifi1mode" = "apsta" ] || [ "$wifi1mode" = "sta" ];then
		echo "WIFI_WAN" >> /etc/all_waninterface.txt
	fi
	
	if [ "$guestwifienable" = "1" ];then
		echo "ra1" >> /etc/all_laninterface.txt
	fi
fi



}

UpdatefirewallZoneForwarding()
{
	lanCount=$(cat /etc/all_laninterface.txt | wc -l)
	if [ -n "$lanCount" ]
	then
		lan_interfaces=$(cat /etc/config/networkinterfaces | grep -i type | grep -c LAN)
		if [ "$lan_interfaces" -gt 0 ]  
		then                                               
		    lanCount=$(cat /etc/all_laninterface.txt | wc -l)				
			wanCount=$(cat /etc/all_waninterface.txt | wc -l)
			for i in $(seq 1 ${lanCount})
			do
				lan=$(cat /etc/all_laninterface.txt | head -${i} | tail -1)
				
				for j in $(seq 1 ${wanCount})
				do
					wan=$(cat /etc/all_waninterface.txt | head -${j} | tail -1)
					uci set firewall.${wan}${lan}=forwarding
					uci set firewall.${wan}${lan}.src="$lan"
					uci set firewall.${wan}${lan}.dest="$wan"
				done
			done				
	    fi	
	fi   
}


RemovefirewallZoneForwarding
UpdateLanWanInterfaces
UpdatefirewallZoneForwarding
uci commit firewall
