#!/bin/sh

if [ $# -ne 2 ]; then
        echo "Usage: new_nms <newurl> <newkey>"
        exit 1
fi
    newurl=$1
    newkey=$2

touch /root/oldnmsurl
oldurl=$(grep "option url" /etc/config/openwisp | awk -F"'" '{print $2}')
echo "$oldurl" > /root/oldnmsurl
url=$(cat /root/oldnmsurl)
echo "$url"
sleep 5
 
key=$(cat /root/oldnmskey)
echo "$key"

# Function to disable NMS
        disable_nms() {
            uci set remoteconfig.general.rmsoption="none"
            uci set remoteconfig.nms.nmsenable="0"
		    sleep 2
            uci commit remoteconfig
            sleep 5
            sh /root/InterfaceManager/script/Disable_Nms.sh
            sleep 10
        }

#function to register new NMS
        modified_nms() {
            counter=0
            while [ $counter -lt 3 ]; 
            do                                 
                sh /root/NMS_Scripts/Register_NMS.sh "$newurl" "$newkey"
                sleep 30
                # check tunnel will come or not
                tunip=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')
                if [ -n "$tunip" ]; then
                    echo "Device registered............"
                   
                    rm /root/oldnmsurl
                    rm /root/oldnmskey
                    return 0
                fi
                counter=$((counter + 1))
            done
            # If the loop didn't succeed after three attempts, execute with oldurl and oldkey
            sh /root/NMS_Scripts/Register_NMS.sh "$url"  "$key"
            # ccheck tunnel is up or not oldurl&oldkey
                tunip=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')
                if [ -n "$tunip" ]; then
                    echo "Device registered olderurl & olderkey..........."
                    rm /root/oldnmsurl
                    rm /root/oldnmskey
                    return 0
                fi
        }

#new server ping
ip=$(echo "$newurl" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
PacketLoss=$(ping  -c 5 $ip | grep "packet loss" | cut -d "," -f 3 | tr -d " " | cut -d "%" -f 1)
if [ "$PacketLoss" -eq 0 ]; 
    then
        disable_nms
        modified_nms
    else
        exit 0 
fi


    

