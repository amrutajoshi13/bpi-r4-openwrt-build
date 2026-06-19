#!/bin/sh

. /lib/functions.sh

Serial="$1"

if [ ! -f "/etc/config/boardconfig" ]
then
{
 echo "config interface 'board'"
 echo -e "\toption serialnum '1'"
 #echo -e "\toption pcbnum '123'" 
 echo -e "\toption moduletype '8'" 
 echo -e "\toption macid '12:12:12:12:12'"
 echo -e "\toption macid1 '12:12:12:12:12'"
 echo -e "\toption macid2 '12:12:12:12:12'"
 echo -e "\toption macid3 '12:12:12:12:12'"
 echo -e "\toption firmwareVer '1.10'"
 echo -e "\toption ApplicationSwVer '1.08'"
 echo -e "\toption imei '999090290280'"
} > /etc/config/boardconfig
fi

ReadModemConfigFile()                                                                            
{                                                                                                
        config_load "$ReadModem"                                                                 
        config_get SingleSimDualModule cellularmodule singlesimdualmodule                        
        config_get SingleSimSingleModule cellularmodule singlesimsinglemodule                    
        config_get DualSimSingleModule cellularmodule dualsimsinglemodule                        
                                                                                                 
} 

ReadSystemGpioFile()                               
{                                                    
        config_load "$SystemGpioConfig"              
        config_get Modem1PowerGpio gpio modem1powergpio
        config_get Modem1PowerOnValue gpio modem1poweronvalue
        config_get Modem1PowerOffValue gpio modem1poweroffvalue
}

ReadDevice()
{
        config_load "$ReadModem"
        config_get ComPort "$1" comport
}

ReadModem="/etc/config/modem"
SystemGpioConfig="/etc/config/systemgpio"

ReadModemConfigFile
ReadSystemGpioFile


if [ "$SingleSimSingleModule" = "1" ]
then                            
   ReadDevice "CWAN1"                  
elif [ "$DualSimSingleModule" = "1" ]  
then                                   
   ReadDevice "CWAN1_0"                
fi  

uci set boardconfig.board.serialnum="$Serial"

uci set system.system.hostname="$Serial"

macfirst=$(echo "$Serial" | cut -b 2,3)

macsecond=$(echo "$Serial" | cut -b 4,5)

macthird=$(echo "$Serial" | cut -b 6)

last=$(echo "$Serial" | tail -c 5)

macfour=$(echo "$last" | cut -b 1,2)

macfive=$(echo "$last" | cut -b 3,4)

uci set boardconfig.board.macid="9C:${macfirst}:${macsecond}:${macthird}0:${macfour}:${macfive}"

uci set boardconfig.board.macid1="9C:${macfirst}:${macsecond}:${macthird}1:${macfour}:${macfive}"

uci set boardconfig.board.macid2="9C:${macfirst}:${macsecond}:${macthird}2:${macfour}:${macfive}"

uci set boardconfig.board.macid3="9C:${macfirst}:${macsecond}:${macthird}3:${macfour}:${macfive}"

while [ `cat /sys/class/gpio/gpio$Modem1PowerGpio/value` -eq 1 ]
do
echo "modem is off"
echo "$Modem1PowerOnValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value
sleep 10
done

sleep 5

for i in $(seq 0 3)
do
  Imei=$(gcom -d /dev/ttyUSB"$ComPort" -s /root/Test_APP/atgsn_test.gcom | awk 'NR==2' | tr -d '\011\012\013\014\015\040')
  if [ ${#Imei} -eq 15 ]
  then
   echo "imei read success"  
   break
  fi
done

uci set boardconfig.board.imei="$Imei"

uci commit system

uci commit boardconfig

exit 0
