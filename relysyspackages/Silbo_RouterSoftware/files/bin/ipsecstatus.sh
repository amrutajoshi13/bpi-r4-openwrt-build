#!/bin/sh

. /lib/functions.sh

connections=$(awk '/^conn/ {print $2}' /var/ipsec/ipsec.conf)

echo "$connections" > /tmp/ipsec.txt

connections_file="/tmp/ipsec.txt"

processed_clients=""
total_installed_count=0
total_established_count=0

if [ -e "$connections_file" ]; then
    while IFS= read -r connection; do

        #echo "Processing connection: $connection"

        status=$(ipsec status "$connection" | grep -E INSTALLED | cut -d " " -f 3 -s | tr -d ',')
        status1=$(ipsec status "$connection" | grep -E ESTABLISHED | cut -d " " -f 2 -s)

        client_name=$(echo "$connection" | cut -d '-' -f 1)
        #echo "Processing client: $client_name"

        installed_var="installed_count_$client_name"
        established_var="established_count_$client_name"

        if [[ $status == "INSTALLED" ]]; then
            #echo "INSTALLED"
            eval "$installed_var=\$((\$$installed_var + 1))"
            total_installed_count=$((total_installed_count + 1))
        fi

        if [[ $status1 == "ESTABLISHED" ]]; then
            #echo "ESTABLISHED"
            eval "$established_var=\$((\$$established_var + 1))"
            total_established_count=$((total_established_count + 1))
        fi

        # Check if the client has already been processed
        if ! echo "$processed_clients" | grep -q -w "$client_name"; then
            processed_clients="$processed_clients $client_name"
        fi
    done < "$connections_file"

    # Print the counts for each client
    for client in $processed_clients; do
        installed_var="installed_count_$client"
        established_var="established_count_$client"
        A=$(echo "$client" | cut -d '-' -f 1)
        
        #echo $($installed_var)
        #echo $($established_var)

eval "echo \"\$A - Installed Count: \${$installed_var}, Established Count: \${$established_var}\""   
#echo "$A - Total INSTALLED Count: ${!installed_var}, Total ESTABLISHED Count: ${!established_var}"
    done > /tmp/ipsecconnections.txt
else
    echo "File not found: $connections_file"
fi

while IFS= read -r line; do

    client=$(echo "$line" | awk '{print $1}')
    installed_count=$(echo "$line" | awk -F ', ' '{print $1}' | awk -F ': ' '{print $2}')
    established_count=$(echo "$line" | awk -F ', ' '{print $2}' | awk -F ': ' '{print $2}')

    Name=$client
    InstalledCount=$installed_count 
    EstablishedCount=$established_count

    Localsubnets=$(uci get vpnconfig1.$Name.nooflocalsubnets)
    Remotesubnets=$(uci get vpnconfig1.$Name.noofremotesubnets)
    Connectionprotocol=$(uci get vpnconfig1.$Name.connectionprotocol)
    Connectiontype=$(uci get vpnconfig1.$Name.connectiontype)

    # echo The value of $Localsubnets
    # echo The value of $Remotesubnets
    # echo The installed is $InstalledCount
    # echo the estrablished count is $EstablishedCount

    # Multiply local and remote subnet counts

    if [ "$Connectiontype" = "tunnel" ]; then
	# Tunnel configuration
        expected_count=$(($Localsubnets * $Remotesubnets))

        echo the value of expected_count $expected_count

        # Compare expected with actual installed and established count
        if [ "$installed_count" -eq "$expected_count" ] && [ "$established_count" -eq "$expected_count" ]; then
            
            uci set vpnconfig1.$Name.status="UP"
            #echo "Status: UP"
        else
            uci set vpnconfig1.$Name.status="DOWN"
            #/root/InterfaceManager/script/IpsecRestart.sh
        # echo "Status: DOWN"
        fi
	

    elif [ "$Connectiontype" = "transport" ]; then
        # Transport configuration

          # Compare expected with actual installed and established count
        if [ "$installed_count" -eq "$established_count" ]; then
            
            uci set vpnconfig1.$Name.status="UP"
            #echo "Status: UP"
        else
            uci set vpnconfig1.$Name.status="DOWN"
            #/root/InterfaceManager/script/IpsecRestart.sh
        # echo "Status: DOWN"
        fi
        
    fi


    if [ "$installed_count" -eq "$established_count" ]; then
        
       #echo "$Name: Installed Count:$InstalledCount is equal to Established Count:$EstablishedCount"

       uci set vpnconfig1.$Name.installed_count=$InstalledCount
       uci set vpnconfig1.$Name.established_count=$EstablishedCount

    elif [ "$established_count" -gt "$installed_count" ]; then 

       #echo "$Name: established_count is greater than to established_count"                                
                                                                              
       uci set vpnconfig1.$Name.installed_count=$InstalledCount               
       uci set vpnconfig1.$Name.established_count=$EstablishedCount 
 
    else
       
       #echo "$Name: $InstalledCount is not equal to $established_count"    

       uci set vpnconfig1.$Name.installed_count=$InstalledCount                         
       uci set vpnconfig1.$Name.established_count=$EstablishedCount   
fi
#uci set vpnconfig1.Client1.installed_count=2
uci commit vpnconfig1

#echo If the value is same $client 
done < /tmp/ipsecconnections.txt

