

#!/bin/sh

. /lib/functions.sh



Openvpnmain="/bin/openvpngeneral.sh"

ReadSystemConfigFile()                               
{                                                    
        config_load "$SystemConfigFile"              
        config_get EnableCellular sysconfig enablecellular
        config_get PortType1 sysconfig porttype1
        config_get ComPort1 sysconfig comport1
        config_get SmsEnable1 smsconfig smsenable1
        config_get SmsEnable2 smsconfig smsenable2
        config_load "$BoardConfigfile"
		config_get serialnum  board serialnum
}

ReadSystemGpioFile()                               
{                                                    
        config_load "$SystemGpioConfig"              
        config_get BoardPowerGpio gpio boardpowergpio
        config_get BoardOnValue gpio boardonvalue
        config_get BoardOffValue gpio boardoffvalue
        config_get NoOfModem gpio noofmodem
        config_get Modem1PowerGpio gpio modem1powergpio
        config_get Modem1PowerOnValue gpio modem1poweronvalue
        config_get Modem1PowerOffValue gpio modem1poweroffvalue
        config_get Modem2PowerGpio gpio modem2powergpio
        config_get Modem2PowerOnValue gpio modem2poweronvalue
        config_get Modem2PowerOffValue gpio modem2poweroffvalue
        config_get ExternelUsb gpio externelusb
        config_get ExternelUsbGpio gpio externelusbgpio
        config_get ExternelUsbOnValue gpio externelusbonvalue
        config_get ExternelUsbOffValue gpio externelusboffvalue
        config_get SimSelectGpio gpio simselectgpio
        config_get Sim1SelectValue gpio sim1selectvalue
        config_get Sim2SelectValue gpio sim2selectvalue
        config_get NoOfProgramLed gpio noofprogramled
        config_get ProgramLed1Number gpio programled1number
        config_get ProgramLed1OnValue gpio programled1onvalue
        config_get ProgramLed1OffValue gpio programled1offvalue
        config_get ProgramLed2Number gpio programled2number
        config_get ProgramLed2OnValue gpio programled2onvalue
        config_get ProgramLed2OffValue gpio programled2offvalue
        config_get ProgramLed3Number gpio programled3number
        config_get ProgramLed3OnValue gpio programled3onvalue
        config_get ProgramLed3OffValue gpio programled3offvalue
        config_get SystemResetSwitch gpio systemresetswitch
        config_get Sim1LedGpio gpio Sim1LedGpio
        config_get Sim1LedGpioOnvalue gpio Sim1LedGpioOnvalue
        config_get Sim1LedGpioOffvalue gpio Sim1LedGpioOffvalue
        config_get Sim2LedGpio gpio Sim2LedGpio
        config_get Sim2LedGpioOnvalue gpio Sim2LedGpioOnvalue
        config_get Sim2LedGpioOffvalue gpio Sim2LedGpioOffvalue
        config_get Wpsgpio gpio Wpsgpio
        config_get numberOfModem1SignalStrengthleds gpio numberOfModem1SignalStrengthleds
        config_get modem1SignalStrengthLedOnValue gpio modem1SignalStrengthLedOnValue
        config_get modem1SignalStrengthLedOffValue gpio modem1SignalStrengthLedOffValue
	config_get modem1SignalStrengthLed1 gpio modem1SignalStrengthLed1
	config_get modem1SignalStrengthLed2 gpio modem1SignalStrengthLed2
	config_get modem1SignalStrengthLed3 gpio modem1SignalStrengthLed3
	config_get modem1SignalStrengthLed4 gpio modem1SignalStrengthLed4
}

SystemGpioConfig="/etc/config/systemgpio"
SystemConfigFile="/etc/config/sysconfig"
SystemHostnameFile="/etc/config/system"
BoardConfigfile="/etc/config/boardconfig"
GcomScript="/etc/gcom/getcardinfo.gcom"


ReadSystemConfigFile
ReadSystemGpioFile

