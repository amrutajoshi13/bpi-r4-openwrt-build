#!/bin/sh


wifi_enable_disable=$(hexdump -v -n 1 -s 0x61 -e '7/1 "%01X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
wifi_enable_disable=$(echo "$wifi_enable_disable" | tr -d '\013\014\015 ')

#echo "wifi_enable_disable:$wifi_enable_disable"

lan_mac_addr=$(hexdump -v -n 6 -s 0x28 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)

if [ "$wifi_enable_disable" = "1" ]; then 
	wifi_mac_addr=$(hexdump -v -n 6 -s 0x4 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
fi
serial_number=$(hexdump -v -n 6 -s 0x100 -e '5/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
#imei_n=$(hexdump -v -n 8 -s 0x110 -e '7/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
#imei=${imei_n:0}

if [ -e /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt ]
then 
	rm /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
fi

time_stamp=$(date)
echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "[$time_stamp]" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The serial number is - $serial_number" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
#echo "The IMEI number is - $imei" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
#if [ "$wan_mac" = "y" ]; then
	#echo "The wan mac addr is - $wan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
#fi
echo "The lan mac addr is - $lan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
if [ "$wifi_enable_disable" = "1" ]; then
	echo "The wifi mac addr is - $wifi_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
fi
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt

#Wifi SSID 
wifi_ssid="AP_$serial_number"
wifi_guest_ssid="GUESTAP_$serial_number"


filename=${serial_number:0}.txt
board_name=$(cat /tmp/sysinfo/board_name)

outputfile2path="/usr/local/bin/Testscripts/Testresult/output2_file.txt"
#Update the required parameters in config files.
uci set boardconfig.board.serialnum=$serial_number

uci set boardconfig.board.lanmacid=$lan_mac_addr
if [ "$wifi_enable_disable" = "1" ]; then
	uci set boardconfig.board.wifimacid=$wifi_mac_addr
fi

uci commit boardconfig

sleep 1

cp /etc/config/boardconfig /root/InterfaceManager/config/boardconfig

sleep 1

uci set sysconfig.sysconfig.wifi1ssid=$wifi_ssid

sleep 1

uci set system.system.hostname=$serial_number
uci commit system

sleep 1

uci set wireless.ap.ssid=$wifi_ssid
uci commit wireless

sleep 1

#if [ "$wan_mac" = "y" ]; then
	#uci set sysconfig.sysconfig.port5macid=$wan_mac_addr
	#uci set network.EWAN2.macaddr=$wan_mac_addr
#fi


#Update SSID in mt7628.dat file.
wirelessdatfile="/etc/wireless/mt7628/mt7628.dat"
ssid=$(grep -w "SSID1" ${wirelessdatfile})        
ssid_replace="SSID1=$wifi_ssid"
sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"

ssid_guest=$(grep -w "SSID2" ${wirelessdatfile})        
ssid_guest_replace="SSID2=$wifi_guest_ssid"
sed -i "s/${ssid_guest}/${ssid_guest_replace}/" "$wirelessdatfile"

cp /etc/wireless/mt7628/mt7628.dat /root/InterfaceManager/mt7628/mt7628.dat

uci set system.system.hostname=$serial_number
uci commit system

uci commit sysconfig
uci commit network

cp /etc/config/boardconfig /root/InterfaceManager/config/
cp /etc/config/system /root/InterfaceManager/config/
cp /etc/config/sysconfig /root/InterfaceManager/config/
cp /etc/config/network /root/InterfaceManager/config/

/etc/init.d/system restart
sleep 1

/sbin/wifi reload
echo  "Test will continue in  25 seconds"
sleep 25

echo "wifi_enable_disable=$wifi_enable_disable" > "/usr/local/bin/Testscripts/Testresult/output_file.txt"

cat /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt  > /usr/local/bin/Testscripts/Testresult/$filename


echo " "
echo "===================================================================================== 
                                    PING TEST
===================================================================================== "
echo " "

res1=n
echo "Connect to the LAN1 port."	
echo "Pinging to 192.168.9.2 ...."

time_stamp=$(date)
packet=$(ping -A -I eth0 -c 40 192.168.9.2 | grep "packet loss" |cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
if [ $packet -lt 20 ]; then	
	echo -e "\e[1;32m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = PASS \e[0m"
	a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res1=y
else
	echo -e "\e[1;31m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	echo "Ethernet is down! Please check the ethernet connection .. "
	res1=n
fi

echo "res1=$res1" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "
sleep 5
echo " "
echo "=====================================================================================
				              SWITCH TEST 
===================================================================================== "
echo " "
res2=n
echo "Testing switch"
echo "Press and hold switch to observe the change in values"
for i in $(seq 1 25);
do
	gpio_val=$(cat /sys/class/gpio/gpio38/value)
	echo $gpio_val
	if [ $gpio_val -eq 0 ]
	then
		res2=y
		time_stamp=$(date)
		echo -e "\e[1;32m [$time_stamp] Reset Switch test = PASS \e[0m"					
		a=$(echo "[$time_stamp]	Reset Switch Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		break
	fi
		sleep 1
done

if [ "$res2" = "n"  ]
then
	time_stamp=$(date)
	echo -e "\e[1;31m [$time_stamp] Reset Switch test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	Reset Switch Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
fi

echo "res2=$res2" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

sleep 5

echo " "
echo "====================================================================================="
echo "                               RS485 TEST "
echo "===================================================================================== "

res4=n
. /root/RS485UtilityComponent/etc/Config/RS485utilityConfigTestScript.cfg
. /usr/local/bin/Testscripts/testscriptconfig.cfg
retry=0
RS485_out=$(sh /bin/hextoIEEE.sh "$slaveid_rs485")
ieee754_value=$(echo "$RS485_out" | grep -o 'IEEE 754 Value:[+-]\?[0-9]\+\(\.[0-9]\+\)\?' | cut -d':' -f2)

echo "IEEE 754 Value=$ieee754_value"

if echo "$RS485_out" | grep -q "not"; then
	res4="n"
else
	res4="y"
fi

time_stamp=$(date)
case $res4 in
	[yY]* )
		echo -e "\e[1;32m  [$time_stamp]  RS485 test = PASS \e[0m" 				
		a=$(echo "[$time_stamp]	RS485 test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)		
		res4=y; break;;
	[nN]* )
		echo -e "\e[1;31m  [$time_stamp]  RS485 test = FAIL \e[0m" 				
		a=$(echo "[$time_stamp]	RS485 test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res4=n; break;;
	* ) ;;
esac
echo "res4=$res4" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

time_stamp=$(date)
sleep 5

if [ "$wifi_enable_disable" = "1" ]; then
echo " "
echo "=====================================================================================
				               WIFI TEST 
===================================================================================== "
	res3=n
	echo " "
	echo "Connect to WIFI Access point on the Phone & check the signal strength on WIfiman app."
	echo "Enter the signal strength --"
	read sigstr

	echo " "
	echo " "
	time_stamp=$(date)
	if [ $sigstr -lt 35 ]; then	
		echo -e "\e[1;32m [$time_stamp] Wifi signal strength = -$sigstr dbm. WIFI Test = PASS \e[0m"
		a=$(echo "[$time_stamp]	Wifi signal strength = -$sigstr dbm. WIFI Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res3=y;
	else
		echo -e "\e[1;31m [$time_stamp] Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res3=n;
	fi
else
	res3=y
fi
echo "res3=$res3" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "
echo " "
echo "=====================================================================================
			        DISPLAYING REPORT 
===================================================================================== "
echo " "
cat /usr/local/bin/Testscripts/Testresult/$filename

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

sleep 1

if [ "$res1" = "y" ] && [ "$res2" = "y" ] && [ "$res3" = "y" ] && [ "$res4" = "y" ];then

	mv /usr/local/bin/Testscripts/Testresult/$filename /usr/local/bin/Testscripts/Testresult/Pass/$filename
	
else

	mv /usr/local/bin/Testscripts/Testresult/$filename /usr/local/bin/Testscripts/Testresult/Fail/$filename
	
fi 

echo "=====================================================================================
                                 BOARD POWERING OFF 
====================================================================================="
echo -e "\e[1;32m Press Enter after 10 seconds to continue the test.Board is rebooting... \e[0m"
sleep 3
sh /root/usrRPC/script/Board_Recycle_12V_Script.sh



