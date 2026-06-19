#!/bin/sh

. /lib/functions.sh

#echo "Input Command: $1"

{
  echo "opengt"
  echo -e "\tset com 115200n81"
  echo -e "\tset comecho off"
  echo -e "\tset senddelay 0.02"
  echo -e "\twaitquiet 0.2 0.2"
  echo -e "\tflash 0.1"
  echo -e "\n"
  echo ":start"
  echo -e "\tsend \""$1"^m\""
  echo -e "\tget 1 \"\" \$s"
  echo -e "\tprint \$s"
  echo -e "\n"
  echo ":continue"
  echo -e "\texit 0"
} > /etc/gcom/testweb.gcom

ReadModemConfigFile()
{
	config_load "$ReadModem"
	config_get SingleSimDualModule cellularmodule singlesimdualmodule
	config_get SingleSimSingleModule cellularmodule singlesimsinglemodule
	config_get DualSimSingleModule cellularmodule dualsimsinglemodule

}

ReadDevice()
{
	config_load "$ReadModem"
	
}

ReadModem="/etc/config/modem"
ReadModemConfigFile
 simnum=$(cat /tmp/simnumfile);

if [ "$SingleSimSingleModule" = "1" ]
then
   ReadDevice "CWAN1"
   if [ "$simnum" = 1 ]
	then 
	ConfiguredComPort=$(grep -w "ComPort" /tmp/InterfaceManager/status/CWAN1.ports ) > /dev/null 2>&1
		if [ "$?" = "2" ]
		then 
		     response="modem is not yet up,please retry after sometime"
		     atoutput=$response
		else 
			source /tmp/InterfaceManager/status/CWAN1.ports
			atoutput=$(gcom -d "$ComPort" -s /etc/gcom/testweb.gcom)
		fi

	fi
elif [ "$DualSimSingleModule" = "1" ]
then
   ReadDevice "CWAN1_0"
   
	if [ "$simnum" = 1 ]
	then 
	ConfiguredComPort=$(grep -w "ComPort" /tmp/InterfaceManager/status/CWAN1_0.ports ) > /dev/null 2>&1
		if [ "$?" = "2" ]
		then 
		     response="modem is not yet up,please retry after sometime"
		     atoutput=$response
		else 
		     source /tmp/InterfaceManager/status/CWAN1_0.ports
		     atoutput=$(gcom -d "$ComPort" -s /etc/gcom/testweb.gcom)
		fi
		
	elif [ "$simnum" = 2 ]
	then
	ConfiguredComPort=$(grep -w "ComPort" /tmp/InterfaceManager/status/CWAN1_1.ports ) > /dev/null 2>&1
  		if [ "$?" = "2" ]
		then 
		     response="modem is not yet up,please retry after sometime"
		     atoutput=$response
		else 
			source /tmp/InterfaceManager/status/CWAN1_1.ports
			atoutput=$(gcom -d "$ComPort" -s /etc/gcom/testweb.gcom)
		fi
	fi
fi



echo "$atoutput" | sed 's/"/ /g'


exit 0
