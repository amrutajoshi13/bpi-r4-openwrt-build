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
#commented as on 6th ,march 2023   	config_get Service sysconfig service
	config_get Service sysconfig bandselectenable
   	config_get Sim2Service sysconfig sim2service
}

SystemConfigFile="/etc/config/sysconfig"

ReadSystemConfigFile

if [ "$EnableCellular" = "1" ]
then
	if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
	then
	  ComPort1=$(cat "/tmp/InterfaceManager/status/$cellularwan1interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
	  ComPort2=$(cat "/tmp/InterfaceManager/status/$cellularwan2interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
	elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
	then
	  simnum=$(cat /tmp/simnumfile)                                                                                         
      if [ "$simnum" = "1" ]                                                                                                
      then
        ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim1interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
      else
        ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim2interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)     
      fi 
	else
      ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim1interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
	fi
fi

                                                                    
FotaConfigFile="/etc/config/ltemodulefirmwareupgrade"                  
                                                                     
FOTA="/etc/gcom/fota.gcom"                                               
FirmwareVersionGcom="/etc/gcom/getfirmwareversion.gcom"           
flag=1                                                                   
RebootBoard="/root/usrRPC/script/Board_Recycle_12V_Script.sh"              
                                                                           
ReadConfig()                                                               
{                                                                          
  config_load "$FotaConfigFile"                                          
  config_get AuthEnable ltemodulefirmwareupgrade Authenable                
  config_get User ltemodulefirmwareupgrade user                      
  config_get Password ltemodulefirmwareupgrade password                  
  config_get URL ltemodulefirmwareupgrade url                                                  
  config_get ConnectionTimeout ltemodulefirmwareupgrade connectiontimeout                      
  config_get OperationTimeout ltemodulefirmwareupgrade operationtimeout                        
  config_get FirmwareVersion ltemodulefirmwareupgrade firmwareversion                          
}                           
                                                                                               
ReadConfig                    
                                                                                                                                          
{                                                                                                                                         
 echo "opengt"                                                                                                                            
 echo -e "\tset com 115200n81"                                                                                                            
 echo -e "\tset comecho off"                    
 echo -e "\tset senddelay 0.02"                                                                                                           
 echo -e "\twaitquiet 0.2 0.2"                                                                 
 echo -e "\tflash 0.1"
 echo -e "\n"                                                                                                                             
 echo ":start"                                  
 echo -e "\tsend \"AT+QFOTADL="ftp://"$User":"$Password"@"$URL"",1,5,5^m"\"                                                               
 echo -e "get 1 \"\" \$s"                                                                      
 echo -e "print \$s"                       
 echo -e "\n"                                                                                                                             
 echo ":continue"                               
 echo -e "\texit 0"                                                                                                                       
} > ${FOTA}                        

fotaoutput=$(gcom -d "$ComPort" -s "$FOTA" | awk 'NR==2' | tr -d '\011\012\013\014\015\040')
                                                                                               
if [ "$fotaoutput" = "OK"  ]                                                                   
then                                                                                           
  while true                                                                                  
  do                                                                                           
  sleep 120                                                                                    
  FirmwareUpdated=$(gcom -d "$ComPort" -s "$FirmwareVersionGcom" | grep -i "Revision" | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
  if [ "$FirmwareUpdated" = "$FirmwareVersion" ]                                                                                          
  then                                                                                                                                    
     echo "Firmware Updated Successfully"                                                                                                 
     $RebootBoard                                                                                                                         
     break                                                                                                                                
  fi                                                                                                                                      
 done                                                                                                                                     
else                                                                                                                                      
   echo "Failed to Updated Module Firmware"                                                                                               
fi      