#mount tmpfs to 25000k in RF44/GD44 for sysupgrade to work
source /root/Web_page/Board_info.txt
if echo "$board_name" | grep -qE "(Silbo_RF44|GD44)";
then
	/bin/mount tmpfs /tmp -t tmpfs -o remount,size=25000k,nosuid,nodev
fi

#update serial number,firmware version,wifi ssid in easycwmp config file
serial_num=$(uci get boardconfig.board.serialnum)
Firmwareversion=$(uci get boardconfig.board.FirmwareVer)
Applicationversion=$(uci get boardconfig.board.ApplicationSwVer)
wifi_passwd=$(uci get sysconfig.wificonfig.wifi1key)
wifi_ssid=$(uci get sysconfig.wificonfig.wifi1ssid)
Model=$(uci get boardconfig.board.model)
easycwmp_status=$(uci get remoteconfig.tr069.trenable)
if [ "${easycwmp_status}" = "1" ];then
uci set easycwmp.@device[0].serial_number=$serial_num
uci set easycwmp.@device[0].software_version=${Firmwareversion}_${Applicationversion}
uci set remote.@update[0].ssid=$wifi_ssid
uci set remote.@update[0].passwd=$wifi_passwd
uci set easycwmp.@device[0].product_class=$Model
uci set easycwmp.@device[0].hardware_version=Ed.02

