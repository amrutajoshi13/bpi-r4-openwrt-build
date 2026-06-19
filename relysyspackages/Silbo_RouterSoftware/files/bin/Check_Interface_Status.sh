#!/bin/sh

. /lib/functions.sh

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

ReadSystemConfigFile()
{
   	config_load "$SystemConfigFile"
   	config_get CellularOperationModelocal sysconfig CellularOperationMode
   	config_get EnableCellular sysconfig enablecellular
   	config_get pdp1 sysconfig pdp
   	config_get pdp2 sysconfig sim2pdp
}

SystemConfigFile="/etc/config/sysconfig"

ReadSystemConfigFile

if [ "$EnableCellular" = "1" ]
then

	if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
	then
	
	  simnum=$(cat /tmp/simnumfile)                                                                                         
      if [ "$simnum" = "1" ]                                                                                                
      then      
	        InterfaceStatus=$(mwan3 interfaces | grep CWAN1_0 | cut -d " " -f 5) 
		if [ "$pdp1" = "IPV6" ] 
		then                
                    InterfaceStatus=$(mwan3 interfaces | grep wan6c1 | cut -d " " -f 5) 
                fi
	        echo "InterfaceStatus=$InterfaceStatus"
	         if [ $InterfaceStatus == "online" ]
	         then
	             echo 0 > /tmp/InterfaceStatus.txt
		         
	         else
	             echo 1 > /tmp/InterfaceStatus.txt
	         
	         fi
	        
      else  

	        InterfaceStatus=$(mwan3 interfaces | grep CWAN1_1 | cut -d " " -f 5) 
	        
		if [ "$pdp2" = "IPV6" ] 
		then                
                    InterfaceStatus=$(mwan3 interfaces | grep wan6c2 | cut -d " " -f 5) 
                fi
	        if [ $InterfaceStatus == "online" ]
	         then
	             echo 0 > /tmp/InterfaceStatus.txt
		         
	         else
	             echo 1 > /tmp/InterfaceStatus.txt
	         
	         fi
	        
	 fi       
	 
	else
	        InterfaceStatus=$(mwan3 interfaces | grep CWAN1 | cut -d " " -f 5) 
	        
	        if [ "$pdp1" = "IPV6" ] 
					then                
                    InterfaceStatus=$(mwan3 interfaces | grep wan6c1 | cut -d " " -f 5) 
            fi
	        
	        
	        if [ $InterfaceStatus == "online" ]
	         then
	             echo 0 > /tmp/InterfaceStatus.txt
		         
	         else
	             echo 1 > /tmp/InterfaceStatus.txt
	         
	         fi

	fi
	
else

	echo 2 > /tmp/InterfaceStatus.txt
	
fi

