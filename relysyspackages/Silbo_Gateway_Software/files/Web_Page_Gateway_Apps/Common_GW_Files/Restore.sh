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

sh /etc/init.d/GD44AppManager stop

uci set applist_config.appconfig.running="0"
uci commit applist_config

rm /etc/ser2net.conf
rm /etc/mbusdconfig.conf
rm /etc/mbusdconfig2.conf

sh /bin/defaultbackupRestoreGateway.sh 2
#cp /Web_Page_Gateway_Apps/Default_Gateway/etc/* /etc/
#cp /Web_Page_Gateway_Apps/Default_Gateway/etc/crontabs/root /etc/crontabs/

date=$(date)
echo "$date:[Factory Reset button Press]:5" >> "$RebootLogfile"
echo "$date:[Factory Reset button Press]:5" > "$RebootreasonLogfile"

/root/usrRPC/script/Board_Recycle_12V_Script.sh

exit 0