device_info="/etc/device_info"
logo_n=$(hexdump -v -n 1 -s 0x60 -e '7/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
if [ "$logo_n" -eq "01" ] || [ $logo_n = FF ] 
then
MANUFACTURER=$(grep -w "DEVICE_MANUFACTURER" ${device_info})        
MANUFACTURER_Replace="DEVICE_MANUFACTURER=Invendis-Technologies"
sed -i "s/${MANUFACTURER}/${MANUFACTURER_Replace}/" "$device_info"

MANUFACTURER_URL=$(grep -w "DEVICE_MANUFACTURER_URL" "$device_info")
MANUFACTURER_URL_Replace="DEVICE_MANUFACTURER_URL=  "
sed -i "s|${MANUFACTURER_URL}|${MANUFACTURER_URL_Replace}|" "$device_info"

DEVICE_PRODUCT=$(grep -w "DEVICE_PRODUCT" ${device_info})        
DEVICE_PRODUCT_Replace="DEVICE_PRODUCT=$Model"
sed -i "s/${DEVICE_PRODUCT}/${DEVICE_PRODUCT_Replace}/" "$device_info"

DEVICE_REVISION=$(grep -w "DEVICE_REVISION" ${device_info})        
DEVICE_REVISION_Replace="DEVICE_REVISION=Ed.02"
sed -i "s/${DEVICE_REVISION}/${DEVICE_REVISION_Replace}/" "$device_info"
elif [ "$logo_n" -eq "03" ]
then
manufacturer=$(uci get customconfig.customconfig.manufacturer)
manufacturer_url=$(uci get customconfig.customconfig.manufacturer_url)
uci set easycwmp.@device[0].manufacturer=$manufacturer                                     
uci commit easycwmp
device_info="/etc/device_info"

MANUFACTURER=$(grep -w "DEVICE_MANUFACTURER" ${device_info})        
MANUFACTURER_Replace="DEVICE_MANUFACTURER=$manufacturer"
sed -i "s/${MANUFACTURER}/${MANUFACTURER_Replace}/" "$device_info"

MANUFACTURER_URL=$(grep -w "DEVICE_MANUFACTURER_URL" "$device_info")
MANUFACTURER_URL_Replace="DEVICE_MANUFACTURER_URL=  "
sed -i "s|${MANUFACTURER_URL}|${MANUFACTURER_URL_Replace}|" "$device_info"

DEVICE_PRODUCT=$(grep -w "DEVICE_PRODUCT" ${device_info})        
DEVICE_PRODUCT_Replace="DEVICE_PRODUCT=$Model"
sed -i "s/${DEVICE_PRODUCT}/${DEVICE_PRODUCT_Replace}/" "$device_info"

DEVICE_REVISION=$(grep -w "DEVICE_REVISION" ${device_info})        
DEVICE_REVISION_Replace="DEVICE_REVISION=Ed.02"
sed -i "s/${DEVICE_REVISION}/${DEVICE_REVISION_Replace}/" "$device_info"

fi

uci commit easycwmp
uci commit remote
wan1mac=$(uci get boardconfig.board.wanmacid)
wanmacid()
{
        local var1=${wan1mac:0:2}
        local var2=${wan1mac:3:2}
        local var3=${wan1mac:6:2}
        local var4=${wan1mac:9:2}
        local var5=${wan1mac:12:2}
        local var6=${wan1mac:15:2}
        oui=$var1$var2$var3
        uci set easycwmp.@device[0].oui=$oui
        uci commit easycwmp
}

wanmacid
fi
#update board serial number in deviceid variable
uci set sysconfig.smsconfig.smsdeviceid=$serialnum
uci set modem.CWAN1.smsdeviceid=$serialnum
uci set modem.CWAN1_0.smsdeviceid=$serialnum
uci set modem.CWAN1_1.smsdeviceid=$serialnum
uci commit modem

echo "$BoardPowerGpio" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$BoardPowerGpio/direction
echo "$BoardOnValue" > /sys/class/gpio/gpio$BoardPowerGpio/value

sleep 1

simup=$(ls /sys/class/gpio/ | grep -i gpio$Sim1LedGpio)
###################################################################
# Export for sim1 and sim2 gpio LEDs
if [ -z $simup ]
then
	#Sim1 led gpio
	echo "$Sim1LedGpio" > /sys/class/gpio/export 
	echo out > /sys/class/gpio/gpio$Sim1LedGpio/direction
	echo "$Sim1LedGpioOnvalue" > /sys/class/gpio/gpio$Sim1LedGpio/value

	sleep 1

	#Sim2 led gpio
	echo "$Sim2LedGpio" > /sys/class/gpio/export 
	echo out > /sys/class/gpio/gpio$Sim2LedGpio/direction
	echo "$Sim2LedGpioOffvalue" > /sys/class/gpio/gpio$Sim2LedGpio/value
fi
###################################################################

if [ "$NoOfModem" = "1" ]
then
# for onboard Modem power recycle gpio initialization (or its mini-PCIe slot J5 / USB3 , USB3_ENABLE)
echo "$Modem1PowerGpio" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$Modem1PowerGpio/direction
echo "$Modem1PowerOnValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value
fi

if [ "$NoOfModem" = "2" ]
then
# for onboard Modem power recycle gpio initialization (or its mini-PCIe slot J5 / USB3 , USB3_ENABLE)
echo "$Modem1PowerGpio" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$Modem1PowerGpio/direction
echo "$Modem1PowerOnValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value
sleep 1
# for 2nd mini-PCIe slot power recycle gpio initialization (or its mini-PCIe slot J2 / USB4, USB2_ENABLE)
echo "$Modem2PowerGpio" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$Modem2PowerGpio/direction
echo "$Modem2PowerOnValue" > /sys/class/gpio/gpio$Modem2PowerGpio/value
fi

if [ "$ExternelUsb" = "1" ]
then
# for external USB connector power enable / disable (USB2 and USB1_ENABLE)
echo "$ExternelUsbGpio" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$ExternelUsbGpio/direction
echo "$ExternelUsbOnValue" > /sys/class/gpio/gpio$ExternelUsbGpio/value
fi

# Sim Select Gpio
echo "$SimSelectGpio" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$SimSelectGpio/direction
echo "$Sim1SelectValue" > /sys/class/gpio/gpio$SimSelectGpio/value

if [ "$NoOfProgramLed" = "1" ]
then
# Programmable led1
echo "$ProgramLed1Number" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$ProgramLed1Number/direction
echo "$ProgramLed1OffValue" > /sys/class/gpio/gpio$ProgramLed1Number/value
fi


if [ "$NoOfProgramLed" = "2" ]
then
# Programable led1
echo "$ProgramLed1Number" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$ProgramLed1Number/direction
echo "$ProgramLed1OffValue" > /sys/class/gpio/gpio$ProgramLed1Number/value
sleep 1
# Programable led2
echo "$ProgramLed2Number" > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio$ProgramLed2Number/direction
echo "$ProgramLed2OnValue" > /sys/class/gpio/gpio$ProgramLed2Number/value
fi

# System Reset Button
source /root/ConfigFiles/ResetGpioValue.cfg
echo "$SystemResetSwitch" > /sys/class/gpio/export 
echo in > /sys/class/gpio/gpio$SystemResetSwitch/direction

# WPS reset button
source /root/ConfigFiles/WpsSwitchValue.cfg
echo "$SystemWpsSwitch" > /sys/class/gpio/export 
echo in > /sys/class/gpio/gpio$SystemWpsSwitch/direction


IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)
OpenvpnEnable=$(uci get vpnconfig1.general.enableopenvpngeneral)


