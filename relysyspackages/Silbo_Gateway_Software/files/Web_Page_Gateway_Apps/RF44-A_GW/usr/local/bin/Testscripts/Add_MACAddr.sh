#!/bin/sh

source /Web_Page_Gateway_Apps/Board_info.txt

source /usr/local/bin/Testscripts/RF44Config.cfg

productid=$(cat /sys/devices/platform/101c0000.ehci/usb1/1-1/idProduct)
vendorid=$(cat /sys/devices/platform/101c0000.ehci/usb1/1-1/idVendor)

board_name=$(cat /tmp/sysinfo/board_name)

flag=0

for k in $(seq 5)
do
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
	if [ $ec1 -eq 20 ]
	then
		setrawip=$(gcom -d /dev/$i -s /etc/gcom/setrawip.gcom | grep -i "OK")
		if [[ -n $setrawip ]]
		then 
			flag=1
			break
		fi
	fi
done
if [ $flag -eq 1 ]
then 
	break
fi
 
done

flag1=0

for k in $(seq 3)
do
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
		SetHotSwap=$(/bin/at-cmd /dev/$i at+qsimdet=1,1 | grep -i "QSIMDET")
		SetHotSwapresp=$(/bin/at-cmd /dev/$i at+qsimdet?) 
		if [[ -n "$SetHotSwapresp" ]]
		then 
		    flag1=1
			break
		fi
	
 done
done

echo "Enter serial number"
read serial_number

echo "Enter WAN MAC address - " 
read wanmac

echo "Do you want to enter WIFI MAC Address(y/n)"
read  wifienabledisable
if [ $wifienabledisable = "y" ]
then
    	sed -i 's|//wifi_enable_disable:true,|wifi_enable_disable:true,|g' /www/luci2/view/configuration.network.js
    	wifienabledisable=1
	echo "Enter WIFI MAC address - " 
	read wifi_mac
else
    uci add_list rpcd.admin.write=!macidconfig
    uci add_list rpcd.admin.read=!macidconfig
    uci commit rpcd
   	cp /etc/config/rpcd /root/InterfaceManager/config/
	sed -i 's|wifi_enable_disable:true,|//wifi_enable_disable:true,|g' /www/luci2/view/configuration.network.js
   	wifienabledisable=0 
fi

        #to set hostname
uci set system.system.hostname=$serial_number
uci commit system

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
    echo "3)Web page with Custom logo"
