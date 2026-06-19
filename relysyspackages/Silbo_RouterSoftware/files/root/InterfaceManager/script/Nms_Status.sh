#!/bin/bash
. /lib/functions.sh

nmsstatusfile="/etc/config/remoteconfigstatus"
NMS_Enable=$(uci get remoteconfig.nms.nmsenable)
RMS=$(uci get remoteconfig.general.rmsoption)		
nmstunneltype=$(uci get remoteconfig.nms.nmstunneltype)

if [ "${NMS_Enable}" = "1" ]
then
	if [ "$RMS" = "nms" ]
	then
		if [ "$nmstunneltype" = "openvpn" ]
		then
			status=$(ifconfig | grep -w "tun0" | cut -d' ' -f1 | cut -d '_' -f2)
			if [ -n "$status" ]; then
				Status="online"
			else
				Status="offline"
			fi
			
			address=$(ifconfig | grep -w "tun0" -A1 | awk '/inet addr/{print $2}' | cut -d: -f2)
			# jq is used to parse, filter, and manipulate JSON data in a structured way
			UPTIME=$(ifstatus VPN | jq -r 'select(.l3_device=="tun0") | .uptime')
			# or we can use grep and awk too
			#UPTIME=$(ifstatus VPN | grep -o '"uptime": [0-9]*' | awk '{print $2}')

			# Convert to hr:min:sec format
			Hours=$((UPTIME / 3600))
			Minutes=$(((UPTIME % 3600) / 60))
			Seconds=$((UPTIME % 60))
			
			Uptime="${Hours}h ${Minutes}m ${Seconds}s"
			
			uci set remoteconfigstatus.remote1=remote	
			uci set remoteconfigstatus.remote1.name='NMS'
			uci set remoteconfigstatus.remote1.status="$Status"
			uci set remoteconfigstatus.remote1.trackingstatus='tun0'
			uci set remoteconfigstatus.remote1.ipaddress="$address"
			uci set remoteconfigstatus.remote1.time="$Uptime"
  
			uci commit remoteconfigstatus
			
		else
			status=$(ifconfig | grep -w "wg0" | cut -d' ' -f1 | cut -d '_' -f2)
			if [ -n "$status" ]; then
				Status="online"
			else
				Status="offline"
			fi
			address=$(ifconfig | grep -w "wg0" -A1 | awk '/inet addr/{print $2}' | cut -d: -f2)
			# jq is used to parse, filter, and manipulate JSON data in a structured way
			UPTIME=$(ifstatus wg0 | jq -r 'select(.l3_device=="wg0") | .uptime')
			# or we can use grep and awk too
			#UPTIME=$(ifstatus wg0 | grep -o '"uptime": [0-9]*' | awk '{print $2}')

			# Convert to hr:min:sec format
			Hours=$((UPTIME / 3600))
			Minutes=$(((UPTIME % 3600) / 60))
			Seconds=$((UPTIME % 60))

			Uptime="${Hours}h ${Minutes}m ${Seconds}s"	
			
			uci set remoteconfigstatus.remote1=remote	
			uci set remoteconfigstatus.remote1.name='NMS'
			uci set remoteconfigstatus.remote1.status="$Status"
			uci set remoteconfigstatus.remote1.trackingstatus='wg0'
			uci set remoteconfigstatus.remote1.ipaddress="$address"
			uci set remoteconfigstatus.remote1.time="$Uptime"
			
			uci commit remoteconfigstatus
		fi
	fi	
else 
	 echo "" > "$nmsstatusfile"	
fi
