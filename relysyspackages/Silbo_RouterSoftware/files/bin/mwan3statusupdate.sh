#!/bin/sh

. /lib/functions.sh

rm /bin/mwan3status.txt
touch /bin/mwan3status.txt
chmod 0777 /bin/mwan3status.txt

wanconfigname3="CWAN1"
wanconfigname4="CWAN2"
wanconfigname5="CWAN1_0"
wanconfigname6="CWAN1_1"

wanconfigname7="WIFI_WAN"
#IPV6 Variables 
cellularwan6sim1interface="wan6c1"
cellularwan6sim2interface="wan6c2"
uci delete mwan3statusconfig.$wanconfigname1
uci delete mwan3statusconfig.$wanconfigname2
uci delete mwan3statusconfig.$wanconfigname3
uci delete mwan3statusconfig.$wanconfigname4
uci delete mwan3statusconfig.$wanconfigname5
uci delete mwan3statusconfig.$wanconfigname6
uci delete mwan3statusconfig.$wanconfigname7
uci delete mwan3statusconfig.$cellularwan6sim1interface
uci delete mwan3statusconfig.$cellularwan6sim2interface

#mwan3 interfaces | grep -i "Interface" | awk '{if(NR>1)print}'  > /bin/mwan3status.txt
mwan3 interfaces | grep -i "Interface" | awk '{if(NR>1)print}' | awk '{$1=$1}1' > /bin/mwan3status.txt

input="/bin/mwan3status.txt"
while IFS= read -r line
do
  echo "$line"
  
  #interface=$($line | cut -d " " -f1)
  #echo "interface=$interface"
  
  interface=$(echo "$line" | cut -d " " -f2)
  echo interface = $interface

  #status=$(echo "$line" | cut -d " " -f4)
  #echo status = $status
 
   #trackingstatus=$(echo "$line" | cut -d " " -f11)
   
  # Extract tracking status using awk 
    trackingstatus=$(echo "$line" | awk -F "tracking is " '{print $2}' | awk '{print $1}')
  
  if [ "$trackingstatus" != "active" ]; then
      trackingstatus="down"
   fi
  echo trackingstatus = $trackingstatus
  
  if [ "$trackingstatus" = "not" ]; then
  echo "trackingstatus has the value 'not'"
  trackingstatussave="NotEnabled"
  
  else
  echo "not matching"
  trackingstatussave=$trackingstatus
fi

	#Get ifname for fping.
	ifname=$(uci get network.$interface.ifname)
	
	#Interface_Status - Check online/offline/error.
	interface_status=$(echo "$line" | cut -d " " -f4)
	
	# Initialize internet_status as offline
	internet_status="offline"
	
	#If interface_status is online, then get the trackip from mwan3 config.
	#Fping to this track_ip, to get internet status.
	if [ "$interface_status" = "online" ] || [ "$interface_status" = "error" ]
	then
	
		track_ip=$(uci get mwan3.$interface.track_ip)
		
		if [ -z "$track_ip" ]
		then
			track_ip="8.8.8.8"
		fi
		
		#internet_status
		for ip in $track_ip
		do
			if fping -I "$ifname" -q -c 2 "$ip" &> /dev/null
			then
				internet_status="online"
				# Exit the loop if the internet status is confirmed online even for a single track ip.
				break				
			fi
		done
	fi

	uci set mwan3statusconfig."$interface"=redirect
	uci set mwan3statusconfig.$interface.name=$interface
	uci set mwan3statusconfig.$interface.interface_status=$interface_status
	uci set mwan3statusconfig.$interface.internet_status=$internet_status
	uci set mwan3statusconfig.$interface.trackingstatus=$trackingstatussave
  
done < "$input"

uci commit mwan3statusconfig



