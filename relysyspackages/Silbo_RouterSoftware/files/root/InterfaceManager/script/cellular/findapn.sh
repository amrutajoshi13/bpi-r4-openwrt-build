#!/bin/sh

	date=$(date) > /dev/null 2>&1
	#ComPort=$1
	InterfaceName=$1
	ConfiguredComPort=$(uci get modem.$InterfaceName.comport)
        ConfiguredComPort=$((ConfiguredComPort + 1))
       echo "Configured comport is $ConfiguredComPort" 
        ComPortSymLink=$(find /dev -maxdepth 1 -name  "$InterfaceName""_"* | sort | sed -n $ConfiguredComPort"p")
        [ "x$ComPortSymLink" != "x" ]  && ComPortSymLink="$ComPortSymLink" && ComPort=$(readlink -f "$ComPortSymLink")
	echo "InterfaceName is $InterfaceName,Comport=$ComPort"  
	echo "Comport=$ComPort" > /tmp/InterfaceManager/status/ATComport.txt
	if [ "$InterfaceName" = "CWAN1" ] || [ "$InterfaceName" = "CWAN1_0" ]
	then
		Apntype=$(uci get sysconfig.sysconfig.Sim1apntype)
	elif [ "$InterfaceName" = "CWAN1_1" ]
	then
		Apntype=$(uci get sysconfig.sysconfig.Sim2apntype)
	fi
					
	if [ $Apntype = "auto" ] 
    then
		for i in 1 2 3 4 5 6
		do
			Quality_Signal_Noise_Full=$(gcom -d /dev/ttyUSB$i -s /etc/gcom/getquality.gcom)
	echo "InterfaceName is Quality_signal=$Quality_Signal_Noise_Full"  
			Connected_LTE=$(echo "$Quality_Signal_Noise_Full" | grep -o LTE | tr -d '\011\012\013\014\015\040')
			Connected_GSM=$(echo "$Quality_Signal_Noise_Full" | grep -o GSM | tr -d '\011\012\013\014\015\040')
			Connected_NSA=$(echo "$Quality_Signal_Noise_Full" | grep -o NR5G-NSA | tr -d '\011\012\013\014\015\040')
			Connected_SA=$(echo "$Quality_Signal_Noise_Full" | grep -o NR5G-SA | tr -d '\011\012\013\014\015\040')
			Connected_EDGE=$(echo "$Quality_Signal_Noise_Full" | grep -o EDGE | tr -d '\011\012\013\014\015\040')
			Connected_GPRS=$(echo "$Quality_Signal_Noise_Full" | grep -o GPRS | tr -d '\011\012\013\014\015\040')
			Connected_CDMA=$(echo "$Quality_Signal_Noise_Full" | grep -o CDMA | tr -d '\011\012\013\014\015\040')
	
			if [ "$Connected_LTE" = "LTE" ] && [ "$Connected_NSA" = "NR5G-NSA" ]
			then
				Connected="NSA"
				Quality_Signal_Noise1=$(echo "$Quality_Signal_Noise_Full" | awk NR==3)
				Quality_Signal_Noise2=$(echo "$Quality_Signal_Noise_Full" | awk NR==4)
			elif [ "$Connected_LTE" = "GSM" ]
			then
				Connected="GSM"
				Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
			
			elif [ "$Connected_LTE" = "LTE" ]
			then
				Connected="LTE"
				Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
				
			elif [ "$Connected_SA" = "NR5G-SA" ]
			then
				Connected="SA"
				Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
			elif [ "$Connected_EDGE" = "EDGE" ]
			then
				Connected="EDGE"
				Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
			elif [ "$Connected_GPRS" = "GPRS" ]
			then
				Connected="GPRS"
				Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
			elif [ "$Connected_CDMA" = "CDMA" ]
			then
				Connected="CDMA"
				Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
			fi
			
			if [ "$Connected" = "SA" ] 
			then
				MCC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')
				MNC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 6 | tr -d '\011\012\013\014\015\040')
			elif [ "$Connected" = "LTE" ] 
			then
				MCC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')
				MNC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 6 | tr -d '\011\012\013\014\015\040')
			elif [ "$Connected" = "NSA" ]
			then
				MCC=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')
				MNC=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 3 | tr -d '\011\012\013\014\015\040')
			elif [ "$Connected" = "GSM" ]
			then
				MCC=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 4 | tr -d '\011\012\013\014\015\040')
				MNC=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')
			else	
				MODE="-"       
				MCC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 4 | tr -d '\011\012\013\014\015\040')                                                      
				MNC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')                                                      
			fi	
			echo "$date :MCC and MNC found is $MCC and $MNC" 
			if [ $MCC -ge "0" ] && [ $MNC -ge "0" ]
			then
			    sleep 2
				APN=$(/root/InterfaceManager/script/cellular/DBlookup $MCC $MNC) 
				if [ "$APN" = "AutoAPN not found ,please change it to manual mode" ] && [ $i = "3" ]
				then       
			    	    APN="AutoAPN not found ,please change it to manual mode"
			           echo "$date :Apn set in modem is $APN" 
			    else 
					echo "$date:APN found is $APN" 
					break
			    fi
            fi
	    done
	fi	 	
if [ $InterfaceName = "CWAN1_0" ] || [ $InterfaceName = "CWAN1" ]                                                                                  
then    
     uci set sysconfig.sysconfig.sim1autoapn="$APN"  
    uci set sysconfig.sysconfig.sim2autoapn="Inactive sim"                                                                                                                                      
elif [ $InterfaceName = "CWAN1_1" ]                                                                                                                 
then 
    uci set sysconfig.sysconfig.sim2autoapn="$APN"  
    uci set sysconfig.sysconfig.sim1autoapn="Inactive sim"                                                                                                                                                                                                        
fi     
uci commit sysconfig

exit 0

