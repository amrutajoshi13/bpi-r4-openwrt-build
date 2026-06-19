#!/bin/ash

serial_n=$(hexdump -v -n 6 -s 0x100 -e '5/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
serial_number=${serial_n:0}

filename=$serial_number

cat /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt > /usr/local/bin/Testscripts/Testresult/$filename.txt

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

echo""
sleep 1

echo "=====================================================================================
                                USB:Modem Test
===================================================================================== "
echo " "
modem_status=$(lsusb -t | grep -e option | grep -o 480 |head -1)
sleep 1
if [ $modem_status = "480" ]
then
			echo "[$time_stamp]		Modem/USB test=PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
			echo "[$time_stamp]		Modem/USB test=PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename;res9=y;
else
			echo "[$time_stamp]		Modem/USB test=FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename
			echo "[$time_stamp]		Modem/USB test=FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename;res9=n;

fi

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
	ec1=$(/bin/at-cmd /dev/$i ati | head -3 |tail -1)

	if [[ -z $ec1 ]]
	then
	    continue
	fi

	sleep 3
	time_stamp=$(date)
	rev=$(/bin/at-cmd /dev/$i ati | grep -i "Revision")

	rev1=${rev:10:25}
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
echo ""

echo ""
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
			echo "[$time_stamp]		QCCID for sim$sim_print = $qccid1" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
			flag=1
        		break
		fi
	done
	count=$((count+1))	
done

echo "=====================================================================================
                                  LAN PING TEST
===================================================================================== "

echo ""
sleep 1
echo "Pinging to 192.168.9.2 ...."

time_stamp=$(date)
packet=$(ping -I eth0 -c 4 192.168.9.2 | grep "packet loss" | awk -F ',' '{print $3}' | awk '{print $1}' | sed 's/.\{1\}$//')
if [ $packet -lt 20 ]; then	
    echo "[$time_stamp]		LAN :$packet% packet loss. Ethernet Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res3=y;
else
    echo "[$time_stamp]		LAN :$packet% packet loss. Ethernet Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res3=n;
    echo "Ethernet is down! Please check the ethernet connection .. "
fi

echo ""
echo ""

echo "=====================================================================================
                               MODEM TEST
===================================================================================== "
echo " "


flag=0
packet_usb=100
sig_str=0
res4=n
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

		sig_str=$(/bin/at-cmd /dev/$i at+csq | head -2 | tail -1 | cut -d " " -f 2 |cut -d "," -f 1)

		ec1=${ec1:2:2}
		if [ $ec1 -eq 25 ]
		then
			ipaddr=$(ifconfig wwan0 | grep "inet addr" | tr -s " " | cut -d " " -f 3 | cut -d ":" -f 2)
			packet_usb=$(ping -I wwan0 -c 4 8.8.8.8 | grep "packet loss" | cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
			res4=y

			break
		else
			ipaddr=$(ifconfig usb0 | grep "inet addr" | tr -s " " | cut -d " " -f 3 | cut -d ":" -f 2)
			packet_usb=$(ping -I usb0 -c 4 8.8.8.8 | grep "packet loss" | cut -d "," -f 3| tr -d " "| cut -d "%" -f 1)
			res4=y
			break
		fi
	done
	if [ $packet_usb -eq 0 ]
	then
		break
	fi
done

time_stamp=$(date)
echo "[$time_stamp]		Modem IP address = $ipaddr" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
echo "[$time_stamp]		Signal strength = $sig_str" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt

echo ""
echo "Pinging to 8.8.8.8"

time_stamp=$(date)
if [ $packet_usb -eq 0 ]; then
	echo "[$time_stamp]		MODEM:$packet_usb% packet loss. Modem Ping Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
	res4=y
else
	echo "[$time_stamp]		MODEM:$packet_usb% packet loss. Modem Ping Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt
	res4=n
fi

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


sleep 1
echo ""
echo ""

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
    echo "[$time_stamp]		Wifi signal strength = -$sigstr dbm. WIFI Test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res5=y;
else
    echo "[$time_stamp]		Wifi signal strength = -$sigstr dbm. WIFI Test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res5=n;
fi

echo ""
echo ""

echo "=======================================================================
LED TEST 
======================================================================= "
echo " "
echo "Whether ALL LED's are glowing or not ?(y/n)"
read res7 

case $res7 in
    [yY] ) echo "[$time_stamp]		LED test = PASS" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res7=y;break;;
    [nN] ) echo "[$time_stamp]		LED test = FAIL" | tee -a /usr/local/bin/Testscripts/Testresult/$filename.txt;res7=y;break;;
    * );;
esac


echo "=======================================================================
DISPLAYING REPORT
======================================================================= "
echo " "
cat /usr/local/bin/Testscripts/Testresult/$filename.txt

echo " "
echo " "
echo "Enter PC username"
read username

for i in $(ls /usr/local/bin/Testscripts/Testresult/Pass)
do
	rm /usr/local/bin/Testscripts/Testresult/Pass/$i
done

for i in $(ls /usr/local/bin/Testscripts/Testresult/Fail)
do
	rm /usr/local/bin/Testscripts/Testresult/Fail/$i
done

if [ "$res1" = "y" ] && [ "$res2" = "y" ] && [ "$res3" = "y" ] && [ "$res4" = "y" ] && [ "$res5" = "y" ] && [ "$res6" = "y" ] && [ "$res7" = "y" ] && [ "$res8" = "y" ] && [ "$res9" = "y" ];then
    mv /usr/local/bin/Testscripts/Testresult/$filename.txt /usr/local/bin/Testscripts/Testresult/Pass/$filename.txt
    scp -p /usr/local/bin/Testscripts/Testresult/Pass/$filename.txt $username@192.168.9.2:Silbo-RF-44/Test_Report/PASS
else
    mv /usr/local/bin/Testscripts/Testresult/$filename.txt /usr/local/bin/Testscripts/Testresult/Fail/$filename.txt
    scp -p /usr/local/bin/Testscripts/Testresult/Fail/$filename.txt $username@192.168.9.2:Silbo-RF-44/Test_Report/FAIL
fi

echo "SSH DISABLED"
uci set dropbear.root.RootLogin='0'
uci commit dropbear
/etc/init.d/dropbear restart

echo "=====================================================================================
                                 BOARD POWERING OFF
====================================================================================="

sleep 3

echo 1 > /sys/class/gpio/gpio2/value
