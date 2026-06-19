#!/bin/sh

. /lib/functions.sh

source /usr/local/bin/Testscripts/RF44Config.cfg

source /Web_Page_Gateway_Apps/Board_info.txt

wifi_enable_disable=$(hexdump -v -n 1 -s 0x61 -e '7/1 "%01X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')

wifi_enable_disable=$(echo "$wifi_enable_disable" | tr -d '\013\014\015 ')
	  	
wan_mac_addr=$(hexdump -v -n 6 -s 0x28 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
serial_n=$(hexdump -v -n 6 -s 0x100 -e '5/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
if [ "$wifi_enable_disable" = "1" ]; then 
	wifi_mac_addr=$(hexdump -v -n 6 -s 0x4 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
fi

imei_n=$(hexdump -v -n 8 -s 0x110 -e '7/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
imei=${imei_n:0}


if [ -e /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt ]
then 
	rm /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt 
fi
time_stamp=$(date)

echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "[$time_stamp]" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The serial number is - $serial_n" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The IMEI number is - $imei" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The wan mac addr is - $wan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
if [ "$wifi_enable_disable" = "1" ]; then
	echo "The wifi mac addr is - $wifi_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
fi
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
serial_number=${serial_n:0}

board_name="$board_name"
filename=$serial_number

wifi_ssid="AP_$serial_number"
wifi_guest_ssid="AP_GUEST_$serial_number"

#Update the required parameters in config files.
uci set boardconfig.board.serialnum=$serial_number
uci set boardconfig.board.wanmacid=$wan_mac_addr
if [ "$wifi_enable_disable" = "1" ]; then
    uci set boardconfig.board.wifimacid=$wifi_mac_addr
fi
uci set boardconfig.board.imei=$imei
uci commit boardconfig

sleep 1

cp /etc/config/boardconfig /root/InterfaceManager/config/boardconfig

sleep 1

uci set sysconfig.sysconfig.wifi1ssid=$wifi_ssid
uci commit sysconfig

sleep 1

uci set system.system.hostname=$serial_number
uci commit system

sleep 1

uci set wireless.ap.ssid=$wifi_ssid
uci commit wireless

uci set sysconfig.sysconfig.port5macid=$wan_mac_addr
uci set network.LAN.macaddr=$wan_mac_addr
uci commit sysconfig
uci commit network

sleep 1

#Update SSID in mt7628.dat file.
wirelessdatfile="/etc/wireless/mt7628/mt7628.dat"
ssid=$(grep -w "SSID1" ${wirelessdatfile})        
ssid_replace="SSID1=$wifi_ssid"
sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"

ssid_guest=$(grep -w "SSID2" ${wirelessdatfile})        
ssid_guest_replace="SSID2=$wifi_guest_ssid"
sed -i "s/${ssid_guest}/${ssid_guest_replace}/" "$wirelessdatfile"

cp /etc/wireless/mt7628/mt7628.dat /root/InterfaceManager/mt7628/mt7628.dat

sleep 2

uci set system.system.hostname=$serial_number
uci commit system
cp /etc/config/boardconfig /root/InterfaceManager/config/
cp /etc/config/system /root/InterfaceManager/config/
cp /etc/config/sysconfig /root/InterfaceManager/config/
cp /etc/config/network /root/InterfaceManager/config/

/etc/init.d/system restart

filename=$serial_number

cat /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt > /usr/local/bin/Testscripts/Testresult/$filename.txt
echo "wifi_enable_disable=$wifi_enable_disable" > "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$reset_button_test" = "y" ]; then

echo "=======================================================================
				RESET BUTTON TEST
======================================================================= "
echo " "

	echo "Testing switch"
	echo "Press and hold switch to observe the change in values"

	res1=n
	for i in $(seq 1 25);
	do
		check=$(cat /sys/class/gpio/gpio38/value)
		echo $check
		if [ $check -eq 0 ]
		then
			res1=y
			break
		fi
		sleep 1
	done

	echo ""
	echo ""

	time_stamp=$(date)
	case $res1 in
		[y] ) echo "[$time_stamp]		RESET BUTTON TEST = PASS " | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;break;;
   
		[n] ) echo  "[$time_stamp]		RESET BUTTON TEST = FAIL " | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;break;;
		* );;
	esac
