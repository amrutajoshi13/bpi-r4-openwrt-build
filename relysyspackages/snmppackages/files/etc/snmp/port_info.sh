#!/bin/sh

#sometime snmp command is not give output then we need to restart the snmpd service so we check here...
output=$(snmpget -v1 -c public localhost .1.3.6.1.4.1.38151.1.1.0)
#echo "output=$output"
if [ -z "$output" ] || [ "$output" -eq "Timeout: No Response from 192.168.10.1" ]
then
	/etc/init.d/snmpd restart
fi

PortBasedVlanConfig="/etc/config/portbasedvlanconfig"
port_details="/etc/snmp/port_details.txt"

#emptying the file "$port_details"
echo -n > "$port_details"

#get the board name from Sysinfo 
board_name=$(cat /tmp/sysinfo/board_name | cut -d "," -f2)

#Get only product name 
#RS_Product_name=$(echo $board_name | grep -o RS)
#RQ_Product_name=$(echo $board_name | grep -o RQ)
#RK_Product_name=$(echo $board_name | grep -o RK)
#RU_Product_name=$(echo $board_name | grep -o RU)
#RV00_Product_name=$(echo $board_name | grep -o RV00)
#RV04_Product_name=$(echo $board_name | grep -o RV04)
#RV54_1_Product_name=$(echo $board_name | grep -o RV54-1)
#RV54_2_Product_name=$(echo $board_name | grep -o RV54-2)
#RG_Product_name=$(echo $board_name | grep -o RG)
#ID_Product_name=$(echo $board_name | grep -o ID)


#configure the port number count in /etc/snmp/port_details.txt
#if [ "$RS_Product_name" = "RS" ];then
	#echo "port_number_count=3" >> "$port_details"
	#PORT="port0 port1 port2"
	#port_number="0 1 2"
#elif [ "$RQ_Product_name" = "RQ" ];then
	#echo "port_number_count=2" >> "$port_details"
	#PORT="port1 port2"
	#port_number="1 2"
#elif [ "$RK_Product_name" = "RK" ];then
	#echo "port_number_count=5" >> "$port_details"
	#PORT="port0 port1 port2 port3 port4"
	#port_number="0 1 2 3 4"
#elif [ "$RU_Product_name" = "RU" ];then
	#echo "port_number_count=5" >> "$port_details"
	#PORT="port0 port1 port2 port3 port4"
	#port_number="0 1 2 3 4"
#elif [ "$RV00_Product_name" = "RV00" ];then
	#echo "port_number_count=5" >> "$port_details"
	#PORT="port0 port1 port2 port3 port4"
	#port_number="0 1 2 3 4"
#elif [ "$RV04_Product_name" = "RV04" ];then
	#echo "port_number_count=5" >> "$port_details"
	#PORT="port0 port1 port2 port3 port4"
	#port_number="0 1 2 3 4"
#elif [ "$RV54_1_Product_name" = "RV54-1" ];then
	#echo "port_number_count=5" >> "$port_details"
	#PORT="port0 port1 port2 port3 port4"
	#port_number="0 1 2 3 4"
#elif [ "$RV54_2_Product_name" = "RV54-2" ];then
	#echo "port_number_count=5" >> "$port_details"
	#PORT="port0 port1 port2 port3 port4"
	#port_number="0 1 2 3 4"
#elif [ "$RG_Product_name" = "RG" ];then
	#echo "port_number_count=5" >> "$port_details"
	#PORT="port0 port1 port2 port3 port4"
	#port_number="0 1 2 3 4"
#elif [ "$ID_Product_name" = "ID" ];then
	#echo "port_number_count=4" >> "$port_details"
	#PORT="port0 port1 port2 port3"
	#port_number="0 1 2 3"
#fi

if [ "$board_name" = "Silbo_RD44-A" ];then
	echo "port_number_count=5" >> "$port_details"
	PORT="port0 port1 port2 port3 port4"
	port_number="0 1 2 3 4"
elif [ "$board_name" = "Silbo_RC44" ];then
	echo "port_number_count=3" >> "$port_details"
	PORT="port0 port1 port4"
	port_number="0 1 4"
elif [ "$board_name" = "Silbo_RB44" ];then
	echo "port_number_count=5" >> "$port_details"
	PORT="port0 port1 port2 port3 port4"
	port_number="0 1 2 3 4"
elif [ "$board_name" = "Silbo_RD44-3" ];then
	echo "port_number_count=3" >> "$port_details"
	PORT="port0 port1 port4"
	port_number="0 1 4"
fi

# Get the number of unique VLAN IDs
NoOfVLANID=$(grep -i "option vlanid" $PortBasedVlanConfig | awk '{print $3}' | tr -d "'" | sort -u | wc -l)

