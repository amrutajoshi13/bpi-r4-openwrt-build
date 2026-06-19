#!/bin/sh

wifi_enable_disable=$(hexdump -v -n 1 -s 0x61 -e '7/1 "%01X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
wifi_enable_disable=$(echo "$wifi_enable_disable" | tr -d '\013\014\015 ')
wan_mac_addr=$(hexdump -v -n 6 -s 0x2e -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
lan_mac_addr=$(hexdump -v -n 6 -s 0x28 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	wifi_mac_addr=$(hexdump -v -n 6 -s 0x4 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
fi
serial_number=$(hexdump -v -n 6 -s 0x100 -e '5/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
imei=$(hexdump -v -n 8 -s 0x110 -e '7/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')

if [ -e /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt ]
then 
	rm /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
fi

time_stamp=$(date)
echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "[$time_stamp]" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The serial number is - $serial_number" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The IMEI number is - $imei" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The wan mac addr is - $wan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The lan mac addr is - $lan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	echo "The wifi mac addr is - $wifi_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
fi
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt


#Wifi SSID 
wifi_ssid="AP_$serial_number"
wifi_guest_ssid="GUESTAP_$serial_number"

#Update the required parameters in config files.
uci set boardconfig.board.serialnum=$serial_number
uci set boardconfig.board.wanmacid=$wan_mac_addr
uci set boardconfig.board.lanmacid=$lan_mac_addr
if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
	uci set boardconfig.board.wifimacid=$wifi_mac_addr
		    uci set sysconfig.wificonfig.wifi1enable=1

	uci set sysconfig.wificonfig.wifi1ssid=$wifi_ssid
	uci commit sysconfig
	
	uci set wireless.ap.ssid=$wifi_ssid
	uci commit wireless
	
		uci set network.ra0=interface
		uci set network.ra0.ipaddr='192.168.100.1'
		uci set network.ra0.netmask='255.255.255.0'
		uci set network.ra0.proto='static'
		uci set network.ra0.ifname='ra0'
		uci commit network
		wifi
	
	uci del_list rpcd.admin.read='!macidconfig'
		uci del_list rpcd.admin.write='!macidconfig'
		uci del_list rpcd.@login[2].read='!macidconfig'
		uci del_list rpcd.@login[2].write='!macidconfig'
		uci commit rpcd
	
	#Update SSID in mt7628.dat file.
	wirelessdatfile="/etc/wireless/mt7628/mt7628.dat"
	ssid=$(grep -w "SSID1" ${wirelessdatfile})        
	ssid_replace="SSID1=$wifi_ssid"
	sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"

	ssid_guest=$(grep -w "SSID2" ${wirelessdatfile})        
	ssid_guest_replace="SSID2=$wifi_guest_ssid"
	sed -i "s/${ssid_guest}/${ssid_guest_replace}/" "$wirelessdatfile"
		
fi
uci set boardconfig.board.imei=$imei
uci commit boardconfig

uci set system.system.hostname=$serial_number
uci commit system

uci set networkinterfaces.SW_LAN.macaddress=$lan_mac_addr
uci set networkinterfaces.EWAN5.macaddress=$wan_mac_addr
uci set network.EWAN5.macaddr=$wan_mac_addr
uci commit sysconfig
uci commit network
uci commit networkinterfaces


cp /etc/config/boardconfig /root/InterfaceManager/config/
cp /etc/config/rpcd /root/InterfaceManager/config/
cp /etc/config/system /root/InterfaceManager/config/
cp /etc/config/sysconfig /root/InterfaceManager/config/
cp /etc/config/network /root/InterfaceManager/config/
cp /etc/config/wireless /root/InterfaceManager/config/
cp /etc/wireless/mt7628/mt7628.dat /root/InterfaceManager/mt7628/
cp /etc/config/networkinterfaces /root/InterfaceManager/config/


filename=${serial_number:0}.txt
outputfile2path="/usr/local/bin/Testscripts/Testresult/output2_file.txt"

cat /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt  > /usr/local/bin/Testscripts/Testresult/$filename

echo "wifi_enable_disable=$wifi_enable_disable" > "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "=====================================================================================
                                USB:Modem Test
===================================================================================== "
echo " "
modem_status=$(lsusb -t | grep -e option | grep -o 480 |head -1)
sleep 1
if [ $modem_status = "480" ]
then
			#echo "[$time_stamp]		Modem/USB test=PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
			echo -e "\e[1;32m [$time_stamp]   Modem/USB test=PASS \e[0m"
			a=$(echo "[$time_stamp]	Modem/USB test=PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			res15=y;
else
			#echo "[$time_stamp]		Modem/USB test=FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
			echo -e "\e[1;32m [$time_stamp]   Modem/USB test=FAIL \e[0m"
			a=$(echo "[$time_stamp]	Modem/USB test=FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			res15=n

fi
echo "res15=$res15" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo ""
sim_status=$(cat /sys/class/gpio/gpio37/value)
sim_print=$(($sim_status+1))
echo "===================================================================================== 
                                SIM$sim_print QCCID TEST
===================================================================================== "
echo " "
flag=0
count=0
qccid1=""
echo "Waiting for QCCID of sim$sim_print"
while [ $flag -eq 0 ] && [ $count -ne 10 ]
do
	sleep 2
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
			res1=y
			echo -e "\e[1;32m [$time_stamp]	QCCID for sim$sim_print = $qccid1 \e[0m"
			a=$(echo "[$time_stamp]	QCCID for sim$sim_print = $qccid1" | tr -d '\013\014\015'| tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			flag=1
        		break
		fi
	done
	count=$((count+1))	
	
	if [ $count -eq 10 ] && [ $flag -eq 0 ]
	then
		time_stamp=$(date)
		res1=n
		echo -e "\e[1;31m [$time_stamp]	QCCID for sim$sim_print = Not available \e[0m"
		a=$(echo "[$time_stamp]	QCCID for sim$sim_print = Not Available" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	fi
done
sleep 5
echo "res1=$res1" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "qccid1=$qccid1" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "
echo "=====================================================================================
		      IMEI NUMBER ,FW_VERSION  & SIGNAL STRENGTH 
===================================================================================== "
echo " "
res2=""
for temp in $(seq 1 3)
do
	count_in=$(ls /dev | grep -i "ttyU" | wc -l)
	for k in $(seq 1 $count_in)
	do 
		i=$(ls /dev | grep -i "ttyU" | head -$k |tail -1)
		ec=$(/bin/at-cmd /dev/$i ati  > /usr/local/bin/Testscripts/temp.txt) 
		modem=$(cat /usr/local/bin/Testscripts/temp.txt | head -3 |tail -1 | tr -d '\013\014\015')
		modem_name=$(cat /usr/local/bin/Testscripts/temp.txt | head -2 |tail -1 | tr -d '\013\014\015')
		firmare_version=$(cat /usr/local/bin/Testscripts/temp.txt | head -4 |tail -1 | tr -d '\013\014\015')
		sleep 2
		rm -f /usr/local/bin/Testscripts/temp.txt
	
		if [[ -z $modem ]]
		then 
			if [ $k -eq $count_in ] && [ $temp -eq 3 ]
			then 
				time_stamp=$(date)
				echo -e "\e[1;31m [$time_stamp]	AT commands = FAIL \e[0m"
				a=$(echo "[$time_stamp]	AT commands = FAIL " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				res2=n
			fi
			continue
		fi

		sleep 3
	
		echo " "
		for j in $(seq 1 3)
		do 
			sig_str=$(/bin/at-cmd /dev/$i at+csq | head -2 | tail -1 | cut -d " " -f 2 |cut -d "," -f 1)
			sleep 1
			if [ $sig_str -ge 17 ]
			then
				time_stamp=$(date)
				echo "[$time_stamp]	Sim$sim_print signal strength = $sig_str " | tee -a /usr/local/bin/Testscripts/Testresult/$filename
				echo ""
				echo -e "\e[1;32m [$time_stamp]	Sim$sim_print signal strength test = PASS \e[0m"
				a=$(echo "[$time_stamp]	Sim$sim_print signal strength test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				res3=y
				break
			fi
			if [ $j -eq 3 ]
			then 
				time_stamp=$(date)
				echo "[$time_stamp]	Sim$sim_print signal strength = $sig_str " | tee -a /usr/local/bin/Testscripts/Testresult/$filename
				echo ""
				echo -e "\e[1;31m [$time_stamp]	Sim$sim_print signal strength test = FAIL \e[0m"
				a=$(echo "[$time_stamp]	Sim$sim_print signal strength test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
				res3=n
				break
			fi
		done

		time_stamp=$(date)
		echo "[$time_stamp]	Modem name = $modem_name" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
		echo "[$time_stamp]	Modem = $modem " | tee -a /usr/local/bin/Testscripts/Testresult/$filename
		echo "[$time_stamp]	Modem firmware version = $firmare_version" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
		echo ""
	
		echo -e "\e[1;32m [$time_stamp]	AT commands = PASS \e[0m"
		a=$(echo "[$time_stamp]	AT commands = PASS " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res2=y
		flag=1
		break
	done
	if [ $flag -eq 1 ]
	then 
		break
	fi
done
echo "res2=$res2" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "res3=$res3" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "
echo "===================================================================================== 
                                    PING TEST
===================================================================================== "
echo " "

echo "Connect to the LAN1 port."	
echo "Pinging to 192.168.10.2 ...."

time_stamp=$(date)
packet=$(ping -A -I eth0.1 -c 40 192.168.10.2 | grep "packet loss" |cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
if [ $packet -lt 20 ]; then	
	echo -e "\e[1;32m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = PASS \e[0m"
	a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res4=y
else
	echo -e "\e[1;31m [$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	LAN1:$packet% packet loss. Ethernet 1 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	echo "Ethernet is down! Please check the ethernet connection .. "
	res4=n
	
fi
echo "res4=$res4" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "Connect to the LAN2 port."
echo "Pinging to 192.168.10.3 ...."
time_stamp=$(date)
packet=$(ping -A -I eth0.1 -c 40 192.168.10.3 | grep "packet loss" |cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
if [ $packet -lt 20 ]; then	
	echo -e "\e[1;32m [$time_stamp]	LAN2:$packet% packet loss. Ethernet 2 Ping Test = PASS \e[0m"
	a=$(echo "[$time_stamp]	LAN2:$packet% packet loss. Ethernet 2 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res5=y
else
	echo -e "\e[1;31m [$time_stamp]	LAN2:$packet% packet loss. Ethernet 2 Ping Test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	LAN2:$packet% packet loss. Ethernet 2 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	echo "Ethernet is down! Please check the ethernet connection .. "
	res5=n
fi
echo "res5=$res5" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "Connect to the LAN3 port."
echo "Pinging to 192.168.10.4 ...."
time_stamp=$(date)
packet=$(ping -A -I eth0.1 -c 40 192.168.10.4 | grep "packet loss" |cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
if [ $packet -lt 20 ]; then	
	echo -e "\e[1;32m [$time_stamp]	LAN3:$packet% packet loss. Ethernet 3 Ping Test = PASS \e[0m"
	a=$(echo "[$time_stamp]	LAN3:$packet% packet loss. Ethernet 3 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res6=y;
else
	echo -e "\e[1;31m [$time_stamp]	LAN3:$packet% packet loss. Ethernet 3 Ping Test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	LAN3:$packet% packet loss. Ethernet 3 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res6=n;
	echo "Ethernet is down! Please check the ethernet connection .. "
fi
echo "res6=$res6" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "Connect to the LAN4 port."
echo "Pinging to 192.168.10.5 ...."
time_stamp=$(date)
packet=$(ping -A -I eth0.1 -c 40 192.168.10.5 | grep "packet loss" |cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
if [ $packet -lt 20 ]; then	
	echo -e "\e[1;32m [$time_stamp]	LAN4:$packet% packet loss. Ethernet 4 Ping Test = PASS \e[0m"
	a=$(echo "[$time_stamp]	LAN4:$packet% packet loss. Ethernet 4 Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res7=y;
else
	echo -e "\e[1;31m [$time_stamp]	LAN4:$packet% packet loss. Ethernet 4 Ping Test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	LAN4:$packet% packet loss. Ethernet 4 Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res7=n;
	echo "Ethernet is down! Please check the ethernet connection .. "
fi
echo "res7=$res7" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "Connect to the WAN port "
echo "Pinging WAN port to 8.8.8.8 ...."

time_stamp=$(date)
packet_usb=$(ping -A -I eth0.5 -c 40 8.8.8.8 | grep "packet loss" | awk -F ',' '{print $3}' | awk '{print $1}' | sed 's/.\{1\}$//')
if [ $packet_usb -lt 10 ]; then	
	echo -e "\e[1;32m [$time_stamp] WAN:$packet_usb% packet loss. WAN port Ping Test = PASS \e[0m"
	a=$(echo "[$time_stamp]	WAN:$packet_usb% packet loss. WAN port Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res8=y;
else
	echo -e "\e[1;31m [$time_stamp] WAN:$packet_usb% packet loss. WAN port Ping Test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	WAN:$packet_usb% packet loss. WAN port Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res8=n;
fi
echo "res8=$res8" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "
echo " "
echo "===================================================================================== 
                              MODEM PING TEST
===================================================================================== "
echo " "

flag=0
packet_usb=100
ip_check=192
for j in $(seq 5)
do
	count=$(ls /dev | grep -i "ttyU" | wc -l)
	for k in $(seq 1 $count)
	do 
		i=$(ls /dev | grep -i "ttyU" | head -$k | tail -1)
		ec1=$(/bin/at-cmd /dev/$i ati | head -3 |tail -1)
		if [[ -z $ec1 ]]
		then 
			continue
		fi

		ec1=${ec1:2:2}
		if [ $ec1 -eq 25 ]
		then 
			sleep 5
			echo "Pinging wwan0 to 8.8.8.8 ...."
			packet_usb=$(ping -A -I wwan0 -c 40 8.8.8.8 | grep "packet loss" | cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
			ip_check=$(ifconfig wwan0 | grep -i "inet addr" | tr -d " " | cut -d ":" -f 2 | cut -d "." -f 1)
			flag=1
		
			break
		else
			sleep 5
			echo "Pinging USB0 to 8.8.8.8 ...."	
			packet_usb=$(ping -A -I usb0 -c 40 8.8.8.8 | grep "packet loss" | cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
			ip_check=$(ifconfig usb0 | grep -i "inet addr" | tr -d " " | cut -d ":" -f 2 | cut -d "." -f 1)
			flag=1
			break
		fi
	done
	if [ $flag -eq 1 ]
	then
		break
	fi
done
time_stamp=$(date)
if [ $packet_usb -lt 10 ]; then	
	echo -e "\e[1;32m [$time_stamp] MODEM:$packet_usb% packet loss. Modem Ping Test = PASS \e[0m"
	a=$(echo "[$time_stamp]	MODEM:$packet_usb% packet loss. Modem Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res9=y;
else
	echo -e "\e[1;31m [$time_stamp] MODEM:$packet_usb% packet loss. Modem Ping Test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	MODEM:$packet_usb% packet loss. Modem Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res9=n;
fi
echo "res9=$res9" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
if [ $ip_check -eq 192 ]
then 
	echo "Raw ip did not set"
	echo "do the add_macaadr test again " 
	echo "exiting script"
	exit 0
fi

if [ $sim_status -eq 1 ]
then
	sim_status=0
else
	sim_status=1
fi
sim_print=$(($sim_status+1))
echo " "

echo "=====================================================================================
                             SWITCHING TO SIM$sim_print
====================================================================================="
echo""
echo $sim_status > /sys/class/gpio/gpio37/value 
sleep 2
echo 1 > /sys/class/gpio/gpio11/value  
sleep 3
echo 0 > /sys/class/gpio/gpio11/value 
sleep 5

flag=0
count=0

echo "=====================================================================================
                                SIM$sim_print QCCID TEST
======================================================================================"

res10=n
echo "Waiting for QCCID of sim$sim_print"
while [ $flag -eq 0 ] && [ $count -ne 25 ]
do
	count_in=$(ls /dev | grep -i "ttyU" | wc -l)
	sleep 2
	for k in $(seq 1 $count_in)
	do
		i=$(ls /dev | grep -i "ttyU" | head -$k | tail -1)
        	qccid2=$(gcom -d /dev/$i -s /etc/gcom/atqccid_test.gcom | head -2 |tail -1 | cut -d " " -f 2)
		
		#checking whether qccid is empty or not
        	if [[ -z $qccid2 ]]
        	then
                	continue
        	fi

		#In case of error 
		
        	if [ "$qccid2" = "open" ]
        	then
                	continue
        	fi
        	
        len_qccid2=$(echo ${#qccid2})
        
		time_stamp=$(date)
		if [ "$qccid1" != "$qccid2" ] && [ $len_qccid2 -eq 21 ]
		then 
			echo "[$time_stamp]	QCCID for sim$sim_print = $qccid2" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
			echo -e "\e[1;32m [$time_stamp] Sim switching through gpio test = SUCCESS \e[0m"
			a=$(echo "[$time_stamp]	Sim switching through gpio test = SUCCESS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
			flag=1
			res10=y
			break
		else
			continue
		fi
	done
	count=$((count+1))	
done

if [ "$res10" = "n" ]
then
	echo -e "\e[1;31m [$time_stamp] Sim switching through gpio test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	Sim switching through gpio test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	res10=n
fi
echo "res10=$res10" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "qccid2=$qccid2" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "

if [ "$wifi_enable_disable" = "1" ] || [ "$wifi_enable_disable" = "FF" ]; then
echo " "
echo "=====================================================================================
				               WIFI TEST 
===================================================================================== "
	res13=n
	echo " "
	echo "Connect to WIFI Access point on the Phone & check the signal strength on Wifiman app."
	echo "Enter the signal strength --"
	read sigstr

	echo " "
	echo " "
	time_stamp=$(date)
	if [ $sigstr -lt 35 ]; then	
		echo -e "\e[1;32m [$time_stamp] Wifi signal strength = -$sigstr dbm. WIFI Test = PASS \e[0m"
		a=$(echo "[$time_stamp]	Wifi signal strength = -$sigstr dbm. WIFI Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res13=y;
	else
		echo -e "\e[1;31m [$time_stamp] Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		res13=n;
	fi
else
	res13=y
fi
echo "res13=$res13" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "=====================================================================================
		                        RTC TEST 
===================================================================================== "

res11=n
#hwclock -w
for i in $(seq 1 1000)
do
	sys_time=$(date | cut -d " " -f 1,2,3,4 | cut -d ":" -f 1,2)
	rtc_time=$(hwclock -r | cut -d " " -f 1,2,3,4 | cut -d ":" -f 1,2)
	if [ "$sys_time" = "$rtc_time" ]
	then 
		res11=y
		break
	fi
done
time_stamp=$(date)
if [ "$res11" = "y" ]
then
	echo -e "\e[1;32m [$time_stamp]	RTC test = PASS \e[0m"
	a=$(echo "[$time_stamp]	RTC test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
else
	echo -e "\e[1;31m [$time_stamp]	RTC test = FAIL \e[0m"
	a=$(echo "[$time_stamp]	RTC test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
fi
echo "res11=$res11" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"
echo "rtc_time=$rtc_time" >> "$outputfile2path"

echo " "
echo "=====================================================================================
				                SWITCH TEST 
===================================================================================== "
echo " "

echo "Testing switch"
echo "Press and hold switch to observe the change in values"
res12=n
for i in $(seq 1 25);
do
    gpio_val=$(cat /sys/class/gpio/gpio38/value)
	echo $gpio_val
	if [ $gpio_val -eq 0 ]
	then
		res12=y
		time_stamp=$(date)
		echo -e "\e[1;32m [$time_stamp] Reset Switch test = PASS \e[0m"					
		a=$(echo "[$time_stamp]	Reset Switch test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
		break
	fi
        sleep 1
done

if [ "$res12" = "n"  ]
	then 
		time_stamp=$(date)
		echo -e "\e[1;31m [$time_stamp] Reset Switch test = FAIL \e[0m"
		a=$(echo "[$time_stamp]	Reset Switch Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
	fi
echo "res12=$res12" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo " "
echo " "
echo "=====================================================================================
                                      LED TEST
===================================================================================== "
#turning on sim1 and sim2 and 5g LED
echo 0 > /sys/class/gpio/gpio3/value
 
echo 0 > /sys/class/gpio/gpio40/value

echo 0 > /sys/class/gpio/gpio41/value

sleep 2

res14=n
while true; do
    echo "Whether all the LED's (Status and Ethernet LED's) are glowing or not? (y/n)"
    read res14	
    sleep 2
    time_stamp=$(date)
    case "$res14" in
        y)
            echo -e "\e[1;32m [$time_stamp] LED test = PASS \e[0m"
            a=$(echo "[$time_stamp]  LED test = PASS " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
            break
            ;;
        n)
            echo -e "\e[1;31m [$time_stamp] LED test = FAIL \e[0m"
            a=$(echo "[$time_stamp]  LED test = FAIL " | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
            break
            ;;
        *)
            echo "Invalid input. Please enter either 'y' or 'n'."
            ;;
    esac
done

echo "res14=$res14" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "=====================================================================================                                            
                                 NMS Registration Test                                                                                 
===================================================================================== "    
echo " "    
counter=1    
nms_test=n                                                                              
while [ $counter -le 3 ]; do                                                               
    echo "Do you want to register NMS (y/n)"                                                  
    read res16                                                                             
                                                                                                                                          
    case $res16 in                                                                         
        y)                                                                                                          
            source /usr/local/bin/Testscripts/Nmssecuritykey.txt     
            nms_test=y                                                                        
            nms_out=$(/usr/local/bin/Testscripts/Register_NMS.sh "$URL" "$KEY")                                 
            tunip=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')    
            sleep 20                                                                                                         
            if [ -n "$tunip" ]; then                                                                                                          
				echo -e "\e[1;32m [$time_stamp] NMS Registration Test = PASS \e[0m"                                                   
                a=$(echo "[$time_stamp]  NMS Registration Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
                res16=y 
                   
                echo "nms_url=$URL" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"                                
				echo "tunip=$tunip" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"                                                                            
                break                                                                                  
            else                                                                                                      
				echo -e "\e[1;31m [$time_stamp] NMS Registration Test = FAIL \e[0m"                                            
                a=$(echo "[$time_stamp]  NMS Registration Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)
                res16=n 
                
            fi                                                                                                        
            ;;                                                                                                        
        n)                                                                                                            
               
            echo -e "\e[1;32m [$time_stamp] NMS is not Enabled... \e[0m"                                            
            a=$(echo "[$time_stamp]  NMS is not enabled" | tee -a /usr/local/bin/Testscripts/Testresult/$filename)                           
            res16=y  
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
echo "res16=$res16" >> "/usr/local/bin/Testscripts/Testresult/output_file.txt"

echo "=====================================================================================
                                 BOARD POWERING OFF 
====================================================================================="
sleep 1
echo "board_powering_off1"
echo -e "\e[1;32m Press Enter after 10 seconds to continue the test.Board is rebooting... \e[0m"
sleep 3

echo 1 > /sys/class/gpio/gpio2/value