else
	res1=y
fi

echo "res1=$res1" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo""
sleep 1

if [ "$usb_modem_test" = "y" ]; then
echo "=====================================================================================
                                USB:Modem Test
===================================================================================== "
	echo " "
	res8=n
	modem_status=$(lsusb -t | grep -e option | grep -o 480 |head -1)
	sleep 1
	if [ $modem_status = "480" ]
	then
			
			echo "[$time_stamp]		Modem/USB test=PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res8=y;
	else
			
			echo "[$time_stamp]		Modem/USB test=FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res8=n;

	fi
else
	res8=y
fi

echo "res8=$res8" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo ""


echo "=====================================================================================
				IMEI NUMBER & MODEM FIRMWARE VERSION 
===================================================================================== "
echo " "

res2=n
for j in $(seq 1 5)
do

    count_in=$(ls /dev | grep -i "ttyU" | wc -l)
    for k in $(seq 1 $count_in)
    do
	sleep 3
	i=$(ls /dev | grep -i "ttyU" | head -$k |tail -1)
	sleep 1
	ec1=$(/bin/at-cmd /dev/$i ati | head -3 |tail -1)

	if [[ -z $ec1 ]]
	then
	    continue
	fi

	sleep 3
	time_stamp=$(date)
	rev=$(/bin/at-cmd /dev/$i ati | grep -i "Revision")

	rev1=${rev:10:25}
	sleep 1
	echo "[$time_stamp]		Firmware version of modem = $rev1" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt

	time_stamp=$(date)
	echo "[$time_stamp]		Modem name= $ec1" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt

	res2=y
	break
    done
    if [ "$res2" = "y" ]
    then 
	break
    fi
done

echo ""
echo ""

time_stamp=$(date)
case $res2 in
    [y] ) echo "[$time_stamp]		AT commands = PASS " | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res2=y;break;;
    [n] ) echo "[$time_stamp]		AT commands = FAIL " | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res2=n;break;;
    * );;
esac

echo "res2=$res2" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "modem_version=$rev1" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo ""

echo ""
echo ""

if [ "$sim_test" = "y" ]; then

echo "===================================================================================== 
                                SIM$sim_print QCCID TEST
