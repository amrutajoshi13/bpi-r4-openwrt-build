#!/bin/sh

. /lib/functions.sh

Openvpnmain="/bin/openvpngeneral.sh"
mwan3status=$(uci get mwan3config.general.select)

ReadSystemConfigFile()
{
   	config_load "$SystemConfigFile"
   	config_get CellularOperationModelocal sysconfig CellularOperationMode
   	config_get EnableCellular sysconfig enablecellular
   	config_get Service sysconfig service
   	config_get Sim2Service sysconfig sim2service
	config_get SmsEnable1 smsconfig smsenable1
	config_get SmsEnable2 smsconfig smsenable2
	config_get Wifi1Mode wificonfig wifi1mode
   	
}


ReadSystemGpioFile()
{
   	config_load "$SystemGpioConfig"
	config_get SimSelectGpio gpio simselectgpio
	config_get Sim1SelectValue gpio sim1selectvalue
	config_get Sim2SelectValue gpio sim2selectvalue
}

swlaninterface="SW_LAN"
lan1interface="LAN1"
lan2interface="LAN2"
lan3interface="LAN3"
lan4interface="LAN4"
ethwan1interface="EWAN1"
ethwan2interface="EWAN2"
cellularwan1interface="CWAN1"
cellularwan2interface="CWAN2"
cellularwan3interface="CWAN3"
cellularwan1sim1interface="CWAN1_0"
cellularwan1sim2interface="CWAN1_1"
wifiap="WIFI"
wifista="WIFI_WAN"

SystemGpioConfig="/etc/config/systemgpio"
SystemConfigFile="/etc/config/sysconfig"

MwanConfigFile="/etc/config/mwan3config"

Gcom2Gonly="/etc/gcom/set2gonly.gcom"
Gcom4Gonly="/etc/gcom/set4gonly.gcom"
GcomAutoonly="/etc/gcom/setauto.gcom"

ReadSystemConfigFile
ReadSystemGpioFile


simtmpfile="/tmp/simnumfile"
SimSwitchingGpio="/sys/class/gpio/gpio$SimSelectGpio/value"

Logfile="/root/ConfigFiles/Logs/AddIfaceLog.txt"
Findapn="/root/InterfaceManager/script/cellular/findapn.sh"
AutoApnFlag="/root/usrRPC/script/autoapnflag.txt"
model1=$(uci get sysconfig.sysconfig.model1)
mwan3status=$(uci get mwan3config.general.select)
#/etc/init.d/firewall restart
#/etc/init.d/dnsmasq restart
#/etc/init.d/network reload                            
ubus call network reload

IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)
OpenvpnEnable=$(uci get vpnconfig1.general.enableopenvpngeneral)

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
    logger -t config -p customs.info "firewall configuration changed"
    sleep 1
    /etc/init.d/firewall reload
    
    /etc/init.d/ipsec stop
    /bin/sleep 2                                                                                       
   /etc/init.d/ipsec start                                                                                                       
   /bin/sleep 4                                                                                                                  
   /usr/sbin/ipsec restart                                                                                                       

fi

if [ "$OpenvpnEnable" = "1" ] ; then
response=$($Openvpnmain)
sleep 2
uci set vpnconfig1.general.openvpnrunning=1
uci commit vpnconfig1
else
uci set vpnconfig1.general.openvpnrunning=0
uci commit vpnconfig1
fi

NMS_Enable=$(uci get remoteconfig.nms.nmsenable)

if [ "${NMS_Enable}" = "1" ]
then
response=$($Openvpnmain)
fi


if [ "$EnableCellular" = "0" ]
then
   sed -i '/Reset_data_usage/d' /etc/crontabs/root
   sed -i '/cellulardatausagemanagerspeedcronscript/d' /etc/crontabs/root
   sed -i '/Data_Cap/d' /etc/crontabs/root
fi
/bin/macidblocking.sh
/bin/routing.sh

exit 0