/root/InterfaceManager/script/GPIO_Polling_nvp_int_wo_Print_w_script "$SystemResetSwitch" /root/InterfaceManager/script/Restore.sh &

uci set testappenable.testappen.enable="1"

source /root/Web_page/Board_info.txt
if [ "$board_name" = "Silbo_RC44" ]
then
/root/InterfaceManager/script/GPIO_Polling_wps_and_wifiON_OFFint_wo_Print_w_script "$SystemWpsSwitch"  /root/InterfaceManager/status/WPS.sh  /root/InterfaceManager/script/Wifi_On_Off.sh &
fi

uci commit testappenable

/bin/sleep 30

/root/InterfaceManager/script/TimeSync.sh &

/root/last_poweroff_on_reason.sh &
sleep 5
/root/Device_health_status.sh &
/root/Device_health/LAST_Power.sh &

if [ "$EnableCellular" = "1" ]                                      
then
    #~ status=$(/usr/bin/gcom -d /dev/"${PortType1}""${ComPort1}" -s "$GcomScript" | awk FNR==2 | cut -d " " -f 2 | cut -c1-5)
  	#~ if [ "$status" = "READY" ]
  	#~ then
    		/root/InterfaceManager/script/InterfaceInitializer.sh boot 
  	#~ fi
fi

mwan3status=$(uci get mwan3config.general.select)
if [ "$mwan3status" = "failover" ] || [ "$mwan3status" = "balanced" ]
then
    /etc/init.d/mwan3 start
fi
/etc/init.d/uhttpd start

