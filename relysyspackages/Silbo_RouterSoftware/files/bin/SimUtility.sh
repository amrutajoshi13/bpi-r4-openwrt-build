#!/bin/sh

. /lib/functions.sh

modemUCIPath=/etc/config/modem
sysconfigsection="interface"
USRBINCMDPATH="/usr/bin"

rm /bin/siminfo.txt
touch /bin/siminfo.txt
chmod 0777 /bin/siminfo.txt

ReadConfig()
{
  var1="$1"
  config_get ModemEnable "$var1" modemenable
  config_get porttype "$var1" porttype
  config_get comport "$var1" comport
  config_get modemenable "$var1" modemenable
}

RunAnalytics()
{
  var="$1"	
  ReadConfig "$var"
  if [ "$ModemEnable" = "1" ]
  then 
		if [ $var = "CWAN1_0" ] 
		then 
		    if [ $modemenable = "1" ]
		    then
			    echo "{\"code\":1,\"output\":\"Active SIM : SIM1 \"}"    
			    cciidinfo=$(${USRBINCMDPATH}/gcom -d /dev/${porttype}$comport -s /etc/gcom/getcardqccidinfo.gcom 2>&1)
			    echo cciidinfo="$cciidinfo"
			    echo "Active SIM = SIM1" >> /bin/siminfo.txt
			    echo ccid="$cciidinfo" >> /bin/siminfo.txt
			    if [ "x$cciidinfo" = "x" ]
					then
					   echo "{\"code\":1,\"output\":\"empty cciidinfo \"}"
				else
				       echo -e "{\"code\":0,\"output\":\n\"$cciidinfo\"}"
				fi	  	
        
            fi
        fi    
        if  [ $var = "CWAN1_1" ] 
		then 
		    if [ $modemenable = "1" ]
		    then
			    echo "{\"code\":1,\"output\":\"Active SIM : SIM2 \"}"    
			    cciidinfo=$(${USRBINCMDPATH}/gcom -d /dev/${porttype}$comport -s /etc/gcom/getcardqccidinfo.gcom 2>&1)
			    echo cciidinfo="$cciidinfo"
			    echo "Active SIM = SIM2" >> /bin/siminfo.txt
			    echo ccid="$cciidinfo" >> /bin/siminfo.txt
			    if [ "x$cciidinfo" = "x" ]
					then
					   echo "{\"code\":1,\"output\":\"empty cciidinfo \"}"
				else
				       echo -e "{\"code\":0,\"output\":\n\"$cciidinfo\"}"
				fi	  	
        
           fi
       
	  fi
	  if  [ $var = "CWAN1" ] 
		then 
		    if [ $modemenable = "1" ]
		    then
			    echo "{\"code\":1,\"output\":\"Active SIM : SIM1 \"}"    
			    cciidinfo=$(${USRBINCMDPATH}/gcom -d /dev/${porttype}$comport -s /etc/gcom/getcardqccidinfo.gcom 2>&1)
			   # echo cciidinfo="$cciidinfo" >> /bin/siminfo.txt
			    echo "Active SIM = SIM1" >> /bin/siminfo.txt
			    #ccid=$("$cciidinfo" | grep "QCCID" | cut -d ":" -f2)
			    echo ccid="$cciidinfo" >> /bin/siminfo.txt
			    echo ccid="$ccid"
			    if [ "x$cciidinfo" = "x" ]
					then
					   echo "{\"code\":1,\"output\":\"empty cciidinfo \"}"
				else
				       echo -e "{\"code\":0,\"output\":\n\"$cciidinfo\"}"
				fi	 	
        
           fi
       
	  fi
	  
	  if  [ $var = "CWAN2" ] 
		then 
		    if [ $modemenable = "1" ]
		    then
			    echo "{\"code\":1,\"output\":\"Active SIM : SIM2 \"}"    
			    cciidinfo=$(${USRBINCMDPATH}/gcom -d /dev/${porttype}$comport -s /etc/gcom/getcardqccidinfo.gcom 2>&1)
			    echo cciidinfo="$cciidinfo"
			    echo "Active SIM = SIM2" >> /bin/siminfo.txt
			    echo ccid="$cciidinfo" >> /bin/siminfo.txt
			    if [ "x$cciidinfo" = "x" ]
					then
					   echo "{\"code\":1,\"output\":\"empty cciidinfo \"}"
				else
				       echo -e "{\"code\":0,\"output\":\n\"$cciidinfo\"}"
				fi	  	
        
           fi
       
	  fi	  
	   
 fi	     
  
}


config_load "$modemUCIPath"
config_foreach RunAnalytics interface

exit 0