# Iterate over each VLAN ID configuration
i=0
while [ $i -lt $NoOfVLANID ]
do
    # Get the VLAN ID for the current redirect
    VLANID=$(uci get portbasedvlanconfig.@redirect[$i].vlanid)
    
    # Iterate over the ports (port0 to port4 --> depends on port number count.) either it is tagged or untagged with its Vlan ID
    for port in $PORT
    do
        port_info=$(uci get portbasedvlanconfig.@redirect[$i].$port)
        
        if [ "$port_info" = "tagged" ] || [ "$port_info" = "untagged" ]
        then
            echo "$port is $port_info for VLAN ID $VLANID" >> "$port_details"
        fi
        
    done

    # Increment the loop counter
    i=$((i + 1))
done

# If port is untagged then its type is WAN or LAN (Multiple untagged is not possible in same port)
# IF port is tagged then its type is LAN only (Multiple tagged is possible in same port)
# Iterate over the ports (port0 to port4 --> depends on port number count.) either it is configure as LAN or WAN
# It is possible that Same port is work as a LAN and WAN both with unique VLANID
for port in $PORT
do 

	#Check port is tagged first and get its vlanid...
	#If Multple tagged is there then we take only first vlanid beacuse tagged port are all type LAN...
	vlanid=$(grep -i "$port is tagged" "$port_details" | cut -d 'D' -f 2 | cut -d ' ' -f 2 | head -n 1)
	
	#If vlanid is have some value then we check its type
	if [ -n "$vlanid" ];then
		interface=$(uci show networkinterfaces | grep -w "eth0.$vlanid" | cut -d '.' -f 2)
		type=$(uci get networkinterfaces.$interface.type)
		echo "${port}_name"="$type" >> "$port_details"
		
		#check port is untagged with type WAN
		VlanID=$(grep -i "$port is untagged" "$port_details" | cut -d 'D' -f 2 | cut -d ' ' -f 2)
		Interface=$(uci show networkinterfaces | grep -w "eth0.$VlanID" | cut -d '.' -f 2)
		Type=$(uci get networkinterfaces.$Interface.type)
		if [ "$Type" = "WAN" ] && [ "$type" = "LAN" ];then
			echo "${port}_name"="$Type" >> "$port_details"
		fi
	#If vlanid is empty then we check port is untagged with type (LAN or WAN)
	else
		vlanid=$(grep -i "$port is untagged" "$port_details" | cut -d 'D' -f 2 | cut -d ' ' -f 2)
		interface=$(uci show networkinterfaces | grep -w "eth0.$vlanid" | cut -d '.' -f 2)
		type=$(uci get networkinterfaces.$interface.type)
		if [ -n "$type" ];then
			echo "${port}_name"="$type" >> "$port_details"
		else
			echo "${port}_name"="off" >> "$port_details"
		fi
	fi
	
done

# Function to get link status details for a given port number
get_link_details() {
    local port_number="$1"
    local response=$(swconfig dev switch0 port "$port_number" get link)

    # Extracting parameters from the response using POSIX regex
    local link=$(echo "$response" | grep -o 'link\s*:\s*\S*' | cut -d ":" -f 2)
    local speed=$(echo "$response" | grep -o 'speed\s*:\s*\S*' | cut -d ":" -f 2)
    local duplex=$(echo "$response"  | cut -d " " -f 4)
	
	# If link is down...
	if [ "$link" = "down" ];then	
		speed="NA"
		duplex="NA"
	# If link is empty...
	elif [ -z "$link" ];then
		port_number="NA"
		link="NA"
		speed="NA"
		duplex="NA"
	fi
	
    # Store the extracted values in variables based on port number
    case "$port_number" in
        0)
	    echo "port0_number=$port_number" >> "$port_details"	
            echo "port0_link_status=$link" >> "$port_details"
            echo "port0_speed=$speed" >> "$port_details"
            echo "port0_duplex=$duplex" >> "$port_details"
            ;;
        1)
	    echo "port1_number=$port_number" >> "$port_details"	
            echo "port1_link_status=$link" >> "$port_details"
            echo "port1_speed=$speed" >> "$port_details"
            echo "port1_duplex=$duplex" >> "$port_details"
            ;;
        2)
	    echo "port2_number=$port_number" >> "$port_details"	
            echo "port2_link_status=$link" >> "$port_details"
            echo "port2_speed=$speed" >> "$port_details"
            echo "port2_duplex=$duplex" >> "$port_details"
            ;;
        3)
	    echo "port3_number=$port_number" >> "$port_details"	
            echo "port3_link_status=$link" >> "$port_details"
            echo "port3_speed=$speed" >> "$port_details"
            echo "port3_duplex=$duplex" >> "$port_details"
            ;;
        4)
	    echo "port4_number=$port_number" >> "$port_details"	
            echo "port4_link_status=$link" >> "$port_details"
            echo "port4_speed=$speed" >> "$port_details"
            echo "port4_duplex=$duplex" >> "$port_details"
            ;;
        *)
            echo "Unsupported port number: $port_number"
            ;;
    esac
}

# Loop through ports $port_number and get link details
for port_number in $port_number
do
    get_link_details "$port_number"
done

exit 0    	
