#!/bin/sh

count=$(ls /dev | grep "ttyU" | wc -l)

for j in $(seq 1 $count)
do
	i=$(ls /dev | grep "ttyU" | head -$j | tail -1)
	ec1=$(/bin/at-cmd /dev/$i ati | head -3 |tail -1) 
	
	if [[ -z $ec1 ]]
	then 
		continue
	fi
	
	ec1=${ec1:2:2}
	if [ $ec1 -eq 25 ]
	then
		break
	else
		setrawip=$(gcom -d /dev/$i -s /etc/gcom/setrawip.gcom | grep -i "OK")
		SetHotSwap=$(/bin/at-cmd /dev/$i at+qsimdet=1,1)
		if [[ -n $setrawip ]]
		then
				SetHotSwapresp=$(/bin/at-cmd /dev/$i at+qsimdet?) 
		     if [[ $SetHotSwapresp = "OKSIMDET: 1,1" ]]
		     then
				break
			 fi
		fi
	fi
done


echo "Enter serial number"
read serial_number

echo "Enter WAN MAC address - " 
read wanmac

echo "Enter WIFI MAC address - " 
read wifi_mac

echo "======================================================================
 Whitelabel_logo
======================================================================= "
echo " "
echo "Do you want Whitelabel_logo ?(y/n)"
read logo 

if [ $logo = "y" ]
then 
    echo "Please choose below option"
    echo "1)Web page with Default Silbo logo"
    echo "2)Web page without logo"
fi
    read Value
   case $Value in 
      1)
        cp  /usr/local/bin/Testscripts/with_silbo_logo/ui.js /www/luci2/                                  
        cp  /usr/local/bin/Testscripts/with_silbo_logo/luci2.html /www/                            
        /etc/init.d/uhttpd restart
        break
	;;
      2)
        cp  /usr/local/bin/Testscripts/without_logo/ui.js /www/luci2/                                  
        cp  /usr/local/bin/Testscripts/without_logo/luci2.html /www/                            
        /etc/init.d/uhttpd restart
        break
	;;
    * );;
esac
SerialNumber()
{
	local var1=${serial_number:0:2}
	local var2=${serial_number:2:2}
	local var3=${serial_number:4:2}
	local var4=${serial_number:6:2}
	local var5=${serial_number:8:2}
	local var6=${serial_number:10:1}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x100))
}

Wanmac()
{
	local var1=${wanmac:0:2}
	local var2=${wanmac:3:2}
	local var3=${wanmac:6:2}
	local var4=${wanmac:9:2}
	local var5=${wanmac:12:2}
	local var6=${wanmac:15:2}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x28))
}

WifiMAC()
{
	local var1=${wifi_mac:0:2}
	local var2=${wifi_mac:3:2}
	local var3=${wifi_mac:6:2}
	local var4=${wifi_mac:9:2}
	local var5=${wifi_mac:12:2}
	local var6=${wifi_mac:15:2}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x4))
}

LOGO()
{
    local var1=${Value:0:2}	
    	printf "\x$var1" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x60))

}


IMEI()
{
	for i in ttyUSB1 ttyUSB1 ttyUSB2 ttyUSB2 ttyUSB3 ttyUSB3
	do
		Imei_num=$(gcom -d /dev/$i -s /etc/gcom/atgsn_test.gcom | awk 'NR==2' | tr -d '\011\012\013\014\015\040')
		if [[ -n $Imei_num ]]
		then
			echo "The IMEI number is -- $Imei_num"
			echo "Did you get the correct Imei number?(y/n)"
			read opt
			if [ "$opt" = "y" ]
			then
				break
			fi
		fi
	done
	if [[ -z $Imei_num ]]
	then
	        echo "The IMEI number is empty"
                echo "Do you want to perform Imei test once again?(y/n)"
		read opt
		if [ "$opt" -eq "y" ]
		then
			IMEI
		else
			exit
		fi
	fi 
	echo "Writing the IMEI number -- $Imei_num to factory."
	Imei=$Imei_num
	local var1=${Imei:0:2}
	local var2=${Imei:2:2}
	local var3=${Imei:4:2}
	local var4=${Imei:6:2}
	local var5=${Imei:8:2}
	local var6=${Imei:10:2}
	local var7=${Imei:12:2}
	local var8=${Imei:14:1}
	printf "\x$var1\x$var2\x$var3\x$var4\x$var5\x$var6\x$var7\x$var8" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x110))
	
}
if [ $serial_number ]
then
	dd if=/dev/mtd2 of=/tmp/factory.bin
	source /root/Web_page/Board_info.txt
	productid=$(cat /sys/devices/platform/101c0000.ehci/usb1/1-1/idProduct)
	vendorid=$(cat /sys/devices/platform/101c0000.ehci/usb1/1-1/idVendor)
	
	
	if  [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
	then
	     uci set system.system.model="$board_name"-EC200A
	      uci set boardconfig.board.model="$board_name"-EC200A
	elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
	then
	     uci set system.system.model="$board_name"-EC25E
	     	          uci set boardconfig.board.model="$board_name"-EC25E
	     cp /Web_page/EC25E/* /www/luci2/
	fi
	uci commit system
	uci commit boardconfig
	cp /etc/config/system /root/InterfaceManager/config/
	cp /etc/config/boardconfig /root/InterfaceManager/config/
	SerialNumber
	Wanmac
	WifiMAC
	IMEI
    LOGO

	mtd -r write /tmp/factory.bin factory
else
	echo "Please enter the correct values"
fi