===================================================================================== "
	echo " "
	flag=0
	count=0
	res3=n
	qccid1=""
	while [ $flag -eq 0 ] && [ $count -ne 10 ]
	do
		sleep 2
		echo "Waiting for QCCID of sim$sim_print"
		count_in=$(ls /dev | grep -i "ttyU" | wc -l)
		for k in $(seq 1 $count_in)
		do
			i=$(ls /dev | grep -i "ttyU" | head -$k | tail -1)
        	qccid1=$(gcom -d /dev/$i -s /etc/gcom/atqccid_test.gcom | head -2 |tail -1 | cut -d " " -f 2)
		
		#checking whether qccid is empty or not
				if [[ -z $qccid1 ]]
				then
                	continue
				fi

		#checking whether the length of qccid is correct or not
			len_qccid1=$(echo ${#qccid1})
			if [ $len_qccid1 -eq 21 ]
			then
				time_stamp=$(date)
				res3=y
				echo "[$time_stamp]          QCCID for sim$sim_print = $qccid1" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
				echo "qccid1=$qccid1" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
				flag=1
        		break
			fi
		done
		count=$((count+1))
		if [ $count -eq 10 ] && [ $flag -eq 0 ]
		then
			time_stamp=$(date)
			res3=n
			echo -e "\e[1;31m [$time_stamp]	         QCCID for sim$sim_print = Not available \e[0m"
			a=$(echo "[$time_stamp]	QCCID for sim$sim_print = Not Available" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
		fi	
	done
else
   res3=y
fi

echo "res3=$res3" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"


if [ "$ethernet1" = "y" ]; then
echo "=====================================================================================
                                  LAN PING TEST
===================================================================================== "

	echo ""
	sleep 1
	echo "Pinging to 192.168.9.2 ...."
	res4=n
	time_stamp=$(date)
	packet=$(ping -I eth0 -c 4 192.168.9.2 | grep "packet loss" | awk -F ',' '{print $3}' | awk '{print $1}' | sed 's/.\{1\}$//')
	if [ $packet -lt 20 ]; then	
		echo "[$time_stamp]		LAN :$packet% packet loss. Ethernet Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res4=y;
	else
		echo "[$time_stamp]		LAN :$packet% packet loss. Ethernet Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res4=n;
		echo "Ethernet is down! Please check the ethernet connection .. "
	fi
else
	res4=y
fi
echo "res4=$res4" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo ""
echo ""

if [ "$modem_test" = "y" ]; then

echo "=====================================================================================
                               MODEM TEST
===================================================================================== "
	echo " "

	flag=0
	packet_usb=100
	sig_str=0
	res5=n
	res7=n

# Loop to check for devices
	for j in $(seq 5); do
		count=$(ls /dev | grep -i "ttyU" | wc -l)
		for k in $(seq 1 $count); do
			i=$(ls /dev | grep -i "ttyU" | head -$k | tail -1)
			ec1=$(/bin/at-cmd /dev/$i ati | head -3 | tail -1)
			if [[ -z $ec1 ]]; then
				continue
			fi
			for l in $(seq 1 3); do 
				sig_str=$(/bin/at-cmd /dev/$i at+csq | head -2 | tail -1 | cut -d " " -f 2 | cut -d "," -f 1)
				sleep 1
				if [ $sig_str -ge 15 ]; then
					time_stamp=$(date)
					echo "[$time_stamp]		Sim$sim_print signal strength test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
					res7=y
					break
				fi
				if [ $l -eq 3 ]; then 
					time_stamp=$(date)
					echo "[$time_stamp]		Sim$sim_print signal strength test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
					res7=n
					
				fi
			done

			ec1=${ec1:2:2}
			if [ $ec1 -eq 25 ]; then
				ipaddr=$(ifconfig wwan0 | grep "inet addr" | tr -s " " | cut -d " " -f 3 | cut -d ":" -f 2)
				packet_usb=$(ping -A -I wwan0 -c 40 8.8.8.8 | grep "packet loss" | cut -d "," -f 3 | tr -d " " | cut -d "%" -f 1)
				res5=y
				break
			else
				ipaddr=$(ifconfig usb0 | grep "inet addr" | tr -s " " | cut -d " " -f 3 | cut -d ":" -f 2)
				packet_usb=$(ping -A -I usb0 -c 40 8.8.8.8 | grep "packet loss" | cut -d "," -f 3 | tr -d " " | cut -d "%" -f 1)
				res5=y
				break
			fi
		done
		if [ $packet_usb -eq 0 ]; then
			break
		fi
	done

# Print modem IP address and signal strength
	time_stamp=$(date)
	echo "[$time_stamp]		Modem IP address = $ipaddr" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
	echo "[$time_stamp]		Signal strength = $sig_str" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
	echo ""
	echo "Pinging to 8.8.8.8"

	time_stamp=$(date)
	if [ $packet_usb -lt 10 ]; then
		echo "[$time_stamp]		MODEM:$packet_usb% packet loss. Modem Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
		res5=y
	else
		echo "[$time_stamp]		MODEM:$packet_usb% packet loss. Modem Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
		res5=n
	fi
else
	res5=y
	res7=y
fi

echo "res5=$res5" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res7=$res7" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$modem_on_off_test" = "y" ]; then
	echo " "
	echo " "
	echo " "
	echo "Testing MODEM ..."
	echo " "
	echo "======================="
	echo "MODEM1 - Power OFF..."
	echo "======================="
	echo 1 > /sys/class/gpio/gpio11/value
	sleep 3
	echo " "
	echo "Did LED D9 is turned OFF?(y/n)"
	read res6

	echo "======================="
	echo "MODEM1 - Power ON..."
	echo "======================="
	echo 0 > /sys/class/gpio/gpio11/value
	sleep 5

	case $res6 in
		[yY] ) echo "[$time_stamp]		MODEM ON and OFF test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res6=y;break;;
		[nN] ) echo "[$time_stamp]		MODEM ON and OFF test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res6=y;break;;
		* );;
	esac