if [ "$IpsecEnable" = "1" ] ; then   
    interfac=$(route -n | awk NR==3 | awk '{print $8}')                                                                           
   if [ "$interfac" = "eth0.4" ]                                                                                                 
   then                                                                                                                          
     uci set ipsec.general.interface="EWAN1"                                                                                     
     uci set firewall.ipsec_rule1.src="EWAN1"                                                                                     
     uci set firewall.ipsec_rule2.src="EWAN1"                                                                                     
     uci set firewall.ipsec_rule3.src="EWAN1"                                                                                     
   elif [ "$interfac" = "eth0.5" ]                                                                                               
   then                                                                                                                          
      uci set ipsec.general.interface="EWAN2" 
     uci set firewall.ipsec_rule1.src="EWAN2"                                                                                     
     uci set firewall.ipsec_rule2.src="EWAN2"                                                                                     
     uci set firewall.ipsec_rule3.src="EWAN2"
   elif [ "$interfac" = "apcli0" ]                                                                                               
   then                                                                                                                          
      uci set ipsec.general.interface="WIFI_WAN" 
     uci set firewall.ipsec_rule1.src="WIFI_WAN"                                                                                     
     uci set firewall.ipsec_rule2.src="WIFI_WAN"                                                                                     
     uci set firewall.ipsec_rule3.src="WIFI_WAN"                                                                                      
   elif [ "$interfac" = "3g-CWAN1" ]                                                                                             
   then                                                                                                                          
      uci set ipsec.general.interface="CWAN1"
     uci set firewall.ipsec_rule1.src="CWAN1"                                                                                     
     uci set firewall.ipsec_rule2.src="CWAN1"                                                                                     
     uci set firewall.ipsec_rule3.src="CWAN1"                                                                                    
   elif [ "$interfac" = "3g-CWAN2" ]                                                                                             
   then                                                                                                                          
      uci set ipsec.general.interface="CWAN2"  
     uci set firewall.ipsec_rule1.src="CWAN2"                                                                                     
     uci set firewall.ipsec_rule2.src="CWAN2"                                                                                     
     uci set firewall.ipsec_rule3.src="CWAN2"                                                                                    
   elif [ "$interfac" = "3g-CWAN1_0" ]                                                                                           
   then                                                                                                                          
      uci set ipsec.general.interface="CWAN1_0"  
     uci set firewall.ipsec_rule1.src="CWAN1_0"                                                                                     
     uci set firewall.ipsec_rule2.src="CWAN1_0"                                                                                     
     uci set firewall.ipsec_rule3.src="CWAN1_0"                                                                                  
   elif [ "$interfac" = "3g-CWAN1_1" ]                                                                                           
   then                                                                                                                          
      uci set ipsec.general.interface="CWAN1_1" 
     uci set firewall.ipsec_rule1.src="CWAN1_1"                                                                                     
     uci set firewall.ipsec_rule2.src="CWAN1_1"                                                                                     
     uci set firewall.ipsec_rule3.src="CWAN1_1"                                                                                   
   elif [ "$interfac" = "usb0" ]                                                                                                 
   then                                                                                                                          
       if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]                                                          
       then                                                                                                                      
           uci set ipsec.general.interface="CWAN1" 
            uci set firewall.ipsec_rule1.src="CWAN1"                                                                                     
           uci set firewall.ipsec_rule2.src="CWAN1"                                                                                     
           uci set firewall.ipsec_rule3.src="CWAN1"                                                                               
       else                                                                                                                      
           simnum=$(cat /tmp/simnumfile)                                                                                         
           if [ "$simnum" = "1" ]                                                                                                
           then                                                                                                                  
             uci set ipsec.general.interface="CWAN1_0"
             uci set firewall.ipsec_rule1.src="CWAN1_0"                                                                                     
             uci set firewall.ipsec_rule2.src="CWAN1_0"                                                                                     
             uci set firewall.ipsec_rule3.src="CWAN1_0"                                                                            
           else                                                                                                                  
             uci set ipsec.general.interface="CWAN1_1"
             uci set firewall.ipsec_rule1.src="CWAN1_1"                                                                                     
             uci set firewall.ipsec_rule2.src="CWAN1_1"                                                                                     
             uci set firewall.ipsec_rule3.src="CWAN1_1"                                                                            
           fi                                                                                                                    
       fi                                                                                                                        
   else                                                                                                                          
       if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]                                                          
       then                                                                                                                      
           uci set ipsec.general.interface="CWAN1"
           uci set firewall.ipsec_rule1.src="CWAN1"                                                                                     
           uci set firewall.ipsec_rule2.src="CWAN1"                                                                                     
           uci set firewall.ipsec_rule3.src="CWAN1"                                                                                
       else                                                                                                                      
           simnum=$(cat /tmp/simnumfile)                                                                                         
           if [ "$simnum" = "1" ]                                                                                                
           then                                                                                                                  
             uci set ipsec.general.interface="CWAN1_0" 
             uci set firewall.ipsec_rule1.src="CWAN1_0"                                                                                     
             uci set firewall.ipsec_rule2.src="CWAN1_0"                                                                                     
             uci set firewall.ipsec_rule3.src="CWAN1_0"                                                                           
           else                                                                                                                  
             uci set ipsec.general.interface="CWAN1_1"
             uci set firewall.ipsec_rule1.src="CWAN1_1"                                                                                     
             uci set firewall.ipsec_rule2.src="CWAN1_1"                                                                                     
             uci set firewall.ipsec_rule3.src="CWAN1_1"                                                                            
           fi                                      
         fi                                                                                                                        
    fi                                                                                                                           
    uci commit ipsec
    uci commit firewall
    sleep 1
    /etc/init.d/firewall reload
                                                                                         
   /etc/init.d/ipsec start                                                                                                       
   /bin/sleep 4                                                                                                                  
   /usr/sbin/ipsec restart                                                                                                       
