#!/bin/sh

. /lib/functions.sh

ReadSystemGpioFile()                               
{
	    config_load "$SystemGpioConfig"
	    config_get ProgramLed1Number gpio programled1number
        config_get ProgramLed1OnValue gpio programled1onvalue
		config_get SimSelectGpio gpio simselectgpio
		config_get Sim1SelectValue gpio sim1selectvalue
		config_get Modem1PowerGpio gpio modem1powergpio      
		config_get Modem1PowerOffValue gpio modem1poweroffvalue

}

pid=$(pgrep -f "/root/InterfaceManager/script/GPIO_Polling_nvp_int_wo_Print_w_script")
kill -TERM "$pid" > /dev/null 2>&1
sleep 1
kill -KILL "$pid" > /dev/null 2>&1


SystemGpioConfig="/etc/config/systemgpio"
RebootLogfile="/root/ConfigFiles/RebootLog/RebootLog.txt"
RebootreasonLogfile="/root/ConfigFiles/RebootLog/Rebootreason.txt"

wifi_enable_disable=$(hexdump -v -n 1 -s 0x61 -e '7/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
wifi_enable_disable=$(echo "$wifi_enable_disable" | tr -d '\013\014\015 ')
retainconfigflag=$(uci get applist_config.appconfig.retainconfigflag)

ReadSystemGpioFile

echo "$ProgramLed1OnValue" > /sys/class/gpio/gpio$ProgramLed1Number/value

mwan3 stop

ipsec stop

uci set modem.CWAN1_0.modemenable="1"
uci set modem.CWAN1_0.modemenable="0"

uci commit modem

echo "$Modem1PowerOffValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value

sleep 2

echo "$Sim1SelectValue" > /sys/class/gpio/gpio$SimSelectGpio/value

/root/InterfaceManager/script/InterfaceInitializer.sh stop

rm /tmp/simnumfile

cp /etc/config/boardconfig /root/


rm -r /etc/config
rm /etc/openvpn/*
rm /etc/crontabs/root
cp -r /root/InterfaceManager/config /etc/
cp  /root/InterfaceManager/crontabs /etc/crontabs/
lan_mac_addr=$(uci get boardconfig.board.lanmacid)
wan_mac_addr=$(uci get boardconfig.board.wanmacid)
uci set networkinterfaces.SW_LAN.macaddress=$lan_mac_addr
uci set networkinterfaces.EWAN5.macaddress=$wan_mac_addr
uci set network.EWAN5.macaddr=$wan_mac_addr
uci commit networkinterfaces
uci commit network
/bin/UpdateConfigurationsMaintenanceReboot  updatemaintenancereboot
cp /etc/openwisp/remote/etc/config/openvpn /etc/config/
cp /root/InterfaceManager/crontabs/root /etc/crontabs/

if  [ "$wifi_enable_disable" -eq "0" ] &&  [ "$retainconfigflag" -eq "1" ]
then
	uci delete network.ra0
	uci delete firewall.wifi
	uci delete firewall.ra0EWAN5
	uci delete firewall.wificwan1_0
	
	uci commit network
	uci commit firewall
	
	uci delete dhcp.ra0
	uci commit dhcp
	uci set wireless.ra0.disabled=1
	uci commit wireless	
		
	wifi
	uci add_list rpcd.root.read='!macidconfig'
	uci add_list rpcd.root.write='!macidconfig'
	uci add_list rpcd.admin.read='!macidconfig'
	uci add_list rpcd.admin.write='!macidconfig'
	uci add_list rpcd.@login[2].read='!macidconfig'
	uci add_list rpcd.@login[2].write='!macidconfig'
	uci add_list rpcd.root.read='!wirelessconfig'
	uci add_list rpcd.root.write='!wirelessconfig'
	uci add_list rpcd.admin.read='!wirelessconfig'
	uci add_list rpcd.admin.write='!wirelessconfig'
	uci add_list rpcd.@login[2].read='!wirelessconfig'
	uci add_list rpcd.@login[2].write='!wirelessconfig'
	uci commit rpcd
	
	# To remove wi-fi scan in the admin debug
	# Check if the section is already commented
	grep -q "^#config MiscUtilities 'MiscUtilities4'" /etc/config/DiagnosticMiscUtilities		
	if [ $? -ne 0 ]; then
	    sed -i "/^config MiscUtilities 'MiscUtilities4'/,/option utility 'Wi-Fi Scan'/ s/^/#/" /etc/config/DiagnosticMiscUtilities
	fi		
	uci commit DiagnosticMiscUtilities
	
	uci set sysconfig.wificonfig.wifi1enable=0
    uci commit sysconfig
    
    cp /etc/config/rpcd /root/InterfaceManager/config/
    cp /etc/config/firewall /root/InterfaceManager/config/
	cp /etc/config/network /root/InterfaceManager/config/
	cp /etc/config/dhcp /root/InterfaceManager/config/
	cp /etc/config/wireless /root/InterfaceManager/config/
	cp /etc/config/sysconfig /root/InterfaceManager/config/
	cp /etc/config/DiagnosticMiscUtilities /root/InterfaceManager/config/
fi

NMS_Enable=$(uci get remoteconfig.nms.nmsenable)
if [ "${NMS_Enable}" = "1" ]
then
	#creating zone  
			uci set firewall.VPN=zone
			uci set firewall.VPN.name="VPN"
			uci set firewall.VPN.input="ACCEPT"
			uci set firewall.VPN.output="ACCEPT"
			uci set firewall.VPN.forward="REJECT"
			uci set firewall.VPN.masq="1"
			uci set firewall.VPN.mtu_fix="1"
			uci set firewall.VPN.network="VPN"
			uci commit firewall
fi
#############################################################################

cp /root/InterfaceManager/mt7628/mt7628.dat /etc/wireless/mt7628/mt7628.dat

#############################################################################
			
sleep 3

sh -x /etc/init.d/GD44AppManager stop

uci set applist_config.appconfig.running="0"
uci commit applist_config

rm /etc/ser2net.conf
rm /etc/mbusdconfig.conf
rm /etc/mbusdconfig2.conf

cp -r /Web_Page_Gateway_Apps/Default_Gateway/config /etc/
cp /Web_Page_Gateway_Apps/Default_Gateway/ser2net.conf /etc/
cp /Web_Page_Gateway_Apps/Default_Gateway/mbusdconfig.conf /etc/
cp /Web_Page_Gateway_Apps/Default_Gateway/mbusdconfig2.conf /etc/
cp /Web_Page_Gateway_Apps/Default_Gateway/root /etc/crontab/

date=$(date)
echo "$date:[Factory Reset button Press]:5" >> "$RebootLogfile"
echo "$date:[Factory Reset button Press]:5" > "$RebootreasonLogfile"

/root/usrRPC/script/Board_Recycle_12V_Script.sh

exit 0