else
	res6=y
fi
echo "res6=$res6" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"


sleep 1
echo ""
echo ""

if [ "$wifi_enable_disable" = "1" ]; then
echo "=======================================================================
				WIFI SIGNAL STRENGTH TEST 
======================================================================= "
	echo " "
	echo "Connect to WIFI Access point on the Phone & check the signal strength on WIfiman app."
	echo "Enter the signal strength --"
	read sigstr

	echo " "
	echo " "

	time_stamp=$(date)
	if [ $sigstr -le 35 ]; then	
		echo -e "\e[1;32m [$time_stamp] Wifi signal strength = -$sigstr dbm. WIFI Test = PASS \e[0m"
		a=$(echo "[$time_stamp]	        Wifi signal strength = -$sigstr dbm. WIFI Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
		res9=y;
	else
		echo -e "\e[1;31m [$time_stamp] Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	        Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
		res9=n;
	fi
else
	res9=y
fi

echo "res9=$res9" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo ""
echo ""


if [ "$rtc_test" = "y" ]; then
echo " "
echo "=====================================================================================
		                       RTC TEST 
===================================================================================== "
	res14=n
	hwclock -w
	for i in $(seq 1 1000)
	do
		sys_time=$(date | cut -d " " -f 1,2,3,4 | cut -d ":" -f 1,2)
		rtc_time=$(/sbin/hwclock -r | cut -d " " -f 1,2,3,4 | cut -d ":" -f 1,2)

		if [ "$sys_time" = "$rtc_time" ]
		then 
			res14=y
			break
		fi
	done
	time_stamp=$(date)
	if [ "$res14" = "y" ]
	then
		echo -e "\e[1;32m [$time_stamp]	RTC test = PASS \e[0m"
		a=$(echo "[$time_stamp]          RTC test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
	else
		echo -e "\e[1;31m [$time_stamp]	RTC test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	         RTC test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
	fi
	rtc_value=$(hwclock -r | cut -d " " -f 1,2,3,4 | cut -d ":" -f 1,2)
	echo "rtc_value=\"$rtc_value\"" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
else
	res14=y
fi
echo "res14=$res14" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$rs485_test" = "y" ]; then
echo " "
echo "====================================================================================="
echo "                               RS485 TEST "
echo "===================================================================================== "

	res10=n


	. /root/RS485UtilityComponent/etc/Config/RS485utilityConfig.cfg
	. /usr/local/bin/Testscripts/testscriptconfig.cfg
	retry=0
	RS485_out=$(sh /bin/hextoIEEE.sh "$slaveid_rs485")
	ieee754_value=$(echo "$RS485_out" | grep -o 'IEEE 754 Value:[+-]\?[0-9]\+\(\.[0-9]\+\)\?' | cut -d':' -f2)

	echo "IEEE 754 Value=$ieee754_value"

	if echo "$RS485_out" | grep -q "not"; then
		res10="n"
	else
		res10="y"
	fi

	time_stamp=$(date)
	case $res10 in
		[yY]* )
		
			echo -e "\e[1;32m  [$time_stamp]  RS485 test = PASS \e[0m" 				
			a=$(echo "[$time_stamp]	        RS485 test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)		
			res10=y; break;;
		[nN]* )
	
			echo -e "\e[1;31m  [$time_stamp]  RS485 test = FAIL \e[0m" 				
			a=$(echo "[$time_stamp]	        RS485 test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
			res10=n; break;;
		* ) ;;
	esac
else
	res10=y
fi

echo "res10=$res10" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

if [ "$rs232_test" = "y" ]; then
echo " "
echo "====================================================================================="
echo "                              RS232 TEST "
echo "===================================================================================== "

	. /root/RS232UtilityComponent/etc/Config/RS232utilityConfig.cfg 
	. /usr/local/bin/Testscripts/testscriptconfig.cfg


	res11=n                                
	echo -e "\e[34mPLEASE CHECK LOOPBACK IS CONNECTED OR NOT? (y/n) \e[0m"
	read res11

	if [ "$res11" = "y" ]; then
		retry_count=0
		rs232Out=$(/root/RS232UtilityComponent/RS232UtilityGD44 "$deviceid_rs232")
		hex_line=$(echo "$rs232Out" | grep -o 'hex values:.*')
		hex_values=$(echo "$hex_line" | cut -d ':' -f 2)

		hex_values_no_spaces=$(echo "$hex_values" | tr -d ' ')
		echo "Received_value:$hex_values_no_spaces"

		if echo "$hex_values_no_spaces" | grep -q '[^0]'; then
			echo -e "\e[1;32m [$time_stamp] RS232 test = PASS \e[0m"
			a=$(echo "[$time_stamp]          RS232 test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
			res12=y
		else	
			echo -e "\e[1;31m [$time_stamp] RS232 test = FAIL \e[0m"
			a=$(echo "[$time_stamp]          RS232 test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
			res12=n
		fi
	else 
		echo "There is no RS232 in this Board"
		echo -e "\e[1;31m [$time_stamp] RS232 test = FAIL \e[0m"
		a=$(echo "[$time_stamp]         RS232 test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res11=n
	fi
else
	res11=y
	res12=y
fi
echo "res11=$res11" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res12=$res12" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"


echo "=====================================================================================                                            
                               NMS Registration Test                                                                                 
===================================================================================== "    
echo " "    
counter=1                                                                                  
while [ $counter -le 3 ]; do                                                               
    echo "Do you want to register NMS (y/n)"                                                  
    read res13                                                                               
                                                                                                                                          
    case $res13 in                                                                         
        y)                                                                                                          
            source /usr/local/bin/Testscripts/Nmssecuritykey.txt   
            nms_test=y                                                                           
            nms_out=$(/usr/local/bin/Testscripts/Register_NMS.sh "$URL" "$KEY")                                 
            tunip=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')    
                                                                                                                      
            if [ -n "$tunip" ]; then                                                                                                          
				echo -e "\e[1;32m [$time_stamp] NMS Registration Test = PASS \e[0m"                                                   
                a=$(echo "[$time_stamp]        NMS Registration Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
                res13=y      
                echo "nms_url=$URL" >> "$outputfile2path"                                     
				echo "tunip=$tunip" >> "$outputfile2path"                                                                              
                break                                                                                  
            else                                                                                                      
				echo -e "\e[1;31m [$time_stamp] NMS Registration Test = FAIL \e[0m"                                            
                a=$(echo "[$time_stamp]        NMS Registration Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)
                res13=n  
            fi                                                                                                        
            ;;                                                                                                        
        n)                                                                                                            
            
            echo -e "\e[1;32m [$time_stamp] NMS is not Enabled... \e[0m"                                            
            a=$(echo "[$time_stamp]          NMS is not enabled" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt)                               
            res13=y    
            nms_test=n                                                                                              
            break                                                                           
            ;;                                                                                                        
        *)                                                                                                            
            echo "Please enter a valid value (y/n)."                                                                                          
            ;;                                           
    esac                                                                                                                                   
                                                                                                        
    counter=$((counter + 1))                                                                                                                  
done            
echo "nms_test=$nms_test" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"                               
echo "res13=$res13" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"             


echo "=====================================================================================
                                 BOARD POWERING OFF
====================================================================================="

sleep 3
echo -e "\e[1;32m board_powering_off1.Press Enter after 20 seconds to continue the test... \e[0m"
sleep 3
echo 1 > /sys/class/gpio/gpio2/value


