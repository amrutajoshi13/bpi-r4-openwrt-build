#!/bin/sh

source /usr/local/bin/Testscripts/Testresult/output_file.txt

source /usr/local/bin/Testscripts/RF44Config.cfg

RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[0;37m'
mac_path="/usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt"
outputfile2path="/usr/local/bin/Testscripts/Testresult/output_file.txt"

imei=$(cat "$mac_path" | grep "The IMEI number is" | cut -d "-" -f 2)
wan_mac_addr=$(cat "$mac_path" | grep "The wan mac addr is" | cut -d "-" -f 2)
wifi_mac_addr=$(cat "$mac_path" | grep "The wifi mac addr is" | cut -d "-" -f 2)
serial_number_line=$(grep "The serial number is" "$mac_path")
serial_number=$(echo "$serial_number_line" | awk '{print $NF}')
filename=${serial_number:0}.txt
test_status1="Not Enabled"
file="/usr/local/bin/Testscripts/Testresult/$filename"

echo " "
echo "===================================================================================== 
                                    DEVICE REBOOT TEST
===================================================================================== " 



uptime=$(awk '{print $1}' /proc/uptime)
echo "$uptime"
time_stamp=$(date)
res15=n
if [ $(awk -v uptime="$uptime" 'BEGIN {print (uptime < 180) ? "1" : "0"}') -eq 1 ]; then
    echo "[$time_stamp]	        REBOOT TEST = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
	res15=y
	result="PASS"
     
else
    echo "[$time_stamp]	        REBOOT TEST = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
	res15=n
	result="FAIL"
fi
echo "Reboot Test=$result" >> "$outputfile2path"

echo "=====================================================================================                                                   
                                 BOARD TEST                                                                                                   
====================================================================================="  
if [ "$res1" = "y" ] && [ "$res2" = "y" ] && [ "$res3" = "y" ] && [ "$res4" = "y" ] && [ "$res5" = "y" ] && [ "$res6" = "y" ] && [ "$res7" = "y" ] && [ "$res8" = "y" ] && [ "$res9" = "y" ] && [ "$res10" = "y" ] && [ "$res11" = "y" ] && [ "$res12" = "y" ] && [ "$res13" = "y" ] && [ "$res14" = "y" ] && [ "$res15" = "y" ]; then
	
	echo "[$time_stamp]	        Board Test status = Pass" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
	
else
	echo "[$time_stamp]	        Board Test status = Fail" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
fi 

echo " "
#cat /usr/local/bin/Testscripts/Testresult/$filename
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

device_path="/tmp/sysinfo/board_name"
device_name=$(cat "$device_path")

if echo "$device_name" | grep -q "Silbo_RF44-A_GW"; then
	if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
		device_name="Silbo_RF44R-A_GW"
	else
		device_name="Silbo_RF04R-A_GW"
	fi
fi


if echo "$device_name" | grep -q "Silbo_RF44-B_GW"; then
	if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
		device_name="Silbo_RF44R-B_GW"
	else
		device_name="Silbo_RF04R-B_GW"
	fi

fi

if echo "$device_name" | grep -q "Silbo_RF44-C_GW"; then
	if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
		device_name="Silbo_RF44R-C_GW"
	else
		device_name="Silbo_RF04R-C_GW"
	fi
fi

wifi_enable_disable=$(cat "$outputfile2path" | grep "wifi_enable_disable" | cut -d "=" -f 2 | tr -d '"')

if echo "$device_name" | grep -q "_GW"; then
	devicetype="Gateway"
else
	devicetype="Router"
fi

model_path="/tmp/sysinfo/model"
device_model=$(cat "$model_path")

if echo "$device_model" | grep -q "Silbo_RF44-A_GW"; then
	if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
		device_model="Silbo_RF44R-A_GW"
	else
		device_model="Silbo_RF04R-A_GW"
	fi

fi


if echo "$device_model" | grep -q "Silbo_RF44-B_GW"; then

	if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
		device_model="Silbo_RF44R-B_GW"
	else
		device_model="Silbo_RF04R-B_GW"
	fi
fi

if echo "$device_model" | grep -q "Silbo_RF44-C_GW"; then
	
	if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
		device_model="Silbo_RF44R-C_GW"
	else
		device_model="Silbo_RF04R-C_GW"
	fi
fi

wan_mac_address=$(cat "$file" | grep "The wan mac addr is" | cut -d "-" -f 2 | tr -d ' ')

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	wifi_mac_address=$(cat "$file" | grep "The wifi mac addr is" | cut -d "-" -f 2 | tr -d ' ')
else
	wifi_mac_address="$test_status1"
fi

imei_no=$(cat "$file" | grep "The IMEI number is" | cut -d "-" -f 2 | tr -d '\007\010\011\012\013\014\015')

modemname=$(cat "$file" | grep "Modem name" | cut -d "=" -f 2 | tr -d '\007\010\011\012\013\014\015')

firmware_version=$(cat "$file" | grep "Firmware version of modem" | cut -d "=" -f 2 | tr -d '\007\010\011\012\013\014\015')

qccid1=$(grep "qccid1=" "$outputfile2path" | cut -d '=' -f 2 | tr -d ' ' | tr -d '\007\010\011\012\013\014\015')


sim_strength_test=$(cat "$file" | grep "Sim signal strength test" | cut -d "=" -f 2 | tr -d ' ')

sim1_strength=$(cat "$file" | grep "Signal strength" | cut -d "=" -f 2 | tr -d ' ' | head -1)


ping_test1=$(cat "$file" | grep "Ethernet Ping Test" | cut -d "=" -f 2 | tr -d ' ')

modem_test=$(cat "$file" | grep "Modem Ping Test" | cut -d "=" -f 2 | tr -d ' ')

modem_on_off_test=$(cat "$file" | grep "MODEM ON and OFF test" | cut -d "=" -f 2 | tr -d ' ')

switch_test=$(cat "$file" | grep "RESET BUTTON TEST" | cut -d "=" -f 2 | tr -d ' ')

if [ "$rtc_test" = "y" ]; then
	rtc_test_status=$(cat "$file" | grep "RTC test" | cut -d "=" -f 2 | tr -d ' ')
	
	rtc_value=$(cat "$outputfile2path" | grep "rtc_value" | cut -d "=" -f 2 | tr -d '"')
	
else
	rtc_test_status="$test_status1"
	rtc_value="$test_status1"
fi

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	wifi_test=$(grep -o 'WIFI Test = [^ ]*' "$file" | cut -d "=" -f 2 | tr -d ' ')
	wifi_signal_strength=$(grep -o 'Wifi signal strength = [^ ]*' "$file" | cut -d "=" -f 2 | tr -d ' ')
	wifi_signal_strength_with_unit="$wifi_signal_strength dBm"
else
	wifi_test="$test_status1"
	wifi_signal_strength_with_unit="$test_status1"
fi

AT_test=$(cat "$file" | grep "AT commands" | cut -d "=" -f 2 | tr -d ' ')

reboot_test=$(grep "Reboot Test=" "$outputfile2path" | cut -d '=' -f 2 | tr -d ' ')

if [ "$nms_test" = "y" ]; then
	nms_test_status=$(cat "$file" | grep "NMS Registration Test" | cut -d "=" -f 2 | tr -d ' ')
	nms_ip=$(grep "tunip=" "$outputfile2path" | awk -F= '{print $2}')
	nms_url=$(grep "nms_url=" "$outputfile2path" | awk -F= '{print $2}')
else
	nms_test_status="$test_status1"
	nms_ip="$test_status1"
	nms_url="$test_status1"
fi

if [ "$rs485_test" = "y" ]; then
	rs485=$(cat "$file" | grep "RS485 test" | cut -d "=" -f 2 | tr -d ' ')
else
	rs485="$test_status1"
fi

if [ "$rs232_test" = "y" ]; then
	rs232=$(cat "$file" | grep "RS232 test" | cut -d "=" -f 2 | tr -d ' ')
else
	rs232="$test_status1"
fi

board_test=$(cat "$file" | grep "Board Test status" | cut -d "=" -f 2 | tr -d ' ')

rm -f /root/.ssh/known_hosts
status=0
if [ "$res1" = "y" ] && [ "$res2" = "y" ] && [ "$res3" = "y" ] && [ "$res4" = "y" ] && [ "$res5" = "y" ] && [ "$res6" = "y" ] && [ "$res7" = "y" ] && [ "$res8" = "y" ] && [ "$res9" = "y" ] && [ "$res10" = "y" ] && [ "$res11" = "y" ] && [ "$res12" = "y" ] && [ "$res13" = "y" ] && [ "$res14" = "y" ] && [ "$res15" = "y" ]; then
	
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
    "wifi_mac": "$wifi_mac_address",
    "at_commands_test_result": "$AT_test",
    "imei_number_for_modem": "$imei_no",
    "qccid_for_sim1": "$qccid1",
    "sim1_signal_strength": "$sim1_strength", 
    "sim1_signal_strength_test_result": "$sim_strength_test",
    "lan1_ping_status": "$ping_test1",
    "modem_name": "$modemname",
    "modem_firmware_version": "$firmware_version", 
    "modem_ping_test_status": "$modem_test",
    "modem_on_off_test_status":"$modem_on_off_test",
    "reset_switch_test_status": "$switch_test",
    "rtc_test_status":"$rtc_test_status",
    "rtc_value":"$rtc_value",
    "wifi_test_status": "$wifi_test",
    "wifi_signal_strength": "$wifi_signal_strength_with_unit",
    "rs485_test_status":"$rs485",
    "rs232_test_status":"$rs232",
    "nms_test_status":"$nms_test_status",
    "nms_url":"$nms_url",
    "device_vpn_ip":"$nms_ip",
    "reboot_status":"$reboot_test",
    "record_type":"1"
  }
}
EOF
)
echo "$data"
max_attempts=5
attempts=0

while [ $attempts -lt $max_attempts ]; do
    if ping -c 1 -W 2 "139.59.65.241:9000" &> /dev/null; then
        echo "Server is reachable. Sending data..."
        curl --data "$data" -v http://139.59.65.241:9000/api/save_data/
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

if [ "$status" = 1 ];then
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
