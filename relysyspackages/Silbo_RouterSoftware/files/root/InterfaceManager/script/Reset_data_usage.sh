#!/bin/sh

. /lib/functions.sh

Sim1DataFile="/etc/sim1data"
Sim1DataFlagFile="/etc/sim1dataflag"
TmpSim1DataFile="/tmp/sim1data"
Sim2DataFile="/etc/sim2data"
Sim2DataFlagFile="/etc/sim2dataflag"
TmpSim2DataFile="/tmp/sim2data"
SimDataFile="/etc/simdata"
SimDataFlagFile="/etc/simdataflag"
TmpSimDataFile="/tmp/simdata"
mwan3status=$(uci get mwan3config.general.select)                                
NMS_Enable=$(uci get remoteconfig.nms.nmsenable)

                                                               
if [ -f "$TmpSim1DataFile" ]                                            
then              
   echo 0 > "$TmpSim1DataFile"                                         
fi

if [ -f "$TmpSim2DataFile" ]                                            
then   
   echo 0 > "$TmpSim2DataFile"                                         
fi

if [ -f "$TmpSimDataFile" ] 
then
   echo 0 > "$TmpSimDataFile" 
fi

if [ -f "$Sim1DataFlagFile" ] 
then
   echo 0 > "$Sim1DataFlagFile" 
fi

if [ -f "$Sim2DataFlagFile" ] 
then
   echo 0 > "$Sim2DataFlagFile" 
fi

if [ -f "$SimDataFlagFile" ] 
then
   echo 0 > "$SimDataFlagFile" 
fi

if [ -f "$Sim1DataFile" ]                                            
then
   flash_data_used=`cat "$Sim1DataFile"` 
   num_writes_full=$(echo "$flash_data_used" | cut -d "," -f 2)                         
   echo "0,$num_writes_full,0" > "$Sim1DataFile"                                           
fi                            
                              
if [ -f "$Sim2DataFile" ]  
then                          
   flash_data_used=`cat "$Sim2DataFile"`
   num_writes_full=$(echo "$flash_data_used" | cut -d "," -f 2)
   echo "0,$num_writes_full,0" > "$Sim2DataFile" 
fi                            
                              
if [ -f "$SimDataFile" ]   
then                          
   flash_data_used=`cat "$SimDataFile"`
   num_writes_full=$(echo "$flash_data_used" | cut -d "," -f 2)
   echo "0,$num_writes_full,0" > "$SimDataFile"  
fi                           

IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)
OpenvpnEnable=$(uci get vpnconfig1.general.enableopenvpngeneral)

/etc/init.d/mwan3 stop
/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
sleep 10

	[ ! -f /tmp/InterfaceStatus/CWAN1_1Status ] && touch /tmp/InterfaceStatus/CWAN1_1Status                                  
	echo "`date` Interface CWAN1_1 DOWN" >> /tmp/InterfaceStatus/CWAN1_1Status  
	echo "Sim Switch"
	sleep 10
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
																								   
	/etc/init.d/ipsec stop                                                                                                        
	/bin/sleep 1                                                                                                                  
	/etc/init.d/ipsec start                                                                                                       
	/bin/sleep 4                                                                                                                  
	/usr/sbin/ipsec restart                                                                                                       
	fi 
	if [ "$OpenvpnEnable" = "1" ] ; then                             
	/etc/init.d/openvpn restart                                      
	fi
	if [ "$NMS_Enable" = "1" ]
   then
	/etc/init.d/openvpn restart
   fi 
   
if [ "$mwan3status" = "failover" ] || [ "$mwan3status" = "balanced" ]
then
	/usr/sbin/mwan3 restart > /dev/null 2>&1
	/bin/sleep 2
elif [ "$mwan3status" = "none" ] 
then
    mwan3 stop
fi