fi 

if [ "$OpenvpnEnable" = "1" ] ; then
/etc/init.d/openvpn start
uci set vpnconfig1.general.openvpnrunning=1
uci commit vpnconfig1
else
uci set vpnconfig1.general.openvpnrunning=0
uci commit vpnconfig1
uci set openvpn.custom_config.enabled=0
fi

uci commit openvpn

sleep 4

if [ "$SmsEnable1" = "1" ] || [ "SmsEnable2" = "1" ]
then
  /root/InterfaceManager/script/SMS_Incomming_event.sh &
fi

BordType=$(uci get boardconfig.board.moduletype)

if [ "$BordType" = "2" ] || [ "$BordType" = "3" ] || [ "$BordType" = "6" ]
then
atnetworkinfo1=$(gcom -d /dev/"${PortType1}""${ComPort1}" -s /etc/gcom/atnetworkinfo1.gcom | awk 'NR==2')
atnetworklatchinfo=$(echo "$atnetworkinfo1" | cut -d ":" -f 2 | cut -d "," -f 4 | tr -d '\011\012\013\014\015\040')

if [ $atnetworklatchinfo -eq 7 ] || [ $atnetworklatchinfo -eq 8 ]
then
echo "$ProgramLed1OffValue" > /sys/class/gpio/gpio$ProgramLed1Number/value
else
echo "$ProgramLed1OffValue" > /sys/class/gpio/gpio$ProgramLed1Number/value
fi
fi

mwan3status=$(uci get mwan3config.general.select)
if [ "$mwan3status" = "failover" ] || [ "$mwan3status" = "balanced" ]
then
    /usr/sbin/mwan3 restart &
elif [ "$mwan3status" = "none" ] 
then
    mwan3 stop
fi
RMS_Value=$(uci get remoteconfig.general.rmsoption)
NMS_Enable=$(uci get remoteconfig.nms.nmsenable)
if [ "${RMS_Value}" = "nms" ] && [ "${NMS_Enable}" = "1" ]
then
	/etc/init.d/openwisp-config start
	sleep 3
	response=$($Openvpnmain)
	sleep 2
	/etc/init.d/openwisp-monitoring start
else
	/etc/init.d/openwisp-config stop
	sleep 2
	/etc/init.d/openwisp-monitoring stop
fi

uci commit sysconfig


/bin/cellulardatausagemanagerscript.sh
/bin/macidblocking.sh 
/bin/routing.sh 
/root/InterfaceManager/script/Update_Analytics_data.sh
if [ "${easycwmp_status}" = "1" ];then
/bin/TR069_launch.sh
fi
/root/InterfaceManager/script/IpSecStart.sh
Apclient=$(uci get sysconfig.wificonfig.wifi1mode)
if [ $Apclient = "sta" ] || [ $Apclient = "apsta" ]
then
   /root/InterfaceManager/script/Wifi_udhcpcmonitor.sh &			  		
fi

######################################################################

#On reboot, the added static route will dissapper from route -n. So, run the routing.sh script.
/bin/routing.sh &

#(For Default route)
#To run pptp_get_gateway.sh script again. This is because all the tables might not have been created.
killall -9 /usr/sbin/pppd

######################################################################
#Adding the above rule with precedence 1, will make all the interfaces not route through table 1,2 ... etc,
#but, via main table.
pptpstatus=$(uci get vpnconfig1.general.enablepptpgeneral)
if [ "$pptpstatus" = "1" ];then
	ip rule add from all lookup main priority 1
fi


exit 0