fi
    read Value
   case $Value in 
      1)
        cp  /Web_page/custom_logo/Silbo/custom_logo.svg /www/luci2/icons/
		cp  /usr/local/bin/Testscripts/with_custom_logo/ui.js /www/luci2/                                  
		cp  /usr/local/bin/Testscripts/with_custom_logo/luci2.html /www/  
	
		if [ "$board_name" = "Silbo_RF44-A_GW" ]
		then
			if [ "$wifienabledisable" = "0" ]
			then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-A_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-A_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-A_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF04R-A_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF04R-A_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi
				
			elif [ "$wifienabledisable" = "1" ]
			then
		
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-A_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-A_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-A_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF44R-A-RM500U"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF44R-A_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi	
			fi
		fi
		
		if [ "$board_name" = "Silbo_RF44-B_GW" ]
		then
			if [ "$wifienabledisable" = "0" ]
			then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
			then
				uci set system.system.model="Silbo_RF04R-B_GW-EC200A"
				uci set boardconfig.board.model="Silbo_RF04R-B_GW-EC200A"
			elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
			then
				uci set system.system.model="Silbo_RF04R-B_GW-EM05G"
				uci set boardconfig.board.model="Silbo_RF04R-B_GW-EM05G"
			elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
			then
				uci set system.system.model="Silbo_RF04R-B_GW-EC25E"
				uci set boardconfig.board.model="Silbo_RF04R-B_GW-EC25E"
				cp /Web_page/EC25E/* /www/luci2/
			elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
			then  
				uci set system.system.model="Silbo_RF04R-B_GW-RM500U"
				uci set boardconfig.board.model="Silbo_RF04R-B_GW-RM500U"
				uci set signalstrength.modem1.highestNetworkMode="5g"
			elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
			then     
				uci set system.system.model="Silbo_RF04R-B_GW-RM500Q"
				uci set boardconfig.board.model="Silbo_RF04R-B_GW-RM500Q"
				uci set signalstrength.modem1.highestNetworkMode="5g"
				cp /Web_page/EC25E/* /www/luci2/
			fi	
			elif [ "$wifienabledisable" = "1" ]
			then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-B_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-B_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-B_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF44R-B_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF44R-B_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi				
			fi
		fi
		
		if [ "$board_name" = "Silbo_RF44-C_GW" ]
		then
			if [ "$wifienabledisable" = "0" ]
			then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-C_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-C_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-C_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF04R-C_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF04R-C_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi
			elif [ "$wifienabledisable" = "1" ]
			then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
						uci set system.system.model="Silbo_RF44R-C_GW-EC200A"
						uci set boardconfig.board.model="Silbo_RF44R-C_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
						uci set system.system.model="Silbo_RF44R-C_GW-EM05G"
						uci set boardconfig.board.model="Silbo_RF44R-C_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
						uci set system.system.model="Silbo_RF44R-C_GW-EC25E"
						uci set boardconfig.board.model="Silbo_RF44R-C_GW-EC25E"
						cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
						uci set system.system.model="Silbo_RF44R-C_GW-RM500U"
						uci set boardconfig.board.model="Silbo_RF44R-C_GW-RM500U"
						uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
						uci set system.system.model="Silbo_RF44R-C_GW-RM500Q"
						uci set boardconfig.board.model="Silbo_RF44R-C_GW-RM500Q"
						uci set signalstrength.modem1.highestNetworkMode="5g"
						cp /Web_page/EC25E/* /www/luci2/
				fi
								
			fi
		fi
         uci commit system
         uci commit boardconfig	     
		 cp /etc/config/system /root/InterfaceManager/config/
		 cp /etc/config/boardconfig /root/InterfaceManager/config/             
                            
		 /etc/init.d/uhttpd restart
		break
		;;
      2)
		cp  /usr/local/bin/Testscripts/without_logo/ui.js /www/luci2/                                  
		cp  /usr/local/bin/Testscripts/without_logo/luci2.html /www/  
		if [ "$board_name" = "Silbo_RF44-A_GW" ]
		then
			if [ "$wifienabledisable" = "0" ]
			then
			
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-A_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-A_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-A_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF04R-A_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF04R-A_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF04R-A_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi	
			elif [ "$wifienabledisable" = "1" ]
			then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-A_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-A_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-A_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF44R-A_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF44R-A_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF44R-A_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi
			fi
		fi
		
		if [ "$board_name" = "Silbo_RF44-B_GW" ]
		then
			if [ "$wifienabledisable" = "0" ]
			then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-B_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF04R-B_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-B_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF04R-B_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-B_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF04R-B_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF04R-B_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF04R-B_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF04R-B_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF04R-B_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi	
			 elif [ "$wifienabledisable" = "1" ]
			 then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-B_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-B_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-B_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF44R-B_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF44R-B_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF44R-B_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi
			fi
		fi
		
		if [ "$board_name" = "Silbo_RF44-C_GW" ]
		then
			if [ "$wifienabledisable" = "0" ]
			then
			
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-C_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-C_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF04R-C_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF04R-C_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF04R-C_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF04R-C_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi	
			elif [ "$wifienabledisable" = "1" ]
			then
				if [ "2c7c" = "$vendorid" ] && [ "6005" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-C_GW-EC200A"
					uci set boardconfig.board.model="Silbo_RF44R-C_GW-EC200A"
				elif [ "2c7c" = "$vendorid" ] && [ "030e" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-C_GW-EM05G"
					uci set boardconfig.board.model="Silbo_RF44R-C_GW-EM05G"
				elif [ "2c7c" = "$vendorid" ] && [ "0125" = "$productid" ] 
				then
					uci set system.system.model="Silbo_RF44R-C_GW-EC25E"
					uci set boardconfig.board.model="Silbo_RF44R-C_GW-EC25E"
					cp /Web_page/EC25E/* /www/luci2/
				elif [ "2c7c" = "${vendorid}" ] && [ "0900" = "${productid}" ]   
				then  
					uci set system.system.model="Silbo_RF44R-C_GW-RM500U"
					uci set boardconfig.board.model="Silbo_RF44R-C_GW-RM500U"
					uci set signalstrength.modem1.highestNetworkMode="5g"
				elif [ "2c7c" = "${vendorid}" ] && [ "0800" = "${productid}" ]
				then     
					uci set system.system.model="Silbo_RF44R-C_GW-RM500Q"
					uci set boardconfig.board.model="Silbo_RF44R-C_GW-RM500Q"
					uci set signalstrength.modem1.highestNetworkMode="5g"
					cp /Web_page/EC25E/* /www/luci2/
				fi
			fi
			
		fi
         uci commit system
		uci commit boardconfig	     
		cp /etc/config/system /root/InterfaceManager/config/
		cp /etc/config/boardconfig /root/InterfaceManager/config/	                          
		/etc/init.d/uhttpd restart
        break
	;;
	  3)
		# Uncomment the logo image tag in luci2.html
        echo "Uncommenting the logo image tag in luci2.html..."
        sed -i 's|<!--<img src="/luci2/icons/custom_logo.svg" class="logoimg1" />-->|<img src="/luci2/icons/custom_logo.svg" class="logoimg1" />|g' /www/luci2.html

        # Uncomment the logo appending line in ui.js
        echo "Uncommenting the logo appending line in ui.js..."
        sed -i 's|//\.append('\''<img src="/luci2/icons/custom_logo.svg"/>'\'')|\.append('\''<img src="/luci2/icons/custom_logo.svg"/>'\'')|g' /www/luci2/ui.js
                          
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

Wifienabledisable()
{
    local var1=${wifienabledisable:0:2}	
    	printf "\x$var1" | dd conv=notrunc of=/tmp/factory.bin bs=1 seek=$((0x61))

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
	IMEI
	SerialNumber
	Wanmac
	Wifienabledisable
	WifiMAC
    LOGO
    max_retries=3
	retry_count=0
	while [ $retry_count -lt $max_retries ]; do
		/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh
		
		if [ $? -eq 0 ]; then
			echo "Modem powered off successfully"
			break
		else
			echo "Modem powered off failed.Retring..."
			retry_count=$((retry_count+1))
			sleep 2
		fi
	done
	sleep 2
	echo -e "\e[1;32m Press Enter after 10 seconds.Board is Rebooting... \e[0m"
	sleep 1
	mtd -r write /tmp/factory.bin factory
else
	echo "Please enter the correct values"
fi
