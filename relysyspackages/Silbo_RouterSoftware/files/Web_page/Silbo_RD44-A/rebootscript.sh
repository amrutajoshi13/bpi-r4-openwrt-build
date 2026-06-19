#!/bin/sh

source /usr/local/bin/Testscripts/Testresult/output_file.txt

RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
outputfilepath="/usr/local/bin/Testscripts/Testresult/output_file.txt"
outputfile2path="/usr/local/bin/Testscripts/Testresult/output2_file.txt"
mac_path="/usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt"
serial_number_line=$(grep "The serial number is" "$mac_path")
serial_number=$(echo "$serial_number_line" | awk '{print $NF}')
filename=${serial_number:0}.txt
file="/usr/local/bin/Testscripts/Testresult/$filename"
test_status="NA"
test_status1="Not Enabled"

echo " "
echo "===================================================================================== 
                                    DEVICE REBOOT TEST
===================================================================================== " 



uptime=$(awk '{print $1}' /proc/uptime)
echo "$uptime"
time_stamp=$(date)
res17=n
if [ $(awk -v uptime="$uptime" 'BEGIN {print (uptime < 180) ? "1" : "0"}') -eq 1 ]; then
	echo -e "\e[1;32m [$time_stamp] REBOOT TEST = PASS \e[0m" 
    a=$(echo "[$time_stamp]  REBOOT TEST = PASS " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res17=y
	result="PASS"
     
else
	echo -e "\e[1;31m [$time_stamp]	REBOOT TEST = FAIL \e[0m"
    a=$(echo "[$time_stamp]  REBOOT TEST = FAIL " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res17=n
	result="FAIL"
fi

echo "=====================================================================================                                                   
                                 BOARD TEST                                                                                                   
====================================================================================="  
if [ "$res1" = "y" ] && [ "$res2" = "y" ] && [ "$res3" = "y" ] && [ "$res4" = "y" ] && [ "$res5" = "y" ] && [ "$res6" = "y" ] && [ "$res7" = "y" ] && [ "$res8" = "y" ]  && [ "$res9" = "y" ] && [ "$res10" = "y" ] && [ "$res11" = "y" ] && [ "$res12" = "y" ] && [ "$res13" = "y" ] && [ "$res14" = "y" ] && [ "$res15" = "y" ] && [ "$res16" = "y" ] && [ "$res17" = "y" ]; then
 
	echo -e "\e[1;32m [$time_stamp]	Board Test status = PASS \e[0m"
    a=$(echo -e "[$time_stamp]  Board Test status = Pass" | tee -a "/usr/local/bin/Testscripts/Testresult/$filename")
	
else
    echo -e "\e[1;31m [$time_stamp]	Board Test status = FAIL \e[0m"
	a=$(echo "[$time_stamp]  Board Test status = Fail" | tee -a "/usr/local/bin/Testscripts/Testresult/$filename")

fi 

echo " "
echo " "
echo " "
echo " "


for i in $(ls /usr/local/bin/Testscripts/Testresult/Pass)
do 
	rm /usr/local/bin/Testscripts/Testresult/Pass/$i
done

for i in $(ls /usr/local/bin/Testscripts/Testresult/Fail)
do 
	rm /usr/local/bin/Testscripts/Testresult/Fail/$i
done

wifi_enable_disable=$(cat "$outputfilepath" | grep "wifi_enable_disable" | cut -d "=" -f 2 | tr -d '"')

device_path="/tmp/sysinfo/board_name"
device_name=$(cat "$device_path")

model_path="/tmp/sysinfo/model"
device_model=$(cat "$model_path")

wan_mac_address=$(cat "$file" | grep "The wan mac addr is" | cut -d "-" -f 2 | tr -d ' ')

lan_mac_address=$(cat "$file" | grep "The lan mac addr is" | cut -d "-" -f 2 | tr -d ' ')

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	wifi_mac_address=$(cat "$file" | grep "The wifi mac addr is" | cut -d "-" -f 2 | tr -d ' ')
else
	wifi_mac_address="$test_status"
fi
imei_no=$(cat "$file" | grep "The IMEI number is" | cut -d "-" -f 2 | tr -d ' ')

modemname=$(cat "$file" | grep "Modem name" | cut -d "=" -f 2 | tr -d ' ')

modemmodel=$(cat "$file" | grep "Modem =" | cut -d "=" -f 2 | tr -d ' ')

firmware_version=$(grep "Modem firmware version" "$file" | awk -F ': ' '{print $2}' | tr -d ' ')

qccid1=$(cat "$file" | grep "QCCID for sim1" | cut -d "=" -f 2 | tr -d ' ' | tr -d '\007\010\011\012\013\014\015')
 
#qccid2=$(grep "qccid2=" "$outputfilepath" | cut -d '=' -f 2 | tr -d ' ' | tr -d '\007\010\011\012\013\014\015')
qccid2=$(cat "$file" | grep "QCCID for sim2" | cut -d "=" -f 2 | tr -d ' ' | tr -d '\007\010\011\012\013\014\015')

sim_strength_test=$(cat "$file" | grep -E "Sim[12] signal strength test" | cut -d "=" -f 2 | tr -d ' ')

sim1_strength=$(cat "$file" | grep "Sim[12] signal strength" | cut -d "=" -f 2 | tr -d ' ' | head -1)

ping_test1=$(cat "$file" | grep "Ethernet 1 Ping Test" | cut -d "=" -f 2 | tr -d ' ')

ping_test2=$(cat "$file" | grep "Ethernet 2 Ping Test" | cut -d "=" -f 2 | tr -d ' ')

ping_test3=$(cat "$file" | grep "Ethernet 3 Ping Test" | cut -d "=" -f 2 | tr -d ' ')

ping_test4=$(cat "$file" | grep "Ethernet 4 Ping Test" | cut -d "=" -f 2 | tr -d ' ')

wan_test=$(cat "$file" | grep "WAN port Ping Test" | cut -d "=" -f 2 | tr -d ' ')

modem_test=$(cat "$file" | grep "Modem Ping Test" | cut -d "=" -f 2 | tr -d ' ')

gpio_test=$(cat "$file" | grep "Sim switching through gpio test" | cut -d "=" -f 2 | tr -d ' ')

rtc_test=$(cat "$file" | grep "RTC test" | cut -d "=" -f 2 | tr -d ' ')

rtc_value=$(grep "rtc_time=" "$outputfile2path" | awk -F= '{print $2}')

switch_test=$(cat "$file" | grep "Reset Switch test" | cut -d "=" -f 2 | tr -d ' ')

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	wifi_test=$(grep -o 'WIFI Test = [^ ]*' "$file" | cut -d "=" -f 2 | tr -d ' ')
	wifi_signal_strength=$(grep -o 'Wifi signal strength = [^ ]*' "$file" | cut -d "=" -f 2 | tr -d ' ')
	wifi_signal_strength_with_unit="$wifi_signal_strength dBm"
else
	wifi_test="$test_status"
	wifi_signal_strength_with_unit="$test_status"
fi

led_test=$(cat "$file" | grep "LED test" | cut -d "=" -f 2 | tr -d ' ')

AT_test=$(cat "$file" | grep "AT commands" | cut -d "=" -f 2 | tr -d ' ')

devicetype="Router"
#reboot_test=$(grep "Reboot Test=" "$outputfile2path" | cut -d '=' -f 2 | tr -d ' ')

if [ "$nms_test" = "y" ]; then
	nms_test_status=$(cat "$file" | grep "NMS Registration Test" | cut -d "=" -f 2 | tr -d ' ')
	nms_ip=$(grep "tunip=" "$outputfilepath" | awk -F= '{print $2}')
	nms_url=$(grep "nms_url=" "$outputfilepath" | awk -F= '{print $2}')
else
	nms_test_status="$test_status1"
	nms_ip="$test_status1"
	nms_url="$test_status1"
fi

board_test=$(cat "$file" | grep "Board Test status" | cut -d "=" -f 2 | tr -d ' ')

rm -f /root/.ssh/known_hosts
status=0

if [ "$res1" = "y" ] && [ "$res2" = "y" ] && [ "$res3" = "y" ] && [ "$res4" = "y" ] && [ "$res5" = "y" ] && [ "$res6" = "y" ] && [ "$res7" = "y" ] && [ "$res8" = "y" ]  && [ "$res9" = "y" ] && [ "$res10" = "y" ] && [ "$res11" = "y" ] && [ "$res12" = "y" ] && [ "$res13" = "y" ] && [ "$res14" = "y" ] && [ "$res15" = "y" ] && [ "$res16" = "y" ] && [ "$res17" = "y" ]; then
	
	mv /usr/local/bin/Testscripts/Testresult/$filename /usr/local/bin/Testscripts/Testresult/Pass/$filename
	status=1
else
	mv /usr/local/bin/Testscripts/Testresult/$filename /usr/local/bin/Testscripts/Testresult/Fail/$filename	
	status=2
fi 
sleep 2
echo "SENDING DATA TO SERVER.........."


data=$(cat <<EOF
{
 "device_id": "$serial_number",
  "device_type": "$devicetype",
  "device_model": "$device_model",
  "testing_time": "$time_stamp",
  "board_test_status":"$board_test",
  "json_data": {
    "device_id": "$serial_number",
    "device_type": "$devicetype",
    "device_model":"$device_model",
    "testing_time": "$time_stamp",
    "board_test_status":"$board_test",
    "board_name": "$device_name",
    "wan_mac": "$wan_mac_address",
    "lan_mac": "$lan_mac_address",
    "wifi_mac":"$wifi_mac_address",
    "at_commands_test_result": "$AT_test",
    "imei_number_for_modem_1": "$imei_no",
    "modem_name": "$modemname",
    "modem_model": "$modemmodel",
    "qccid_for_sim1": "$qccid1",
    "sim_signal_strength": "$sim1_strength", 
    "sim_signal_strength_test_result": "$sim_strength_test",
    "qccid_for_sim2": "$qccid2",
    "lan1_ping_status": "$ping_test1",
    "lan2_ping_status": "$ping_test2",
    "lan3_ping_status":"$ping_test3",
    "lan4_ping_status":"$ping_test4",
    "wan_ping status": "$wan_test",
    "modem_firmware_version": "$firmware_version", 
    "modem_ping_status": "$modem_test",
    "rtc_test_status": "$rtc_test",
    "rtc_value": "$rtc_value",
    "reset_switch_test_status": "$switch_test",
    "wifi_test_status":"$wifi_test",
    "wifi_signal_strength":"$wifi_signal_strength_with_unit",
    "led_test_status": "$led_test",
    "nms_test_status":"$nms_test_status",
    "nms_url":"$nms_url",
    "device_vpn_ip":"$nms_ip",
    "reboot_status":"$result",
    "record_type":"1"
  }
}
EOF
)
echo "$data"
max_attempts=5
attempts=0

while [ $attempts -lt $max_attempts ]; do
    if ping -c 1 -W 2 "productionapp.silbo.co.in" &> /dev/null; then
        echo "Server is reachable. Sending data..."
        curl --data "$data" -v http://productionapp.silbo.co.in/api/save_data/
        break  # exit the loop once data is sent
    else
        echo "Server is not reachable. Retrying in 10 seconds (attempt $((attempts + 1)) of $max_attempts)..."
        sleep 10
        attempts=$((attempts+1))
    fi
done

if [ $attempts -eq $max_attempts ]; then
    echo "Failed to send data after $max_attempts attempts. Exiting with an error."
fi
sleep 3
echo " "
echo "=====================================================================================
			        DISPLAYING REPORT 
===================================================================================== "

if [ $status = 1 ];then
	cat /usr/local/bin/Testscripts/Testresult/Pass/$filename
	
echo -e "\e[32m ==============================================
 ____   _    ____ ____  
|  _ \ / \  / ___/ ___| 
| |_) / _ \ \___ \___ \ 
|  __/ ___ \ ___) |__) |
|_| /_/   \_\____/____/ 
                        
==============================================\e[0m"
else
	cat /usr/local/bin/Testscripts/Testresult/Fail/$filename
	
echo -e "\e[31m==============================================
 ____	 _____ _       
|  ___/ \  |_ _| |    
| |_ / _ \  | || |    
|  _/ ___ \ | || |___ 
|_|/_/   \_\___|_____|

==============================================\e[0m"
fi
